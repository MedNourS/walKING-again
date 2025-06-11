import CoreLocation
import Foundation // For ObservableObject and @Published

/// A centralized class to manage location services, including permissions and updates.
/// It conforms to `ObservableObject` to allow SwiftUI views to react to location changes.
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

	/// The underlying Core Location manager responsible for delivering location events.
	private let locationManager = CLLocationManager()

	/// Publishes the user's last known location. Views observing this property will update
	/// when a new location is received.
	@Published var currentLocation: CLLocation?

	/// Publishes the current authorization status of location services for the app.
	/// Views can use this to determine UI state (e.g., showing a "Request Location" button).
	@Published var authorizationStatus: CLAuthorizationStatus?

	/// Publishes any error encountered by the location manager.
	@Published var locationError: CLError?

	/// Initializes the LocationManager.
	/// Sets the delegate to `self` to receive location events and automatically checks
	/// and requests permission when the manager is initialized.
	override init() {
		super.init()
		locationManager.delegate = self // Assign self as the delegate
		locationManager.desiredAccuracy = kCLLocationAccuracyBest // Set desired accuracy for location data
		// You can set a distance filter if you only need updates after a certain movement
		// locationManager.distanceFilter = 10 // e.g., update every 10 meters

		// Request permission on initialization, but the actual system prompt
		// will only appear when `requestWhenInUseAuthorization()` or `requestAlwaysAuthorization()`
		// is called later, or when `startUpdatingLocation()` is called for the first time.
		// This is a good place to check initial status.
		checkAuthorizationStatus()
	}

	/// Checks the current authorization status and requests appropriate permission if needed.
	/// This method is called internally to respond to status changes.
	private func checkAuthorizationStatus() {
		switch locationManager.authorizationStatus {
		case .notDetermined:
			// If authorization status is not determined, request WhenInUse authorization.
			// This will prompt the user the first time if the app hasn't requested before.
			// Consider calling requestWhenInUseAuthorization() explicitly from a UI action
			// if you want to delay the prompt until the user explicitly needs location.
			print("Location authorization: Not Determined. Requesting When In Use.")
			// locationManager.requestWhenInUseAuthorization() // You might explicitly call this from UI
		case .authorizedWhenInUse:
			print("Location authorization: Authorized When In Use.")
			// If already authorized, you can potentially start updating location here
			// startUpdatingLocation() // Only if app logic requires immediate start
		case .authorizedAlways:
			print("Location authorization: Authorized Always.")
			// If already authorized, you can potentially start updating location here
			// startUpdatingLocation() // Only if app logic requires immediate start
		case .denied:
			print("Location authorization: Denied. User must enable in Settings.")
			// Handle this state by perhaps showing a message to the user.
		case .restricted:
			print("Location authorization: Restricted (e.g., parental controls).")
			// Handle this state appropriately.
		@unknown default:
			print("Location authorization: Unknown status.")
		}
		self.authorizationStatus = locationManager.authorizationStatus
	}

	/// Requests "When In Use" authorization for location services.
	/// This will trigger the system permission dialog if permission hasn't been granted.
	func requestWhenInUseAuthorization() {
		locationManager.requestWhenInUseAuthorization()
	}

	/// Requests "Always" authorization for location services.
	/// Use this only if your app genuinely requires background location updates.
	/// If "When In Use" is already granted, this will prompt the user for an upgrade.
	func requestAlwaysAuthorization() {
		locationManager.requestAlwaysAuthorization()
	}

	/// Starts continuously updating the user's location.
	/// Ensure you have the necessary authorization before calling this.
	func startUpdatingLocation() {
		// It's good practice to check authorization status before starting updates.
		guard let status = authorizationStatus else { return }
		if status == .authorizedWhenInUse || status == .authorizedAlways {
			locationManager.startUpdatingLocation()
			print("Started updating location.")
		} else {
			print("Cannot start updating location: Insufficient authorization status: \(status.rawValue)")
			// You might want to call requestWhenInUseAuthorization() here if not already prompted
			// locationManager.requestWhenInUseAuthorization()
		}
	}

	/// Stops location updates.
	/// Important for battery life. Call this when location data is no longer needed.
	func stopUpdatingLocation() {
		locationManager.stopUpdatingLocation()
		print("Stopped updating location.")
	}

	// MARK: - CLLocationManagerDelegate Methods

	/// Called when new location data is available.
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let latestLocation = locations.last else { return }
		self.currentLocation = latestLocation // Update the published property
		print("Location updated: \(latestLocation.coordinate.latitude), \(latestLocation.coordinate.longitude), Altitude: \(latestLocation.altitude)")
		self.locationError = nil // Clear any previous errors on successful update
	}

	/// Called when the location manager encounters an error.
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		if let clError = error as? CLError {
			self.locationError = clError // Publish the specific Core Location error
			print("Location manager failed with CLError: \(clError.localizedDescription) (Code: \(clError.errorCode))")

			// Specific handling for denied error
			if clError.code == .denied {
				print("User denied location services. Please inform the user.")
				// You could trigger a UI alert here
			}
		} else {
			print("Location manager failed with unknown error: \(error.localizedDescription)")
		}
	}

	/// Called when the app's authorization status for location services changes.
	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		self.authorizationStatus = manager.authorizationStatus // Update the published property
		print("Authorization status changed to: \(manager.authorizationStatus.rawValue)")

		// Re-evaluate what to do based on the new status
		switch manager.authorizationStatus {
		case .authorizedWhenInUse, .authorizedAlways:
			print("Authorization granted. You can now start location updates.")
			// If your app automatically starts tracking, uncomment this:
			// startUpdatingLocation()
		case .denied, .restricted:
			print("Authorization denied or restricted. Location features will be unavailable.")
			stopUpdatingLocation() // Stop if it was running and permission revoked
		case .notDetermined:
			print("Authorization not determined. Waiting for user action.")
		@unknown default:
			print("Unknown authorization status in didChangeAuthorization.")
		}
	}

	// MARK: - iOS 14+ Accuracy Authorization
	// This is optional but good for more precise control over accuracy.
	// If your app requires precise location, you should check this and potentially inform the user.
	func locationManager(_ manager: CLLocationManager, didChangeAccuracyAuthorization accuracyAuthorization: CLAccuracyAuthorization) {
		switch accuracyAuthorization {
		case .fullAccuracy:
			print("Full accuracy authorized.")
		case .reducedAccuracy:
			print("Reduced accuracy authorized.")
			// Consider informing the user that some features might be less precise.
		@unknown default:
			print("Unknown accuracy authorization.")
		}
	}
}
