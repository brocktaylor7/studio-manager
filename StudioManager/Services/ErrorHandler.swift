//
//  ErrorHandler.swift
//  StudioManager
//
//  Created by Claude on 12/31/25.
//

import SwiftUI
import Combine

/// Defines the types of errors that can occur in the application
enum AppError: LocalizedError {
    case saveFailed(underlying: Error)
    case deleteFailed(underlying: Error)
    case fetchFailed(underlying: Error)
    case validationFailed(reasons: [String])
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "Failed to save changes"
        case .deleteFailed:
            return "Failed to delete item"
        case .fetchFailed:
            return "Failed to load data"
        case .validationFailed(let reasons):
            return reasons.joined(separator: "\n")
        case .unknown:
            return "An unexpected error occurred"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .saveFailed, .deleteFailed:
            return "Please try again. If the problem persists, restart the app."
        case .fetchFailed:
            return "Pull to refresh or restart the app."
        case .validationFailed:
            return "Please correct the highlighted fields."
        case .unknown:
            return "Please restart the app and try again."
        }
    }
}

/// Centralized error handling service for the application
@MainActor
final class ErrorHandler: ObservableObject {
    /// Shared singleton instance
    static let shared = ErrorHandler()

    /// The current error being displayed
    @Published var currentError: AppError?

    /// Whether to show the error alert
    @Published var showError = false

    private init() {}

    /// Handle an error by storing it and triggering the alert
    /// - Parameters:
    ///   - error: The error that occurred
    ///   - context: A description of where the error occurred (for logging)
    func handle(_ error: Error, context: String = "") {
        #if DEBUG
        print("Error in \(context): \(error.localizedDescription)")
        #endif

        if let appError = error as? AppError {
            currentError = appError
        } else {
            currentError = .unknown(error)
        }
        showError = true
    }

    /// Clear the current error state
    func clear() {
        currentError = nil
        showError = false
    }
}
