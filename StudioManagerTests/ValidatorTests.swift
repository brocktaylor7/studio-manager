//
//  ValidatorTests.swift
//  StudioManagerTests
//
//  Created by Claude on 12/31/25.
//

import Testing
@testable import StudioManager

struct ValidatorTests {

    // MARK: - Name Validation Tests

    @Test func emptyNameIsInvalid() {
        let result = Validators.validateName("", entityType: "Test")
        #expect(!result.isValid)
        #expect(result.errors.contains("Test name cannot be empty"))
    }

    @Test func whitespaceOnlyNameIsInvalid() {
        let result = Validators.validateName("   ", entityType: "Test")
        #expect(!result.isValid)
        #expect(result.errors.contains("Test name cannot be empty"))
    }

    @Test func validNamePasses() {
        let result = Validators.validateName("Valid Name", entityType: "Test")
        #expect(result.isValid)
        #expect(result.errors.isEmpty)
    }

    @Test func nameTooLongIsInvalid() {
        let longName = String(repeating: "a", count: 101)
        let result = Validators.validateName(longName, entityType: "Test", maxLength: 100)
        #expect(!result.isValid)
        #expect(result.errors.contains("Test name must be 100 characters or less"))
    }

    @Test func nameAtMaxLengthIsValid() {
        let maxName = String(repeating: "a", count: 100)
        let result = Validators.validateName(maxName, entityType: "Test", maxLength: 100)
        #expect(result.isValid)
    }

    @Test func customMaxLengthIsRespected() {
        let name = String(repeating: "a", count: 51)
        let result = Validators.validateName(name, entityType: "Test", maxLength: 50)
        #expect(!result.isValid)
    }

    // MARK: - Gear Item Validation

    @Test func validateGearItemWithValidName() {
        let result = Validators.validateGearItem(name: "LA-2A Compressor")
        #expect(result.isValid)
    }

    @Test func validateGearItemWithEmptyName() {
        let result = Validators.validateGearItem(name: "")
        #expect(!result.isValid)
    }

    // MARK: - Manufacturer Validation

    @Test func validateManufacturerWithValidName() {
        let result = Validators.validateManufacturer(name: "Universal Audio")
        #expect(result.isValid)
    }

    @Test func validateManufacturerWithEmptyName() {
        let result = Validators.validateManufacturer(name: "")
        #expect(!result.isValid)
    }

    // MARK: - Preset Validation

    @Test func validatePresetWithValidName() {
        let result = Validators.validatePreset(name: "Vocal Recording Session")
        #expect(result.isValid)
    }

    @Test func validatePresetWithEmptyName() {
        let result = Validators.validatePreset(name: "")
        #expect(!result.isValid)
    }

    // MARK: - Scenario Validation

    @Test func validateScenarioWithValidName() {
        let result = Validators.validateScenario(name: "Drum Recording")
        #expect(result.isValid)
    }

    @Test func validateScenarioWithEmptyName() {
        let result = Validators.validateScenario(name: "")
        #expect(!result.isValid)
    }

    // MARK: - Control Value Validation

    @Test func validateControlValueWithValidValue() {
        let result = Validators.validateControlValue("7")
        #expect(result.isValid)
    }

    @Test func validateControlValueWithEmptyValue() {
        let result = Validators.validateControlValue("")
        #expect(!result.isValid)
    }

    @Test func validateControlValueTooLong() {
        let longValue = String(repeating: "a", count: 51)
        let result = Validators.validateControlValue(longValue)
        #expect(!result.isValid)
    }

    @Test func validateControlValueAtMaxLength() {
        let maxValue = String(repeating: "a", count: 50)
        let result = Validators.validateControlValue(maxValue)
        #expect(result.isValid)
    }

    // MARK: - ValidationResult Tests

    @Test func validResultIsValid() {
        let result = ValidationResult.valid
        #expect(result.isValid)
        #expect(result.errors.isEmpty)
    }

    @Test func invalidResultWithArrayOfErrors() {
        let result = ValidationResult.invalid(["Error 1", "Error 2"])
        #expect(!result.isValid)
        #expect(result.errors.count == 2)
    }

    @Test func invalidResultWithSingleError() {
        let result = ValidationResult.invalid("Single error")
        #expect(!result.isValid)
        #expect(result.errors.count == 1)
        #expect(result.errors.first == "Single error")
    }
}
