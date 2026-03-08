//
//  NutritionView.swift
//  AuraFit
//
//  Created by Abhirup Pal on 10/18/25.
//

import SwiftUI

struct NutritionView: View {
    @StateObject var viewModel = NutritionViewModel()
    
    @State private var gender = "Male"
    @State private var weight = ""
    @State private var height = ""
    @State private var age = ""
    @State private var activityLevel = "Moderate"
    @State private var maintenanceCalories: Int?
    
    @State private var selectedMeal = "Breakfast"
    @State private var selectedFoods: [String: Double] = [:] // [FoodName: ServingMultiplier]
    
    private let meals = ["Breakfast", "Lunch", "Dinner"]
    private let activityOptions = ["Sedentary", "Light", "Moderate", "Active"]
    
    struct FoodItem: Identifiable {
        let id = UUID()
        let name: String
        let calories: Int
        let image: String
        let meal: String
    }
    
    private let foodItems = [
        // Breakfast
        FoodItem(name: "Oats", calories: 180, image: "🥣", meal: "Breakfast"),
        FoodItem(name: "2 Boiled Eggs", calories: 150, image: "🥚", meal: "Breakfast"),
        FoodItem(name: "Avocado Toast", calories: 200, image: "🥑", meal: "Breakfast"),
        FoodItem(name: "Banana", calories: 90, image: "🍌", meal: "Breakfast"),
        
        // Lunch
        FoodItem(name: "Grilled Chicken", calories: 250, image: "🥩", meal: "Lunch"),
        FoodItem(name: "Brown Rice", calories: 220, image: "🍚", meal: "Lunch"),
        FoodItem(name: "2 Boiled Eggs", calories: 150, image: "🥚", meal: "Lunch"),
        FoodItem(name: "Mixed Veggies", calories: 100, image: "🥕", meal: "Lunch"),
        FoodItem(name: "Paneer", calories: 270, image: "🧀", meal: "Lunch"),
        
        // Dinner
        FoodItem(name: "Fish Curry", calories: 300, image: "🐟", meal: "Dinner"),
        FoodItem(name: "Roti", calories: 96, image: "🫓", meal: "Dinner"),
        FoodItem(name: "Salad", calories: 90, image: "🥗", meal: "Dinner"),
        FoodItem(name: " 2 Boiled Eggs", calories: 150, image: "🥚", meal: "Dinner"),
        FoodItem(name: "Protein Shake", calories: 160, image: "🥤", meal: "Dinner")
    ]
    
