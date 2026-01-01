//
//  PresetRepositoryTests.swift
//  StudioManagerTests
//
//  Created by Claude on 12/31/25.
//

import Testing
import CoreData
@testable import StudioManager

struct PresetRepositoryTests {

    // Helper to create an in-memory context for testing
    private func makeTestContext() -> NSManagedObjectContext {
        let controller = PersistenceController(inMemory: true)
        return controller.container.viewContext
    }

    // MARK: - Scenario Tests

    @Test func fetchAllScenariosReturnsEmptyArrayWhenNone() throws {
        let context = makeTestContext()
        let repository = PresetRepository(context: context)

        let scenarios = try repository.fetchAllScenarios()
        #expect(scenarios.isEmpty)
    }

    @Test func createScenario() throws {
        let context = makeTestContext()
        let repository = PresetRepository(context: context)

        let scenario = try repository.createScenario(name: "Vocal Recording")

        #expect(scenario.name == "Vocal Recording")
    }

    @Test func createdScenarioIsPersisted() throws {
        let context = makeTestContext()
        let repository = PresetRepository(context: context)

        _ = try repository.createScenario(name: "Test Scenario")

        let fetched = try repository.fetchAllScenarios()
        #expect(fetched.count == 1)
        #expect(fetched.first?.name == "Test Scenario")
    }

    @Test func updateScenarioName() throws {
        let context = makeTestContext()
        let repository = PresetRepository(context: context)

        let scenario = try repository.createScenario(name: "Original")
        try repository.updateScenario(scenario, name: "Updated")

        #expect(scenario.name == "Updated")
    }

    @Test func deleteScenario() throws {
        let context = makeTestContext()
        let repository = PresetRepository(context: context)

        let scenario = try repository.createScenario(name: "To Delete")
        #expect(try repository.fetchAllScenarios().count == 1)

        try repository.deleteScenario(scenario)
        #expect(try repository.fetchAllScenarios().isEmpty)
    }

    @Test func scenariosAreSortedByName() throws {
        let context = makeTestContext()
        let repository = PresetRepository(context: context)

        _ = try repository.createScenario(name: "Zebra Session")
        _ = try repository.createScenario(name: "Alpha Session")

        let fetched = try repository.fetchAllScenarios()
        #expect(fetched[0].name == "Alpha Session")
        #expect(fetched[1].name == "Zebra Session")
    }

    // MARK: - Preset Tests

    @Test func createPresetInScenario() throws {
        let context = makeTestContext()
        let repository = PresetRepository(context: context)

        let scenario = try repository.createScenario(name: "Test Scenario")
        let preset = try repository.createPreset(name: "Lead Vocal", in: scenario)

        #expect(preset.name == "Lead Vocal")
        #expect(preset.scenario === scenario)
    }

    @Test func updatePresetName() throws {
        let context = makeTestContext()
        let repository = PresetRepository(context: context)

        let scenario = try repository.createScenario(name: "Test")
        let preset = try repository.createPreset(name: "Original", in: scenario)

        try repository.updatePreset(preset, name: "Updated")

        #expect(preset.name == "Updated")
    }

    @Test func deletePreset() throws {
        let context = makeTestContext()
        let repository = PresetRepository(context: context)

        let scenario = try repository.createScenario(name: "Test")
        let preset = try repository.createPreset(name: "To Delete", in: scenario)

        try repository.deletePreset(preset)

        let presets = scenario.presets as? Set<Preset> ?? []
        #expect(presets.isEmpty)
    }

    @Test func deletingScenarioRemovesScenario() throws {
        let context = makeTestContext()
        let repository = PresetRepository(context: context)

        let scenario = try repository.createScenario(name: "Test Scenario")
        _ = try repository.createPreset(name: "Preset 1", in: scenario)
        _ = try repository.createPreset(name: "Preset 2", in: scenario)

        try repository.deleteScenario(scenario)

        // Verify scenario is deleted
        #expect(try repository.fetchAllScenarios().isEmpty)

        // Note: Whether presets cascade delete depends on Core Data model configuration
        // The delete rule should be set to "Cascade" on Scenario->Presets relationship
    }

    // MARK: - Setting Tests

    @Test func addSettingToPreset() throws {
        let context = makeTestContext()
        let repository = PresetRepository(context: context)

        // Setup
        let scenario = try repository.createScenario(name: "Test")
        let preset = try repository.createPreset(name: "Test Preset", in: scenario)

        let gear = GearItem(context: context)
        gear.name = "Compressor"

        let controlType = ControlType(context: context)
        controlType.name = "Knob"

        let control = GearControl(context: context)
        control.name = "Threshold"
        control.controlType = controlType
        control.gearItem = gear

        try context.save()

        // Test
        let setting = try repository.addSetting(to: preset, gearItem: gear, control: control, value: "-10dB")

        #expect(setting.controlValue == "-10dB")
        #expect(setting.preset === preset)
        #expect(setting.gearItem === gear)
        #expect(setting.control === control)
    }

    @Test func updateSettingValue() throws {
        let context = makeTestContext()
        let repository = PresetRepository(context: context)

        // Setup
        let scenario = try repository.createScenario(name: "Test")
        let preset = try repository.createPreset(name: "Test Preset", in: scenario)

        let gear = GearItem(context: context)
        gear.name = "EQ"

        let controlType = ControlType(context: context)
        controlType.name = "Knob"

        let control = GearControl(context: context)
        control.name = "Frequency"
        control.controlType = controlType
        control.gearItem = gear

        try context.save()

        let setting = try repository.addSetting(to: preset, gearItem: gear, control: control, value: "1kHz")

        // Test
        try repository.updateSetting(setting, value: "2kHz")

        #expect(setting.controlValue == "2kHz")
    }

    @Test func deleteSetting() throws {
        let context = makeTestContext()
        let repository = PresetRepository(context: context)

        // Setup
        let scenario = try repository.createScenario(name: "Test")
        let preset = try repository.createPreset(name: "Test Preset", in: scenario)

        let gear = GearItem(context: context)
        gear.name = "Compressor"

        let controlType = ControlType(context: context)
        controlType.name = "Knob"

        let control = GearControl(context: context)
        control.name = "Ratio"
        control.controlType = controlType
        control.gearItem = gear

        try context.save()

        let setting = try repository.addSetting(to: preset, gearItem: gear, control: control, value: "4:1")

        // Test
        try repository.deleteSetting(setting)

        let settings = preset.settings as? Set<Setting> ?? []
        #expect(settings.isEmpty)
    }

    @Test func deletingPresetDeletesSettings() throws {
        let context = makeTestContext()
        let repository = PresetRepository(context: context)

        // Setup
        let scenario = try repository.createScenario(name: "Test")
        let preset = try repository.createPreset(name: "Test Preset", in: scenario)

        let gear = GearItem(context: context)
        gear.name = "Compressor"

        let controlType = ControlType(context: context)
        controlType.name = "Knob"

        let control = GearControl(context: context)
        control.name = "Threshold"
        control.controlType = controlType
        control.gearItem = gear

        try context.save()

        _ = try repository.addSetting(to: preset, gearItem: gear, control: control, value: "Test")

        // Test
        try repository.deletePreset(preset)

        let settingRequest = Setting.fetchRequest()
        let settings = try context.fetch(settingRequest)
        #expect(settings.isEmpty)
    }
}
