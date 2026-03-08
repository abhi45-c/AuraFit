//
//  AuraFitApp.swift
//  AuraFit
//
//  Created by Abhirup Pal on 10/18/25.
//

import SwiftUI

@main
struct AuraFitApp: App {
    @StateObject private var nutritionViewModel = NutritionViewModel()
   @StateObject private var workoutHistoryVM = WorkoutHistoryViewModel()   // ← NEW
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(nutritionViewModel) // Shared globally
                .environmentObject(workoutHistoryVM)  // ← Inject globally
                .preferredColorScheme(.dark)
        }
    }
}
