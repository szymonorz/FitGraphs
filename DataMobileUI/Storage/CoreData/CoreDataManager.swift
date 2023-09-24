//
//  CoreDataManager.swift
//  DataMobileUI
//
//  Created by b on 09/09/2023.
//

import CoreData

struct CoreDataManager {
    static let shared = CoreDataManager()
    
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "DataMobileUI")
        
        // inMemory storage
        if let storageDescription = container.persistentStoreDescriptions.first {
            storageDescription.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unable to configure CoreData storage \(error), \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