    private var totalCalories: Int {
        foodItems.reduce(0) { total, item in
            total + Int(Double(item.calories) * (selectedFoods[item.name] ?? 0))
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Title
                Text("Nutrition Planner 🍽️")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 50)
                    .shadow(radius: 20)
                
                // Maintenance Calorie Calculator
                VStack(spacing: 15) {
                    Text(" Maintenance Calorie Calculator 🔢")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Picker("Gender", selection: $gender) {
                        Text("Male").tag("Male")
                        Text("Female").tag("Female")
                    }
                    .pickerStyle(.segmented)
                    
                    HStack(spacing: 15) {
                        TextField("Weight (kg)", text: $weight)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                        TextField("Height (cm)", text: $height)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                    
                    Picker("Activity", selection: $activityLevel) {
                        ForEach(activityOptions, id: \.self) { Text($0) }
                    }
                    .pickerStyle(.menu)
                    
                    Button {
                        calculateCalories()
                    } label: {
                        Label("Calculate Maintenance 🔥", systemImage: "flame.fill")
                            .font(.title3.bold())
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(Color.green.opacity(0.8))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .shadow(radius: 10)
                    }
                    
                    if let calories = maintenanceCalories {
                        Text("Maintenance: \(calories) kcal/day")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.top, 5)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding(.horizontal)
                
                
                // Meal Segments
                Picker("Meal", selection: $selectedMeal) {
                    ForEach(meals, id: \.self) { Text($0) }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                
                // Food Selection
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(foodItems.filter { $0.meal == selectedMeal }) { item in
                        VStack(spacing: 10) {
                            HStack(spacing: 15) {
                                Text(item.image)
                                    .font(.largeTitle)
                                VStack(alignment: .leading) {
                                    Text(item.name)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text("\(item.calories) kcal per serving")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Button {
                                    toggleFood(item)
                                } label: {
                                    Image(systemName: selectedFoods[item.name] != nil ? "checkmark.circle.fill" : "circle")
                                        .font(.title2)
                                        .foregroundColor(selectedFoods[item.name] != nil ? .green : .gray)
                                }
                            }
                            
                            // Serving Size Selector
                            if selectedFoods[item.name] != nil {
                                HStack {
                                    Text("Serving Size:")
                                        .foregroundColor(.white.opacity(0.8))
                                    Picker("", selection: Binding(
                                        get: { selectedFoods[item.name] ?? 1.0 },
                                        set: { selectedFoods[item.name] = $0 }
                                    )) {
                                        Text("1x").tag(1.0)
                                        Text("2x").tag(2.0)
                                        Text("3x").tag(3.0)
                                        Text("4x").tag(4.0)
                                    }
                                    .pickerStyle(.segmented)
                                    .frame(width: 180)
                                }
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                        .shadow(radius: 8)
                    }
                }
                .padding(.horizontal)
                
                // Calorie Progress Ring
                if let maintenance = maintenanceCalories, maintenance > 0 {
                    VStack {
                        Text("Calorie Progress")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        ZStack {
                            Circle()
                                .stroke(lineWidth: 20)
                                .opacity(0.2)
                                .foregroundColor(.gray)
                            
                            Circle()
                                .trim(from: 0.0, to: min(CGFloat(Double(totalCalories) / Double(maintenance)), 1.0))
                                .stroke(
                                    AngularGradient(
                                        gradient: Gradient(colors: [.green, .yellow, .orange, .red]),
                                        center: .center
                                    ),
                                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut, value: totalCalories)
                            
                            VStack {
                                Text("\(totalCalories)")
                                    .font(.system(size: 38, weight: .bold))
                                    .foregroundColor(.white)
                                Text("of \(maintenance) kcal")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .frame(width: 200, height: 200)
                        .padding(.top, 10)
                    }
                }
                
                // Save Today's Intake Button
                Button {
                    Task {
                        await viewModel.fetchSelectedForToday()
                        await viewModel.saveDailyLog()
                    }
                } label: {
                    Label("Save Today’s Intake 📅", systemImage: "calendar.badge.plus")
                        .font(.title3.bold())
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(Color.teal.gradient)
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .shadow(color:.black.opacity(0.4), radius: 10, x: 0, y: 4)
                }
                .padding(.horizontal)
                .padding(.top, 10)

                Spacer(minLength: 100)
                
            }
        }
        .background(
            LinearGradient(
                colors: [.black, .green.opacity(0.7), .black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
    
    private func calculateCalories() {
        guard let w = Double(weight),
              let h = Double(height),
              let a = Double(age) else { return }
        
        var bmr: Double = 0
        if gender == "Male" {
            bmr = 88.36 + (13.4 * w) + (4.8 * h) - (5.7 * a)
        } else {
            bmr = 447.6 + (9.2 * w) + (3.1 * h) - (4.3 * a)
        }
        
        let multiplier: Double
        switch activityLevel {
        case "Sedentary": multiplier = 1.2
        case "Light": multiplier = 1.375
        case "Moderate": multiplier = 1.55
        case "Active": multiplier = 1.725
        default: multiplier = 1.55
        }
        
        maintenanceCalories = Int(bmr * multiplier)
    }
    
    private func toggleFood(_ item: FoodItem) {
        if selectedFoods[item.name] != nil {
            selectedFoods.removeValue(forKey: item.name)
        } else {
            selectedFoods[item.name] = 1.0
        }
    }
}

#Preview {
    NutritionView()
}
