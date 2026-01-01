//
//  Repository.swift
//  StudioManager
//
//  Created by Claude on 12/31/25.
//

import CoreData

/// Base protocol for all repository implementations
protocol Repository {
    associatedtype Entity: NSManagedObject

    var context: NSManagedObjectContext { get }

    func fetchAll(sortedBy: [NSSortDescriptor]) throws -> [Entity]
    func create() -> Entity
    func save() throws
    func delete(_ entity: Entity) throws
}

extension Repository {
    /// Saves the context if there are pending changes
    func save() throws {
        guard context.hasChanges else { return }
        try context.save()
    }

    /// Deletes an entity and saves the context
    func delete(_ entity: Entity) throws {
        context.delete(entity)
        try save()
    }
}
