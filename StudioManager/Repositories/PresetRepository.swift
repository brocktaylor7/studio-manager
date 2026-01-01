//
//  PresetRepository.swift
//  StudioManager
//
//  Created by Claude on 12/31/25.
//

import CoreData

/// Protocol defining preset-related data operations
protocol PresetRepositoryProtocol {
    func fetchAllScenarios() throws -> [Scenario]
    func createScenario(name: String) throws -> Scenario
    func updateScenario(_ scenario: Scenario, name: String) throws
    func deleteScenario(_ scenario: Scenario) throws
    func createPreset(name: String, in scenario: Scenario) throws -> Preset
    func updatePreset(_ preset: Preset, name: String) throws
    func deletePreset(_ preset: Preset) throws
    func addSetting(to preset: Preset, gearItem: GearItem, control: GearControl, value: String) throws -> Setting
    func updateSetting(_ setting: Setting, value: String) throws
    func deleteSetting(_ setting: Setting) throws
}

/// Repository for managing Scenario, Preset, and Setting entities
final class PresetRepository: PresetRepositoryProtocol {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Scenario Operations

    /// Fetches all scenarios sorted by name
    func fetchAllScenarios() throws -> [Scenario] {
        let request = Scenario.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Scenario.name, ascending: true)]
        return try context.fetch(request)
    }

    /// Creates a new scenario with the specified name
    @discardableResult
    func createScenario(name: String) throws -> Scenario {
        let scenario = Scenario(context: context)
        scenario.name = name
        try save()
        return scenario
    }

    /// Updates a scenario's name
    func updateScenario(_ scenario: Scenario, name: String) throws {
        scenario.name = name
        try save()
    }

    /// Deletes a scenario and all its presets
    func deleteScenario(_ scenario: Scenario) throws {
        context.delete(scenario)
        try save()
    }

    // MARK: - Preset Operations

    /// Creates a new preset within a scenario
    @discardableResult
    func createPreset(name: String, in scenario: Scenario) throws -> Preset {
        let preset = Preset(context: context)
        preset.name = name
        preset.scenario = scenario
        try save()
        return preset
    }

    /// Updates a preset's name
    func updatePreset(_ preset: Preset, name: String) throws {
        preset.name = name
        try save()
    }

    /// Deletes a preset and all its settings
    func deletePreset(_ preset: Preset) throws {
        context.delete(preset)
        try save()
    }

    // MARK: - Setting Operations

    /// Adds a setting to a preset
    @discardableResult
    func addSetting(to preset: Preset, gearItem: GearItem, control: GearControl, value: String) throws -> Setting {
        let setting = Setting(context: context)
        setting.controlValue = value
        setting.preset = preset
        setting.gearItem = gearItem
        setting.control = control
        try save()
        return setting
    }

    /// Updates a setting's value
    func updateSetting(_ setting: Setting, value: String) throws {
        setting.controlValue = value
        try save()
    }

    /// Deletes a setting
    func deleteSetting(_ setting: Setting) throws {
        context.delete(setting)
        try save()
    }

    private func save() throws {
        guard context.hasChanges else { return }
        try context.save()
    }
}
