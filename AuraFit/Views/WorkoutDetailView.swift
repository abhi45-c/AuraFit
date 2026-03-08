//
//  WorkoutDetailView.swift
//  AuraFit
//
//  Created by Abhirup Pal on 10/19/25.
//


import SwiftUI

struct WorkoutDetailView: View {
    let category: String
    
    // Predefined exercises per category
    var exercises: [String] {
        switch category {
        case "Chest":
            return ["Bench Press", "Incline Dumbbell Press", "Chest Fly", "Push-ups", "Cable Crossover"]
        case "Back":
            return ["Pull-ups", "Deadlift", "Seated Row", "Lat Pulldown", "Barbell Row"]
        case "Legs":
            return ["Squats", "Lunges", "Leg Press", "Calf Raises", "Hamstring Curl"]
        case "Shoulders":
            return ["Overhead Press", "Lateral Raise", "Front Raise", "Face Pulls", "Reverse Fly"]
        case "Biceps":
            return ["Bicep Curl", "Hammer Curl", "Preacher Curl", "Concentration Curl"]
        case "Triceps":
            return ["Cable Pushdowns", "Tricep Dips", "Overhead Extensions", "Skull Crusher"]
        case "Core":
            return ["Plank", "Crunches", "Leg Raises", "Russian Twist", "Mountain Climbers"]
        default:
            return ["Full Body Circuit", "Stretching Routine", "Mobility Flow"]
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                Text(category)
                    .font(.largeTitle.bold())
                    .padding(.top, 30)
                    .foregroundStyle(.white)
                
                Text("AI-Optimized Plan for \(category)")
                    .font(.headline)
                    .foregroundStyle(.gray)
                
                // List of exercises
                ForEach(exercises, id: \.self) { exercise in
                    NavigationLink(destination: ExerciseSessionView(exerciseName: exercise)) {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(exercise)
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                Text("3 sets · 12 reps · 60s rest")
                                    .font(.subheadline)
                                    .foregroundStyle(.gray)
                            }
                            Spacer()
                            Image(systemName: "chevron.right.circle.fill")
                                .foregroundStyle(.purple)
                                .imageScale(.large)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(colors: [.purple.opacity(0.3), .blue.opacity(0.3)],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing),
                            in: RoundedRectangle(cornerRadius: 16)
                        )
                    }
                }
            }
            .padding()
        }
        .background(Color.black.ignoresSafeArea())
    }
}

#Preview {
    NavigationView {
        WorkoutDetailView(category: "Biceps")
    }
}
