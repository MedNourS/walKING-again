import SwiftUI

/// Placeholder view for the "Settings" page.
struct SettingsView: View {
	var body: some View {
		NavigationView {
			VStack {
				Image(systemName: "gearshape.fill")
					.resizable()
					.scaledToFit()
					.frame(width: 100, height: 100)
					.foregroundColor(.gray)
					.padding()
				Text("App Settings")
					.font(.largeTitle)
					.fontWeight(.bold)
				Text("Customize your walKING experience.")
					.font(.body)
					.foregroundColor(.gray)
					.multilineTextAlignment(.center)
					.padding()
				// Add actual settings options here later, e.g.,
				// Toggle(isOn: .constant(true)) { Text("Enable Notifications") }
			}
			.navigationTitle("Settings")
			.navigationBarTitleDisplayMode(.inline)
		}
	}
}

#Preview {
	SettingsView()
}
