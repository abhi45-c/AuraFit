//
//  FoodItem.swift
//  AuraFit
//
//  Created by Abhirup Pal on 10/27/25.
//


import Foundation
import CoreData
import SwiftUI

@MainActor
final class NutritionViewModel: ObservableObject {
    // MARK: - Inputs
    @Published var age: String = "25"
    @Published var gender: String = "Male"
    @Published var weightKg: String = "70"
    @Published var heightCm: String = "175"
    @Published var activityIndex: Int = 2
    @Published var weeklyLogs: [DailyCalorieLog] = []


    // MARK: - Food & Selections
    @Published private(set) var foodItems: [FoodItem] = []
    @Published private(set) var totalCaloriesToday: Int = 0
    @Published private(set) var maintenanceCalories: Int = 0

    private let context: NSManagedObjectContext
    private let activityFactors: [Double] = [1.2, 1.375, 1.55, 1.725, 1.9]

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        loadFoodLibrary()
        Task { await fetchSelectedForToday() }
    }

    // MARK: - FoodItem Model
    struct FoodItem: Identifiable, Hashable {
        let id = UUID()
        let name: String
        let imageName: String
        let calories: Int
        var isSelected: Bool = false
        var servingMultiplier: Double = 1.0
    }

    private func loadFoodLibrary() {
        foodItems = [
            FoodItem(name: "Grilled Chicken (100g)", imageName: "chicken", calories: 165),
            FoodItem(name: "Brown Rice (100g)", imageName: "brown_rice", calories: 120),
            FoodItem(name: "Oats (100g)", imageName: "oats", calories: 380),
            FoodItem(name: "Boiled Egg", imageName: "egg", calories: 70),
            FoodItem(name: "Banana", imageName: "banana", calories: 90),
            FoodItem(name: "Almonds (10 pcs)", imageName: "almonds", calories: 160),
            FoodItem(name: "Whey Protein (1 scoop)", imageName: "whey", calories: 120),
            FoodItem(name: "Paneer (100g)", imageName: "paneer", calories: 250),
            FoodItem(name: "Sweet Potato (100g)", imageName: "sweet_potato", calories: 90),
            FoodItem(name: "Olive Oil (1 tbsp)", imageName: "olive_oil", calories: 120)
        ]
    }

    // MARK: - Maintenance Calories
    func calculateMaintenanceCalories() {
        guard let w = Double(weightKg),
              let h = Double(heightCm),
              let a = Double(age) else {
            maintenanceCalories = 0
            return
        }
        let s = (gender == "Male") ? 5.0 : -161.0
        let bmr = 10 * w + 6.25 * h - 5 * a + s
        let factor = activityFactors[safe: activityIndex] ?? 1.55
        maintenanceCalories = Int(round(bmr * factor))
    }

    // MARK: - Toggle Food Selection
    func toggle(_ item: FoodItem) {
        Task {
            if await isSelected(item) {
                await deleteSelected(item)
            } else {
                await saveSelected(item)
            }
            await fetchSelectedForToday()
        }
    }

    private func saveSelected(_ item: FoodItem) async {
        await context.perform {
            let entity = SelectedFood(context: self.context)
            entity.id = UUID()
            entity.name = item.name
            entity.calories = Int64(Double(item.calories) * item.servingMultiplier)
            entity.date = Calendar.current.startOfDay(for: Date())
            do {
                try self.context.save()
            } catch {
                print("❌ Failed saving SelectedFood: \(error)")
                self.context.rollback()
            }
        }
    }

    private func deleteSelected(_ item: FoodItem) async {
        await context.perform {
            let request: NSFetchRequest<SelectedFood> = SelectedFood.fetchRequest()
            let today = Calendar.current.startOfDay(for: Date())
            request.predicate = NSPredicate(format: "name == %@ AND date == %@", item.name, today as CVarArg)
            request.fetchLimit = 1
            do {
                if let obj = try self.context.fetch(request).first {
                    self.context.delete(obj)
                    try self.context.save()
                }
            } catch {
                print("❌ Failed deleting SelectedFood: \(error)")
                self.context.rollback()
            }
        }
    }

    private func isSelected(_ item: FoodItem) async -> Bool {
        await context.perform {
            let request: NSFetchRequest<SelectedFood> = SelectedFood.fetchRequest()
            let today = Calendar.current.startOfDay(for: Date())
            request.predicate = NSPredicate(format: "name == %@ AND date == %@", item.name, today as CVarArg)
            request.fetchLimit = 1
            do {
                return try self.context.count(for: request) > 0
            } catch {
                print("⚠️ Error checking selected food: \(error)")
                return false
            }
        }
    }

    // MARK: - Fetch Today
    func fetchSelectedForToday() async {
        await context.perform {
            let request: NSFetchRequest<SelectedFood> = SelectedFood.fetchRequest()
            let today = Calendar.current.startOfDay(for: Date())
            request.predicate = NSPredicate(format: "date == %@", today as CVarArg)

            do {
                let selected = try self.context.fetch(request)
                let selectedNames = Set(selected.compactMap { $0.name })
                let total = selected.reduce(0) { $0 + Int($1.calories) }

                DispatchQueue.main.async {
                    for i in self.foodItems.indices {
                        self.foodItems[i].isSelected = selectedNames.contains(self.foodItems[i].name)
                    }
                    self.totalCaloriesToday = total
                }
            } catch {
                print("❌ Failed fetching SelectedFood: \(error)")
            }
        }
    }

    // MARK: - Reset
    func resetTodaySelections() {
        Task {
            await context.perform {
                let request: NSFetchRequest<NSFetchRequestResult> = SelectedFood.fetchRequest()
                let today = Calendar.current.startOfDay(for: Date())
                request.predicate = NSPredicate(format: "date == %@", today as CVarArg)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
                do {
                    try self.context.execute(deleteRequest)
                    try self.context.save()
                } catch {
                    print("❌ Failed resetting today's selections: \(error)")
                    self.context.rollback()
                }
            }
            await fetchSelectedForToday()
        }
    }
}

