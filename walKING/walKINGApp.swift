//
//  walKINGApp.swift
//  walKING
//
//  Created by Chariot 4 - Ordinateur19 - User3 on 2025-06-11.
//

import SwiftUI

@main
struct walKINGApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
