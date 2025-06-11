import SwiftUI
import MapKit // For the Map view and MKCoordinateRegion
import CoreLocation // For CLAuthorizationStatus and CLLocation
import SwiftData // For @Environment(\.modelContext) and WalkingData

// MARK: - WalkingData Model (Placeholder for Preview)
// IMPORTANT: In a real app, this SwiftData model should ideally be in its own dedicated file (e.g., WalkingData.swift).
// It is included here temporarily only to ensure the #Preview block can compile without a 'Cannot find WalkingData in scope' error.
// If you already have WalkingData defined in a separate file and added to your target, you can remove this @Model struct from here.


/// This is the main view responsible for displaying the map and handling walking tracking.
/// It now uses a TabView to include Stats, Map, and Settings pages.
struct MapView: View {
	// LocationManager is shared across the tabs that need it
	@StateObject private var locationManager = LocationManager()

	var body: some View {
		TabView {
			// MARK: - Stats Page
			StatsView()
				.tabItem {
					Label("Stats", systemImage: "chart.bar.fill")
				}

			// MARK: - Map Page (Original MapView content)
			MapContentPage(locationManager: locationManager) // Pass locationManager to the MapContentPage
				.tabItem {
					Label("Map", systemImage: "map.fill")
				}

			// MARK: - Settings Page
			SettingsView()
				.tabItem {
					Label("Settings", systemImage: "gearshape.fill")
				}
		}
		// No .navigationTitle or .navigationBarHidden here, as TabView manages its own top bar or content
	}
}

// MARK: - MapContentPage (Encapsulates the original MapView logic)
/// This struct holds the content for the "Map" tab.
struct MapContentPage: View {
	@ObservedObject var locationManager: LocationManager // Use ObservedObject since it's passed from parent
	@Environment(\.modelContext) private var modelContext // Accessible here

	@State private var mapRegion = MKCoordinateRegion(
		center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default to San Francisco
		span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
	)

	@State private var isTracking = false
	@State private var showMessageBox = false
	@State private var messageBoxText = ""

	var body: some View {
		VStack {
			// MARK: - App Header
			Text("Walking Tracker")
				.font(.largeTitle)
				.fontWeight(.bold)
				.padding(.bottom, 10)

			// MARK: - Map Display Section
			mapSection()

			// MARK: - Location Info Section
			locationInfoSection()

			// MARK: - Action Buttons Section
			actionButtonsSection()

			Spacer()
		}
		.onAppear {
			handleOnAppearLocationSetup()
		}
		.onDisappear {
			if isTracking {
				locationManager.stopUpdatingLocation()
				isTracking = false
			}
		}
		.sheet(isPresented: $showMessageBox) {
			MessageBoxView(message: messageBoxText, isShowing: $showMessageBox)
		}
	}

	// MARK: - Subviews / View Builders
	@ViewBuilder
	private func mapSection() -> some View {
		Map(coordinateRegion: $mapRegion, showsUserLocation: true, userTrackingMode: .constant(.follow))
			.frame(height: 350)
			.cornerRadius(15)
			.shadow(radius: 5)
			.padding(.horizontal)
			.onChange(of: locationManager.currentLocation) { newLocation in
				if isTracking, let newLocation = newLocation {
					mapRegion.center = newLocation.coordinate
				}
			}
	}

	@ViewBuilder
	private func locationInfoSection() -> some View {
		VStack(spacing: 5) {
			Text("Current Location:")
				.font(.headline)

			if let location = locationManager.currentLocation {
				Text("Lat: \(location.coordinate.latitude, specifier: "%.6f"), Lon: \(location.coordinate.longitude, specifier: "%.6f")")
				Text("Altitude: \(location.altitude, specifier: "%.2f") m")
					.font(.caption)
					.foregroundColor(.gray)
				Text("Speed: \(location.speed >= 0 ? location.speed : 0, specifier: "%.2f") m/s")
					.font(.caption)
					.foregroundColor(.gray)
			} else {
				Text("Acquiring location...")
					.foregroundColor(.secondary)
			}

			if let status = locationManager.authorizationStatus {
				Text("Status: \(status.description)")
					.font(.subheadline)
					.padding(.top, 5)
					.foregroundColor(status.color)
			}

			if let error = locationManager.locationError {
				Text("Error: \(error.localizedDescription)")
					.foregroundColor(.red)
					.font(.caption)
					.padding(.top, 5)
			}
		}
		.padding(.horizontal)
		.padding(.top, 10)
	}

	@ViewBuilder
	private func actionButtonsSection() -> some View {
		HStack(spacing: 15) {
			Button(action: requestPermission) {
				Label("Request Permission", systemImage: "hand.raised.fill")
			}
			.buttonStyle(.borderedProminent)
			.tint(.blue)
			.disabled(locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways)

			Button(action: toggleTracking) {
				Label(isTracking ? "Stop Walking" : "Start Walking", systemImage: isTracking ? "stop.fill" : "figure.walk")
			}
			.buttonStyle(.borderedProminent)
			.tint(isTracking ? .red : .green)
			.disabled(locationManager.authorizationStatus != .authorizedWhenInUse && locationManager.authorizationStatus != .authorizedAlways)
		}
		.padding(.horizontal)
		.padding(.top, 10)
	}

