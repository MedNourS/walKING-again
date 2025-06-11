//
//  walKINGApp.swift
//  walKING
//
//  Created by Chariot 4 - Ordinateur19 - User3 on 2025-06-11.
//

import SwiftUI
import SwiftData

@main
struct walKINGApp: App {
	// Configure the SwiftData model container for LocationEntry model
		var sharedModelContainer: ModelContainer = {
			// Define the schema including all your SwiftData models
			let schema = Schema([
				LocationEntry.self, // Make sure LocationEntry is included
			])
			// Configure the model storage (not in-memory for persistence)
			let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

			do {
				// Create and return the ModelContainer
				return try ModelContainer(for: schema, configurations: [modelConfiguration])
			} catch {
				// Fatal error if the container cannot be created (indicates a critical setup issue)
				fatalError("Could not create ModelContainer: \(error)")
			}
		}()

    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
