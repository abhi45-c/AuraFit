//
//  WorkoutHistoryViewModel.swift
//  AuraFit
//
//  Created by Abhirup Pal on 11/24/25.
//


import SwiftUI
import CoreData

class WorkoutHistoryViewModel: ObservableObject {
    @Published var workoutSets: [WorkoutSet] = []
    
    let context = PersistenceController.shared.container.viewContext

    init() {
        fetchWorkoutSets()
    }

    func addSet(exerciseName: String, reps: Int, weight: Int) {
        let newSet = WorkoutSet(context: context)
        newSet.id = UUID()
        newSet.exerciseName = exerciseName
        newSet.reps = Int16(reps)
        newSet.weight = Int16(weight)
        newSet.date = Date()

        save()
        fetchWorkoutSets()
    }

    func fetchWorkoutSets() {
        let request = NSFetchRequest<WorkoutSet>(entityName: "WorkoutSet")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        workoutSets = (try? context.fetch(request)) ?? []
    }

    func deleteSet(_ set: WorkoutSet) {
        context.delete(set)
        save()
        fetchWorkoutSets()
    }

    private func save() {
        if context.hasChanges {
            try? context.save()
        }
    }
}
