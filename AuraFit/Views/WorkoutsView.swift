//
//  WorkoutsView.swift
//  AuraFit
//
//  Created by Abhirup Pal on 10/18/25.
//

import SwiftUI

struct WorkoutCategory: Identifiable, Equatable {
    let id = UUID()
    let name: String
}

struct WorkoutsView: View {
    @State private var selectedCategory: WorkoutCategory? = nil
    @Namespace private var animation

    let workouts = [
        ("Chest", "Chest", Color.red),
        ("Back", "Back", Color.blue),
        ("Legs", "Legs", Color.green),
        ("Shoulders", "Shoulder", Color.orange),
        ("Biceps", "Bicep", Color.purple),
        ("Triceps", "Triceps", Color.cyan),
        ("Core", "Core", Color.yellow)
    ]

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            NavigationStack{
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Title
                    Text("Workout Planner")
                        .font(.largeTitle.bold())
                        .padding(.top, 30)
                        .padding(.horizontal)
                    
                    Text("Select a muscle group to explore AI-crafted workout plans.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                    
                    // Cards
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(workouts, id: \.0) { name, icon, color in
                            
                            WorkoutCardView(name: name, icon: icon, color: color)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        selectedCategory = WorkoutCategory(name: name)
                                    }
                                }
                        }
                    }
                    .padding()
                    .padding(.bottom, 80)
                }
            }
        }
            .background(Color.black.ignoresSafeArea())

            // Floating AI button
            Button(action: {
                // Future: Trigger AI workout generation
            }) {
                Label("Generate AI Plan", systemImage: "wand.and.stars")
                    .font(.headline)
                    .padding()
                    .background(LinearGradient(colors: [.green, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .shadow(color: .purple.opacity(0.5), radius: 10, x: 0, y: 6)
                    .padding()
            }
        }
        .sheet(item: $selectedCategory) { category in
            NavigationStack {
                WorkoutDetailView(category: category.name)
            }
        }

    }
}

// MARK: - Workout Card
struct WorkoutCardView: View {
    let name: String
    let icon: String
    let color: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(
                    LinearGradient(
                        colors: [color.opacity(0.7), color.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 160)
                .shadow(color: color.opacity(0.4), radius: 8, x: 0, y: 6)

            VStack(spacing: 8) {
                Image(icon)
                    .resizable()
                    .frame(width: 90,height: 90)
                    .font(.system(size: 45))
                    .foregroundColor(.white)
                Text(name)
                    .font(.title3.bold())
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    WorkoutsView()
}



