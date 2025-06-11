import SwiftUI
import SwiftData // For @Model and modelContainer

// REMOVED: The @Model WalkingData definition is no longer here.
// It is assumed to be defined in its own separate file (e.g., WalkingData.swift)
// and included in your app's target.

struct ContentView: View {
	// This binding allows ContentView to update the flag in AppStorage
	@Binding var hasLaunchedBefore: Bool

	var body: some View {
		NavigationView {
			VStack(spacing: 30) {
				Image(systemName: "figure.walk.circle.fill")
					.resizable()
					.scaledToFit()
					.frame(width: 150, height: 150)
					.foregroundColor(.green)
					.shadow(radius: 10)

				Text("Welcome to walKING!")
					.font(.largeTitle)
					.fontWeight(.bold)
					.padding(.bottom, 10)

				Text("Start tracking your walks and explore your journey on the map.")
					.font(.body)
					.multilineTextAlignment(.center)
					.foregroundColor(.gray)
					.padding(.horizontal, 40)

				// NavigationLink to your MapView
				NavigationLink(destination: MapView()) {
					Label("Start Walking", systemImage: "map.fill")
						.font(.title2)
						.padding(.vertical, 12)
						.padding(.horizontal, 30)
						.background(
							LinearGradient(gradient: Gradient(colors: [Color.green, Color.teal]), startPoint: .leading, endPoint: .trailing)
						)
						.foregroundColor(.white)
						.cornerRadius(25)
						.shadow(color: .green.opacity(0.4), radius: 10, x: 0, y: 5)
				}
				.simultaneousGesture(TapGesture().onEnded {
					// When the "Start Walking" button is tapped, set the flag to true
					hasLaunchedBefore = true
				})
			}
			.navigationTitle("walKING")
		}
		// This onAppear is for setting the flag if the user somehow closes the app
		// without tapping the button (e.g., Force Quitting).
		// For a simple welcome screen, handling it on button tap is often sufficient.
		.onAppear {
			// Optional: If you want the welcome screen to *never* show again
			// after it has *appeared* once, uncomment the line below.
			// If you only want it gone after the user taps "Start Walking", keep it commented.
			// hasLaunchedBefore = true
		}
	}
}

// MARK: - Preview Provider

#Preview {
	// For previewing ContentView, we need to pass a constant binding for hasLaunchedBefore
	ContentView(hasLaunchedBefore: .constant(false)) // Treat it as if it's the first launch for preview
		// Provide a modelContainer for preview if you use SwiftData
		// IMPORTANT: Assuming WalkingData is defined in a separate file and in the target.
		.modelContainer(for: WalkingData.self, inMemory: true)
}