	// MARK: - Helper Methods
	private func handleOnAppearLocationSetup() {
		switch locationManager.authorizationStatus {
		case .authorizedWhenInUse, .authorizedAlways:
			print("MapContentPage: Location authorized on appear. Starting updates if tracking.")
			if isTracking {
				locationManager.startUpdatingLocation()
			}
		case .notDetermined:
			print("MapContentPage: Location not determined on appear. Requesting WhenInUse.")
			locationManager.requestWhenInUseAuthorization()
		case .denied, .restricted:
			messageBoxText = "Location access is required for tracking. Please enable it in Settings > Privacy & Security > Location Services."
			showMessageBox = true
			isTracking = false
		case .none:
			print("MapContentPage: Authorization status is none. Waiting for update.")
		@unknown default:
			print("MapContentPage: Unknown authorization status on appear.")
		}
	}

	private func requestPermission() {
		switch locationManager.authorizationStatus {
		case .notDetermined:
			locationManager.requestWhenInUseAuthorization()
		case .denied, .restricted:
			messageBoxText = "Location access is denied or restricted. Please go to Settings > Privacy & Security > Location Services and enable it for this app."
			showMessageBox = true
		default:
			break
		}
	}

	private func toggleTracking() {
		if isTracking {
			locationManager.stopUpdatingLocation()
			isTracking = false
			print("Tracking stopped.")
		} else {
			guard locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways else {
				messageBoxText = "Cannot start tracking. Location access is not authorized. Please grant permission."
				showMessageBox = true
				return
			}
			locationManager.startUpdatingLocation()
			isTracking = true
			print("Tracking started.")
			// saveWalkingData() // Example: Save immediately when tracking starts
		}
	}

	private func saveWalkingData() {
		if let location = locationManager.currentLocation {
			let newWalkingData = WalkingData(
				timestamp: Date(),
				latitude: location.coordinate.latitude,
				longitude: location.coordinate.longitude,
				altitude: location.altitude
			)
			modelContext.insert(newWalkingData)
			do {
				try modelContext.save()
				print("Saved walking data: \(newWalkingData)")
			} catch {
				print("Failed to save walking data: \(error.localizedDescription)")
			}
		}
	}
}

// MARK: - Placeholder Views for Tabs

/// Placeholder view for the "Stats" page.
struct StatsView: View {
	// You'll likely use @Query here to fetch WalkingData for statistics
	// @Query private var walkingData: [WalkingData]

	var body: some View {
		NavigationView {
			VStack {
				Image(systemName: "chart.pie.fill")
					.resizable()
					.scaledToFit()
					.frame(width: 100, height: 100)
					.foregroundColor(.orange)
					.padding()
				Text("Your Walking Stats")
					.font(.largeTitle)
					.fontWeight(.bold)
				Text("Coming soon: Detailed insights into your walks!")
					.font(.body)
					.foregroundColor(.gray)
					.multilineTextAlignment(.center)
					.padding()
				// Add actual stats display here later, e.g.,
				// Text("Total Walks: \(walkingData.count)")
			}
			.navigationTitle("Stats")
			.navigationBarTitleDisplayMode(.inline)
		}
	}
}

/// Placeholder view for the "Settings" page.

// MARK: - Helper Extensions (Remain unchanged)

/// Extension to provide a user-friendly description for `CLAuthorizationStatus`.
extension CLAuthorizationStatus: CustomStringConvertible {
	public var description: String {
		switch self {
		case .notDetermined: return "Not Determined"
		case .restricted: return "Restricted"
		case .denied: return "Denied"
		case .authorizedAlways: return "Authorized Always"
		case .authorizedWhenInUse: return "Authorized When In Use"
		@unknown default: return "Unknown"
		}
	}

	/// Provides a color hint for the status.
	var color: Color {
		switch self {
		case .authorizedWhenInUse, .authorizedAlways: return .green
		case .denied, .restricted: return .red
		case .notDetermined: return .orange
		@unknown default: return .gray
		}
	}
}

/// A simple custom message box view (instead of using alert()).
struct MessageBoxView: View {
	let message: String
	@Binding var isShowing: Bool

	var body: some View {
		VStack {
			Text("Information")
				.font(.headline)
				.padding()
			Text(message)
				.font(.body)
				.multilineTextAlignment(.center)
				.padding(.horizontal)
			Button("OK") {
				isShowing = false
			}
			.buttonStyle(.borderedProminent)
			.padding()
		}
	}
}

// MARK: - Preview Provider (Updated to reflect the new TabView structure)

#Preview {
	MapView()
		// Provide a modelContainer for preview if you use SwiftData
		// IMPORTANT: Assuming WalkingData is defined in a separate file and in the target.
		.modelContainer(for: WalkingData.self, inMemory: true)
}
