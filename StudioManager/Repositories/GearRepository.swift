//
//  GearRepository.swift
//  StudioManager
//
//  Created by Claude on 12/31/25.
//

import CoreData

/// Protocol defining gear-related data operations
protocol GearRepositoryProtocol {
    func fetchAllGear() throws -> [GearItem]
    func createGear(name: String, manufacturer: Manufacturer?, types: Set<GearType>) throws -> GearItem
    func updateGear(_ gear: GearItem, name: String, manufacturer: Manufacturer?, types: Set<GearType>) throws
    func deleteGear(_ gear: GearItem) throws
    func addControl(to gear: GearItem, name: String, type: ControlType) throws -> GearControl
    func deleteControl(_ control: GearControl) throws
}

/// Repository for managing GearItem entities
final class GearRepository: GearRepositoryProtocol {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    /// Fetches all gear items sorted by name
    func fetchAllGear() throws -> [GearItem] {
        let request = GearItem.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \GearItem.name, ascending: true)]
        return try context.fetch(request)
    }

    /// Creates a new gear item with the specified properties
    @discardableResult
    func createGear(name: String, manufacturer: Manufacturer?, types: Set<GearType>) throws -> GearItem {
        let gear = GearItem(context: context)
        gear.name = name
        gear.manufacturer = manufacturer
        gear.gearType = types as NSSet
        try save()
        return gear
    }

    /// Updates an existing gear item with new values
    func updateGear(_ gear: GearItem, name: String, manufacturer: Manufacturer?, types: Set<GearType>) throws {
        gear.name = name
        gear.manufacturer = manufacturer
        gear.gearType = types as NSSet
        try save()
    }

    /// Deletes a gear item
    func deleteGear(_ gear: GearItem) throws {
        context.delete(gear)
        try save()
    }

    /// Adds a control to a gear item
    @discardableResult
    func addControl(to gear: GearItem, name: String, type: ControlType) throws -> GearControl {
        let control = GearControl(context: context)
        control.name = name
        control.controlType = type
        control.gearItem = gear
        try save()
        return control
    }

    /// Deletes a control from a gear item
    func deleteControl(_ control: GearControl) throws {
        context.delete(control)
        try save()
    }

    private func save() throws {
        guard context.hasChanges else { return }
        try context.save()
    }
}
