//
//  HeslthManager.swift
//  AuraFit
//
//  Created by Abhirup Pal on 11/23/25.
//

import HealthKit

class HealthManager: ObservableObject {
    let healthStore = HKHealthStore()
    
    @Published var caloriesBurned: Double = 0
    @Published var minutesTrained: Double = 0
    @Published var workoutsCompleted: Int = 0
    
    init() {
        requestAuthorization()
    }
    
    func requestAuthorization() {
        let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let exerciseType = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!
        let workoutType = HKObjectType.workoutType()
        
        let readTypes: Set = [calorieType, exerciseType, workoutType]
        
        healthStore.requestAuthorization(toShare: [], read: readTypes) { success, error in
            if success {
                self.fetchData()
            }
        }
    }
    
    func fetchData() {
        fetchActiveCalories()
        fetchExerciseMinutes()
        fetchWorkouts()
    }
    
    // MARK: - Calories
    func fetchActiveCalories() {
        let type = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let predicate = HKQuery.predicateForSamples(today: true)
        
        let query = HKStatisticsQuery(quantityType: type,
                                      quantitySamplePredicate: predicate,
                                      options: .cumulativeSum) { _, stats, _ in
            DispatchQueue.main.async {
                self.caloriesBurned = stats?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
            }
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Exercise Minutes
    func fetchExerciseMinutes() {
        let type = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!
        let predicate = HKQuery.predicateForSamples(today: true)
        
        let query = HKStatisticsQuery(quantityType: type,
                                      quantitySamplePredicate: predicate,
                                      options: .cumulativeSum) { _, stats, _ in
            DispatchQueue.main.async {
                self.minutesTrained = stats?
                    .sumQuantity()?
                    .doubleValue(for: HKUnit.minute()) ?? 0
            }
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Workouts
    func fetchWorkouts() {
        let type = HKObjectType.workoutType()
        let predicate = HKQuery.predicateForSamples(today: true)
        
        let query = HKSampleQuery(sampleType: type,
                                  predicate: predicate,
                                  limit: HKObjectQueryNoLimit,
                                  sortDescriptors: nil) { _, samples, _ in
            DispatchQueue.main.async {
                self.workoutsCompleted = samples?.count ?? 0
            }
        }
        
        healthStore.execute(query)
    }
}

extension HKQuery {
    /// Today only
    static func predicateForSamples(today: Bool) -> NSPredicate {
        let start = Calendar.current.startOfDay(for: Date())
        let end = Date()
        return HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
    }
}

