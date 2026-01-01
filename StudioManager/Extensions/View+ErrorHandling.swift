//
//  View+ErrorHandling.swift
//  StudioManager
//
//  Created by Claude on 12/31/25.
//

import SwiftUI

/// ViewModifier that adds error alert handling to a view
struct ErrorAlertModifier: ViewModifier {
    @ObservedObject var errorHandler: ErrorHandler

    func body(content: Content) -> some View {
        content
            .alert("Error", isPresented: $errorHandler.showError) {
                Button("OK") {
                    errorHandler.clear()
                }
            } message: {
                if let error = errorHandler.currentError {
                    VStack {
                        Text(error.localizedDescription)
                        if let recovery = error.recoverySuggestion {
                            Text(recovery)
                                .font(.caption)
                        }
                    }
                }
            }
    }
}

extension View {
    /// Adds error handling alert capability to the view
    /// - Parameter handler: The ErrorHandler instance to observe (defaults to shared instance)
    /// - Returns: A view with error alert handling
    func withErrorHandling(_ handler: ErrorHandler = .shared) -> some View {
        modifier(ErrorAlertModifier(errorHandler: handler))
    }
}
