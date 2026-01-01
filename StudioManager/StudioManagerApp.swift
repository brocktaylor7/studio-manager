//
//  StudioManagerApp.swift
//  StudioManager
//
//  Created by Brock Taylor on 9/8/25.
//

import SwiftUI

@main
struct StudioManagerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .withErrorHandling()
        }
    }
}
