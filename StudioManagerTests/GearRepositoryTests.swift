//
//  GearRepositoryTests.swift
//  StudioManagerTests
//
//  Created by Claude on 12/31/25.
//

import Testing
import CoreData
@testable import StudioManager

struct GearRepositoryTests {

    // Helper to create an in-memory context for testing
    private func makeTestContext() -> NSManagedObjectContext {
        let controller = PersistenceController(inMemory: true)
        return controller.container.viewContext
    }

    // MARK: - Fetch Tests

    @Test func fetchAllGearReturnsEmptyArrayWhenNoGear() throws {
        let context = makeTestContext()
        let repository = GearRepository(context: context)

        let gear = try repository.fetchAllGear()
        #expect(gear.isEmpty)
    }

    // MARK: - Create Tests

    @Test func createGearWithNameOnly() throws {
        let context = makeTestContext()
        let repository = GearRepository(context: context)

        let gear = try repository.createGear(name: "Test Compressor", manufacturer: nil, types: [])

        #expect(gear.name == "Test Compressor")
        #expect(gear.manufacturer == nil)
    }

    @Test func createGearWithManufacturer() throws {
        let context = makeTestContext()
        let repository = GearRepository(context: context)

        // Create a manufacturer first
        let manufacturer = Manufacturer(context: context)
        manufacturer.name = "Universal Audio"
        try context.save()

        let gear = try repository.createGear(name: "1176", manufacturer: manufacturer, types: [])

        #expect(gear.name == "1176")
        #expect(gear.manufacturer?.name == "Universal Audio")
    }

    @Test func createGearWithTypes() throws {
        let context = makeTestContext()
        let repository = GearRepository(context: context)

        // Create gear types
        let compressorType = GearType(context: context)
        compressorType.name = "Compressor"
        let outboardType = GearType(context: context)
        outboardType.name = "Outboard"
        try context.save()

        let gear = try repository.createGear(name: "LA-2A", manufacturer: nil, types: [compressorType, outboardType])

        let types = gear.gearType as? Set<GearType> ?? []
        #expect(types.count == 2)
    }

    @Test func createdGearIsPersisted() throws {
        let context = makeTestContext()
        let repository = GearRepository(context: context)

        _ = try repository.createGear(name: "Persisted Gear", manufacturer: nil, types: [])

        let fetched = try repository.fetchAllGear()
        #expect(fetched.count == 1)
        #expect(fetched.first?.name == "Persisted Gear")
    }

    // MARK: - Update Tests

    @Test func updateGearName() throws {
        let context = makeTestContext()
        let repository = GearRepository(context: context)

        let gear = try repository.createGear(name: "Original Name", manufacturer: nil, types: [])
        try repository.updateGear(gear, name: "Updated Name", manufacturer: nil, types: [])

        #expect(gear.name == "Updated Name")
    }

    @Test func updateGearManufacturer() throws {
        let context = makeTestContext()
        let repository = GearRepository(context: context)

        let gear = try repository.createGear(name: "Test Gear", manufacturer: nil, types: [])

        let manufacturer = Manufacturer(context: context)
        manufacturer.name = "New Manufacturer"
        try context.save()

        try repository.updateGear(gear, name: "Test Gear", manufacturer: manufacturer, types: [])

        #expect(gear.manufacturer?.name == "New Manufacturer")
    }

    // MARK: - Delete Tests

    @Test func deleteGearRemovesFromDatabase() throws {
        let context = makeTestContext()
        let repository = GearRepository(context: context)

        let gear = try repository.createGear(name: "To Delete", manufacturer: nil, types: [])
        #expect(try repository.fetchAllGear().count == 1)

        try repository.deleteGear(gear)
        #expect(try repository.fetchAllGear().isEmpty)
    }

    // MARK: - Control Tests

    @Test func addControlToGear() throws {
        let context = makeTestContext()
        let repository = GearRepository(context: context)

        let gear = try repository.createGear(name: "Compressor", manufacturer: nil, types: [])

        // Create a control type
        let knobType = ControlType(context: context)
        knobType.name = "Knob"
        try context.save()

        let control = try repository.addControl(to: gear, name: "Threshold", type: knobType)

        #expect(control.name == "Threshold")
        #expect(control.controlType?.name == "Knob")
        #expect(control.gearItem === gear)
    }

    @Test func deleteControl() throws {
        let context = makeTestContext()
        let repository = GearRepository(context: context)

        let gear = try repository.createGear(name: "Test Gear", manufacturer: nil, types: [])

        let controlType = ControlType(context: context)
        controlType.name = "Fader"
        try context.save()

        let control = try repository.addControl(to: gear, name: "Volume", type: controlType)
        try repository.deleteControl(control)

        let controls = gear.controls as? Set<GearControl> ?? []
        #expect(controls.isEmpty)
    }

    // MARK: - Sorting Tests

    @Test func fetchAllGearReturnsSortedByName() throws {
        let context = makeTestContext()
        let repository = GearRepository(context: context)

        _ = try repository.createGear(name: "Zebra", manufacturer: nil, types: [])
        _ = try repository.createGear(name: "Alpha", manufacturer: nil, types: [])
        _ = try repository.createGear(name: "Middle", manufacturer: nil, types: [])

        let fetched = try repository.fetchAllGear()

        #expect(fetched.count == 3)
        #expect(fetched[0].name == "Alpha")
        #expect(fetched[1].name == "Middle")
        #expect(fetched[2].name == "Zebra")
    }
}
