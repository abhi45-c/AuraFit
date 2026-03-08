//
//  AddMuscleEntryView.swift
//  AuraFit
//
//  Created by Abhirup Pal on 11/25/25.
//
import SwiftUI

struct AddMuscleEntryView: View {
    @ObservedObject var vm: MuscleProgressViewModel
    
    @State private var muscle = "Chest"
    @State private var weight: Double = 20
    
    let muscles = [
        "Chest", "Back", "Legs", "Biceps", "Triceps", "Shoulders"
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            
            // ------------------------------------------------------------
            // HEADER
            // ------------------------------------------------------------
            Text("Add Muscle Progress")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
                .padding(.top, 10)
            
            // ------------------------------------------------------------
            // MUSCLE SELECTOR
            // ------------------------------------------------------------
            VStack(alignment: .leading, spacing: 12) {
                Text("Muscle Group")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(muscles, id: \.self) { item in
                            Button {
                                withAnimation(.spring()) {
                                    muscle = item
                                }
                            } label: {
                                Text(item)
                                    .font(.headline)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 20)
                                    .background(
                                        LinearGradient(
                                            colors: muscle == item
                                            ? [.blue, .purple]
                                            : [.gray.opacity(0.3), .gray.opacity(0.4)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .cornerRadius(20)
                                    .shadow(radius: muscle == item ? 10 : 2)
                            }
                        }
                    }
                }
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            

            // ------------------------------------------------------------
            // WEIGHT SELECTION SECTION
            // ------------------------------------------------------------
            VStack(alignment: .leading, spacing: 16) {
                Text("Weight Used (kg)")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                
                HStack {
                    Text("\(Int(weight)) kg")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Stepper("", value: $weight, in: 5...200, step: 1)
                        .labelsHidden()
                }
                
                Slider(value: $weight, in: 5...200, step: 1)
                    .tint(.purple)
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            
            Spacer()
            
            // ------------------------------------------------------------
            // SAVE BUTTON
            // ------------------------------------------------------------
            Button {
                vm.addProgress(muscleGroup: muscle, weight: weight)
            } label: {
                Text("Save Entry")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .foregroundColor(.white)
                    .shadow(color: .purple.opacity(0.5), radius: 8)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [.black, .gray.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
}
