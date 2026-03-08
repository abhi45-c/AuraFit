//
//  AICoachViewModel.swift
//  AuraFit
//
//  Created by Abhirup Pal on 10/24/25.
//

import SwiftUI
import CoreData

class AICoachViewModel: ObservableObject {
    @Published var profile: AIProfile?
    @Published var todayPlan: AIPlan?
    
    private let context = PersistenceController.shared.container.viewContext
    
    // MARK: - Load or Save Profile
    func loadProfile() {
        let request = AIProfile.fetchRequest()
        if let existing = try? context.fetch(request).first {
            profile = existing
        }
    }
    
    func saveProfile(goal: String, bodyType: String, weight: Double, height: Double) {
        let newProfile = AIProfile(context: context)
        newProfile.id = UUID()
        newProfile.goal = goal
        newProfile.bodyType = bodyType
        newProfile.weight = weight
        newProfile.height = height
        newProfile.createdAt = Date()
        
        try? context.save()
        profile = newProfile
        generateTodayPlan()
    }
    
    // MARK: - Generate Daily Plan
    func generateTodayPlan() {
        guard let profile = profile else { return }
        
        let plan = AIPlan(context: context)
        plan.id = UUID()
        plan.date = Date()
        
        // Automatically pick muscle group based on weekday
        let muscleGroup = pickMuscle(for: profile.goal ?? "")
        plan.muscleFocus = muscleGroup
        plan.workoutPlan = sampleWorkout(for: muscleGroup)
        
        // Diet and Motivation
        plan.dietPlan = formatDiet(for: profile.goal ?? "")
        plan.motivation = sampleMotivation()
        
        try? context.save()
        todayPlan = plan
    }
    
    func resetProfile() {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = AIProfile.fetchRequest()
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(batchDeleteRequest)
                try context.save()
                
                DispatchQueue.main.async {
                    self.profile = nil
                    self.todayPlan = nil
                }
                
                print("✅ Profile reset successful.")
            } catch {
                print("❌ Error resetting profile: \(error.localizedDescription)")
            }
        }
    
    // MARK: - Workout & Diet Logic
    private func pickMuscle(for goal: String) -> String {
        // Day-based rotation
        let weekday = Calendar.current.component(.weekday, from: Date())
        let adjustedDay = weekday == 1 ? 7 : weekday - 1 // Sunday → 7
        
        var muscleGroup = ""
        switch adjustedDay {
        case 1: muscleGroup = "Chest & Triceps"
        case 2: muscleGroup = "Back & Biceps"
        case 3: muscleGroup = "Legs & Shoulders"
        case 4: muscleGroup = "Chest & Triceps"
        case 5: muscleGroup = "Back & Biceps"
        case 6: muscleGroup = "Legs & Shoulders"
        default: muscleGroup = "Active Rest / Cardio"
        }
        
        // Add cardio for Build Muscle or Lose Fat goals
        if goal == "Build Muscle" || goal == "Lose Fat" {
            if [2, 4, 6].contains(adjustedDay) {
                muscleGroup += " + 20 min Cardio"
            }
        }
        return muscleGroup
    }
    
    private func sampleWorkout(for muscleGroup: String) -> String {
        switch muscleGroup {
        case _ where muscleGroup.contains("Chest & Triceps"):
            return "Bench Press (3 sets), Incline Dumbbell Press(3 sets), Cable Flys (3 sets), Push-ups(3 sets), Tricep Pushdowns (3 sets), Tricep Overhead Extensions (3 sets)"
        case _ where muscleGroup.contains("Back & Biceps"):
            return "Pull-ups(3 sets), Barbell Rows(3 sets),Lat Pulldowns(3 sets), Dumbbell Curls(3 sets), Prechair Curls(3 sets), Hammar Curls(3 sets)"
        case _ where muscleGroup.contains("Legs & Shoulders"):
            return "Squats(3 sets), Deadlifts(3 sets), Lunges(3 sets), Shoulder Press(3 sets), Calf Raises(3 sets), Lateral Raises(3 sets), Front Raises(3 sets)"
        case _ where muscleGroup.contains("Cardio"):
            return "Running, Jump Rope, Burpees, Jump Squats"
        default:
            return "Full Body Circuit: Push-ups, Squats, Plank, Jumping Jacks"
        }
    }
    
    private func formatDiet(for goal: String) -> String {
        let diet = sampleDiet(for: goal)
        return """
        🍳 Breakfast: \(diet["Breakfast"] ?? "-")
        🍚 Lunch: \(diet["Lunch"] ?? "-")
        🌙 Dinner: \(diet["Dinner"] ?? "-")
        """
    }
    
    private func sampleDiet(for goal: String) -> [String: String] {
        switch goal {
        case "Build Muscle":
            return [
                "Breakfast": """
                Protein: 4 whole eggs + 2 egg whites or 1 scoop whey isolate,
                Carbs: 70g oats + cream of rice + wholegrain toast,
                Fats: 10g almond butter + avocado,
                Add-on: 1 fruit (banana or berries) — rich in antioxidants & fiber
                """,
                
                "Lunch": """
                Protein: 150g grilled chicken breast or fish,
                Carbs: 100g brown rice or quinoa,
                Veggies: Broccoli, spinach, or green beans,
                Fats: 1 tbsp olive oil or handful of nuts
                """,
                
                "Dinner": """
                Protein: 150g paneer or tofu,
                Carbs: Sweet potatoes or brown rice,
                Veggies: Mixed salad with olive oil dressing,
                Supplements: Casein shake (optional)
                """
            ]
            
        case "Lose Fat":
            return [
                "Breakfast": """
                Protein: 3 egg whites + 1 scoop whey isolate,
                Carbs: Oats with water or almond milk,
                Fats: 1 tsp peanut butter,
                Add-on: Green tea + 1 apple
                """,
                
                "Lunch": """
                Protein: 120g grilled fish/chicken,
                Carbs: Small portion of brown rice or sweet potato,
                Veggies: Large portion of sautéed or steamed greens,
                Fats: ½ avocado
                """,
                
                "Dinner": """
                Protein: Boiled eggs or tofu stir-fry,
                Veggies: Soup + mixed salad,
                Fats: Olive oil drizzle or 5 almonds,
                Supplements: Herbal tea before bed,
                """
            ]
            
        case "Get Stronger":
            return [
                "Breakfast": """
                Protein: Whey protein smoothie with milk + 1 banana,
                Carbs: 2 slices wholegrain toast + oats,
                Fats: 1 tbsp peanut butter,
                Add-on: Black coffee
                """,
                
                "Lunch": """
                Protein: 150g paneer or chicken,
                Carbs: 150g rice + lentils + spinach,
                Fats: 1 tbsp ghee or olive oil,
                Add-on: Greek yogurt
                """,
                
                "Dinner": """
                Protein: Grilled fish or tofu,
                Carbs: Brown rice or quinoa,
                Veggies: Broccoli + salad,
                Supplements: Protein shake post workout
                """
            ]
            
        default:
            return [
                "Breakfast": "Fruits + yogurt + oats",
                "Lunch": "Rice + dal + veggies",
                "Dinner": "Soup + salad + tofu"
            ]
        }
    }

    
    private func sampleMotivation() -> String {
        [
            "Push yourself — no one else will do it for you.",
            "One step closer to your best self!",
            "Discipline beats motivation.",
            "You don’t get what you wish for — you get what you work for.",
            "You’re stronger than your excuses.",
            "Consistency creates results — not luck."
        ].randomElement()!
    }
}
