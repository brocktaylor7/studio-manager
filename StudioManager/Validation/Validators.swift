//
//  Validators.swift
//  StudioManager
//
//  Created by Claude on 12/31/25.
//

import Foundation

/// Result of a validation check
struct ValidationResult {
    let isValid: Bool
    let errors: [String]

    /// A successful validation result
    static let valid = ValidationResult(isValid: true, errors: [])

    /// Creates an invalid result with the specified errors
    static func invalid(_ errors: [String]) -> ValidationResult {
        ValidationResult(isValid: false, errors: errors)
    }

    /// Creates an invalid result with a single error
    static func invalid(_ error: String) -> ValidationResult {
        ValidationResult(isValid: false, errors: [error])
    }
}

/// Collection of validation functions for the application
enum Validators {
    /// Validates a name field
    /// - Parameters:
    ///   - name: The name to validate
    ///   - entityType: The type of entity (for error messages)
    ///   - maxLength: Maximum allowed length (default 100)
    /// - Returns: Validation result
    static func validateName(_ name: String, entityType: String, maxLength: Int = 100) -> ValidationResult {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        var errors: [String] = []

        if trimmed.isEmpty {
            errors.append("\(entityType) name cannot be empty")
        }

        if trimmed.count > maxLength {
            errors.append("\(entityType) name must be \(maxLength) characters or less")
        }

        return errors.isEmpty ? .valid : .invalid(errors)
    }

    /// Validates a gear item name
    static func validateGearItem(name: String) -> ValidationResult {
        validateName(name, entityType: "Gear item")
    }

    /// Validates a manufacturer name
    static func validateManufacturer(name: String) -> ValidationResult {
        validateName(name, entityType: "Manufacturer")
    }

    /// Validates a gear type name
    static func validateGearType(name: String) -> ValidationResult {
        validateName(name, entityType: "Gear type")
    }

    /// Validates a control type name
    static func validateControlType(name: String) -> ValidationResult {
        validateName(name, entityType: "Control type")
    }

    /// Validates a control name
    static func validateControl(name: String) -> ValidationResult {
        validateName(name, entityType: "Control")
    }

    /// Validates a preset name
    static func validatePreset(name: String) -> ValidationResult {
        validateName(name, entityType: "Preset")
    }

    /// Validates a scenario name
    static func validateScenario(name: String) -> ValidationResult {
        validateName(name, entityType: "Scenario")
    }

    /// Validates a control value (setting)
    static func validateControlValue(_ value: String) -> ValidationResult {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            return .invalid("Control value cannot be empty")
        }

        if trimmed.count > 50 {
            return .invalid("Control value must be 50 characters or less")
        }

        return .valid
    }
}
