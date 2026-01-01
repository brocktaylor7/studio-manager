//
//  ErrorHandlerTests.swift
//  StudioManagerTests
//
//  Created by Claude on 12/31/25.
//

import Foundation
import Testing
@testable import StudioManager

struct ErrorHandlerTests {

    // MARK: - AppError Tests

    @Test func appErrorSaveFailedDescription() {
        let underlyingError = NSError(domain: "test", code: 1)
        let error = AppError.saveFailed(underlying: underlyingError)

        #expect(error.errorDescription == "Failed to save changes")
        #expect(error.recoverySuggestion != nil)
    }

    @Test func appErrorDeleteFailedDescription() {
        let underlyingError = NSError(domain: "test", code: 1)
        let error = AppError.deleteFailed(underlying: underlyingError)

        #expect(error.errorDescription == "Failed to delete item")
    }

    @Test func appErrorFetchFailedDescription() {
        let underlyingError = NSError(domain: "test", code: 1)
        let error = AppError.fetchFailed(underlying: underlyingError)

        #expect(error.errorDescription == "Failed to load data")
    }

    @Test func appErrorValidationFailedDescription() {
        let error = AppError.validationFailed(reasons: ["Name is required", "Value too long"])

        #expect(error.errorDescription == "Name is required\nValue too long")
    }

    @Test func appErrorUnknownDescription() {
        let underlyingError = NSError(domain: "test", code: 1)
        let error = AppError.unknown(underlyingError)

        #expect(error.errorDescription == "An unexpected error occurred")
    }

    // MARK: - Recovery Suggestions

    @Test func saveFailedHasRecoverySuggestion() {
        let error = AppError.saveFailed(underlying: NSError(domain: "test", code: 1))
        #expect(error.recoverySuggestion?.contains("try again") == true)
    }

    @Test func deleteFailedHasRecoverySuggestion() {
        let error = AppError.deleteFailed(underlying: NSError(domain: "test", code: 1))
        #expect(error.recoverySuggestion?.contains("try again") == true)
    }

    @Test func fetchFailedHasRecoverySuggestion() {
        let error = AppError.fetchFailed(underlying: NSError(domain: "test", code: 1))
        #expect(error.recoverySuggestion?.contains("refresh") == true)
    }

    @Test func validationFailedHasRecoverySuggestion() {
        let error = AppError.validationFailed(reasons: ["Error"])
        #expect(error.recoverySuggestion?.contains("correct") == true)
    }

    @Test func unknownHasRecoverySuggestion() {
        let error = AppError.unknown(NSError(domain: "test", code: 1))
        #expect(error.recoverySuggestion?.contains("restart") == true)
    }

    // MARK: - ErrorHandler Tests

    @Test @MainActor func errorHandlerStartsWithNoError() {
        let handler = ErrorHandler.shared

        // Clear any existing state
        handler.clear()

        #expect(handler.currentError == nil)
        #expect(handler.showError == false)
    }

    @Test @MainActor func errorHandlerHandlesError() {
        let handler = ErrorHandler.shared
        handler.clear()

        let testError = NSError(domain: "test", code: 42)
        handler.handle(testError, context: "Test context")

        #expect(handler.currentError != nil)
        #expect(handler.showError == true)
    }

    @Test @MainActor func errorHandlerHandlesAppError() {
        let handler = ErrorHandler.shared
        handler.clear()

        let appError = AppError.saveFailed(underlying: NSError(domain: "test", code: 1))
        handler.handle(appError, context: "Test")

        if case .saveFailed = handler.currentError {
            // Expected
        } else {
            Issue.record("Expected saveFailed error")
        }
    }

    @Test @MainActor func errorHandlerClearsError() {
        let handler = ErrorHandler.shared

        let testError = NSError(domain: "test", code: 1)
        handler.handle(testError)

        #expect(handler.showError == true)

        handler.clear()

        #expect(handler.currentError == nil)
        #expect(handler.showError == false)
    }

    @Test @MainActor func errorHandlerWrapsUnknownError() {
        let handler = ErrorHandler.shared
        handler.clear()

        let customError = NSError(domain: "custom", code: 999)
        handler.handle(customError)

        if case .unknown = handler.currentError {
            // Expected - unknown errors are wrapped
        } else {
            Issue.record("Expected unknown error wrapper")
        }
    }
}
