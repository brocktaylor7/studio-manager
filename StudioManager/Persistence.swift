//
//  Persistence.swift
//  StudioManager
//
//  Created by Brock Taylor on 9/8/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Create sample data for previews
        let sampleManufacturer = Manufacturer(context: viewContext)
        sampleManufacturer.name = "Warm Audio"
        
        let sampleGearType = GearType(context: viewContext)
        sampleGearType.name = "Microphone"
        
        for i in 0..<5 {
            let newItem = GearItem(context: viewContext)
            newItem.name = "Sample Gear \(i)"
            newItem.manufacturer = sampleManufacturer
            newItem.gearType = [sampleGearType] as NSSet
        }
        do {
            try viewContext.save()
        } catch {
            // Preview context - just log the error
            print("Preview context save error: \(error.localizedDescription)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    /// Stores any error that occurred during persistent store loading
    private(set) var loadError: Error?

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "StudioManager")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        // Enable automatic migration
        if let description = container.persistentStoreDescriptions.first {
            description.shouldMigrateStoreAutomatically = true
            description.shouldInferMappingModelAutomatically = true
            description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        }

        container.loadPersistentStores { [self] (storeDescription, error) in
            if let error = error as NSError? {
                // Log the error instead of crashing
                // Typical reasons for an error here include:
                // * The parent directory does not exist, cannot be created, or disallows writing.
                // * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                // * The device is out of space.
                // * The store could not be migrated to the current model version.
                print("Core Data error: \(error), \(error.userInfo)")

                // Note: In a production app, you might want to:
                // - Show a user-facing error dialog
                // - Attempt recovery (e.g., delete and recreate the store)
                // - Report to analytics
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