// MARK: - Daily Log Management
extension NutritionViewModel {
    func saveDailyLog() async {
        await context.perform {
            let today = Calendar.current.startOfDay(for: Date())
            let request: NSFetchRequest<DailyCalorieLog> = DailyCalorieLog.fetchRequest()
            request.predicate = NSPredicate(format: "date == %@", today as CVarArg)
            request.fetchLimit = 1

            do {
                let existing = try self.context.fetch(request).first
                let log = existing ?? DailyCalorieLog(context: self.context)
                log.id = existing?.id ?? UUID()
                log.date = today
                log.totalCalories = Int64(self.totalCaloriesToday)
                log.maintenanceCalories = Int64(self.maintenanceCalories)
                try self.context.save()
            } catch {
                print("❌ Failed saving daily log: \(error)")
                self.context.rollback()
            }
        }
    }

    func fetchWeeklyLogs() async -> [(date: Date, total: Int, maintenance: Int)] {
        await context.perform {
            let request: NSFetchRequest<DailyCalorieLog> = DailyCalorieLog.fetchRequest()
            let startOfWeek = Calendar.current.date(byAdding: .day, value: -6, to: Calendar.current.startOfDay(for: Date()))!
            request.predicate = NSPredicate(format: "date >= %@", startOfWeek as CVarArg)
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]

            do {
                let logs = try self.context.fetch(request)
                return logs.map { ($0.date ?? Date(), Int($0.totalCalories), Int($0.maintenanceCalories)) }
            } catch {
                print("❌ Failed fetching weekly logs: \(error)")
                return []
            }
        }
    }
}

// MARK: - Safe Subscript
fileprivate extension Array {
    subscript(safe index: Int) -> Element? {
        (0..<count).contains(index) ? self[index] : nil
    }
}
