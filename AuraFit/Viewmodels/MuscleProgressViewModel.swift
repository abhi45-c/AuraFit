//
//  MuscleProgressViewModel.swift
//  AuraFit
//
//  Created by Abhirup Pal on 11/25/25.
//


import SwiftUI
import CoreData

class MuscleProgressViewModel: ObservableObject {
    
    @Published var entries: [MuscleProgress] = []
    
    private let context = PersistenceController.shared.container.viewContext
    
    init() {
        context.automaticallyMergesChangesFromParent = true
        fetchProgress()
    }
    
    // MARK: - Fetch Data
    func fetchProgress() {
        let req: NSFetchRequest<MuscleProgress> = MuscleProgress.fetchRequest()
        req.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: true)
        ]
        
        do {
            entries = try context.fetch(req)
        } catch {
            print("❌ Fetch Error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Add New Entry
    func addProgress(muscleGroup: String, weight: Double) {
        let entry = MuscleProgress(context: context)
        entry.id = UUID()
        entry.muscleGroup = muscleGroup
        entry.weight = weight
        entry.date = Date()
        
        save()
    }
    
    // MARK: - Delete Entry
    func deleteEntry(_ entry: MuscleProgress) {
        context.delete(entry)
        save()
    }
    
    // MARK: - Update Entry
    func updateEntry(_ entry: MuscleProgress, weight: Double) {
        entry.weight = weight
        entry.date = Date()
        save()
    }
    
    // MARK: - Save to Core Data
    func save() {
        do {
            try context.save()
            fetchProgress()
        } catch {
            print("❌ Save Error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Group by Muscle for Chart
    var groupedByMuscle: [String: [MuscleProgress]] {
        Dictionary(
            grouping: entries,
            by: { $0.muscleGroup ?? "Unknown" }
        )
    }
}
