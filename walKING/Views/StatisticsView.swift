import SwiftUI
import SwiftData // Required if you will query WalkingData here

/// Placeholder view for the "Statistics" page.
/// This view will display various statistics about the user's walks.
struct StatisticsView: View {
	// You'll likely use @Query here to fetch WalkingData for statistics later
	// @Query private var walkingData: [WalkingData]

	var body: some View {
		NavigationView {
			VStack {
				Image(systemName: "chart.bar.fill")
					.resizable()
					.scaledToFit()
					.frame(width: 100, height: 100)
					.foregroundColor(.orange)
					.padding()
				Text("Your Walking Statistics")
					.font(.largeTitle)
					.fontWeight(.bold)
				Text("Detailed summary of your walks will appear here!")
					.font(.body)
					.foregroundColor(.gray)
					.multilineTextAlignment(.center)
					.padding()
				// Example of where you might use WalkingData if you fetch it:
				// if let someData = walkingData.first {
				//     Text("First Walk: \(someData.timestamp.formatted())")
				// }
			}
			.navigationTitle("Statistics")
			.navigationBarTitleDisplayMode(.inline)
		}
	}
}

#Preview {
	StatisticsView()
		// Provide a modelContainer for preview if you will query WalkingData here
		// IMPORTANT: Assuming WalkingData is defined in a separate file and in the target.
		.modelContainer(for: WalkingData.self, inMemory: true)
}
