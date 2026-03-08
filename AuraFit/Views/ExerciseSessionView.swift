//
//  ExerciseSessionView.swift
//  AuraFit
//
//  Created by Abhirup Pal on 10/19/25.
//


import SwiftUI

struct ExerciseSessionView: View {
    let exerciseName: String
    
    
    @State private var selectedReps = 10
    @State private var selectedWeight = 20
    @State private var restTime = 90
    @State private var isResting = false
    @State private var timer: Timer?
    
    // progress workout
    @EnvironmentObject var historyVM: WorkoutHistoryViewModel

    var body: some View {
        VStack(spacing: 30) {
            Text(exerciseName)
                .font(.largeTitle.bold())
                .padding(.top, 40)
                .foregroundStyle(.white)
            
            VStack(spacing: 20) {
                
                Image("Bicep")
                    .resizable()
                    .frame(width: 150, height: 150)
                // Reps picker
                HStack {
                    Text("Reps")
                        .font(.headline)
                        .foregroundStyle(.gray)
                        .padding()
    
                    
                    Picker("Reps", selection: $selectedReps) {
                        ForEach(1...30, id: \.self) { Text("\($0)") }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 100)
                }
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                
                // Weight picker
                HStack {
                    Text("Weight (kg)")
                        .font(.headline)
                        .foregroundStyle(.gray)
                        .padding()
                    
                    Picker("Weight", selection: $selectedWeight) {
                        ForEach(1...150, id: \.self) { Text("\($0)") }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 100)
                }
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
            
            // Rest timer display
            if isResting {
                VStack(spacing: 10) {
                    Text("Rest Time")
                        .font(.headline)
                        .foregroundStyle(.gray)
                    Text("\(restTime)s")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(restTime > 0 ? .white : .green)
                    
                    if restTime == 0 {
                        Text("GO! 💪")
                            .font(.title.bold())
                            .foregroundStyle(.green)
                    }
                }
            }
            
            // Start button
            Button(action: startOrStopSession) {
                Label(isResting ? "Stop" : "Start", systemImage: isResting ? "stop.circle.fill" : "play.circle.fill")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(LinearGradient(colors: [.purple, .blue],
                                               startPoint: .leading,
                                               endPoint: .trailing),
                                in: RoundedRectangle(cornerRadius: 14))
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .background(Color.black.ignoresSafeArea())
        .onDisappear { timer?.invalidate() }
    }
    
    private func startOrStopSession() {
        if isResting {
            timer?.invalidate()
            restTime = 90
            isResting = false
        } else {
            isResting = true
            restTime = 90
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if restTime > 0 {
                    restTime -= 1
                } else {
                    // SAVE the workout set when timer ends
                    historyVM.addSet(
                        exerciseName: exerciseName,
                        reps: selectedReps,
                        weight: selectedWeight
                    )

                    timer?.invalidate()
                }
            }
        }
    }

}

#Preview {
    ExerciseSessionView(exerciseName: "Bicep Curl")
}
