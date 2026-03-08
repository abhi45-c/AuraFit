//
//  PersistenceController.swift
//  AuraFit
//
//  Created by Abhirup Pal on 10/26/25.
//


import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "AICoachModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Error loading Core Data: \(error)")
            }
        }
    }
}

