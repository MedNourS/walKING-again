import SwiftUI
import SwiftData

@main
struct walKING_againApp: App {
	// A flag to determine if the welcome page should be shown.
	// It's initialized by checking UserDefaults. If the key "hasLaunchedBefore" is true,
	// then it's not the first launch, so we set showWelcomePage to false.
	@AppStorage("hasLaunchedBefore") private var hasLaunchedBefore: Bool = false

	var body: some Scene {
		WindowGroup {
			// Conditionally show ContentView (welcome page) or MapView
			if hasLaunchedBefore {
				// If the app has launched before, go directly to the MapView
				MapView()
			} else {
				// If it's the first launch, show the ContentView (welcome page)
				ContentView(hasLaunchedBefore: $hasLaunchedBefore)
			}
		}
		// IMPORTANT: Ensure this matches your actual SwiftData model(s)
		.modelContainer(for: WalkingData.self)
	}
}
