import CoreLocation
import Foundation
import Combine
import SwiftData
import SwiftUI

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
	private let locationManager = CLLocationManager()

	@Published var currentLocation: CLLocation?
	@Published var authorizationStatus: CLAuthorizationStatus?

	private var modelContext: ModelContext?

	func setModelContext(_ context: ModelContext) {
		self.modelContext = context
	}

	override init() {
		super.init()
		locationManager.delegate = self
		locationManager.desiredAccuracy = 10
		locationManager.distanceFilter = 2 // Save location every 10 meters

		// Request authorization - choose one:
		 locationManager.requestWhenInUseAuthorization()
		// locationManager.requestAlwaysAuthorization()

		locationManager.startUpdatingLocation()
	}

	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		self.authorizationStatus = status
		switch status {
		case .authorizedWhenInUse, .authorizedAlways:
			manager.startUpdatingLocation()
		case .denied, .restricted:
			break
		case .notDetermined:
			break
		@unknown default:
			fatalError("Unknown location authorization status")
		}
	}

	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let latestLocation = locations.last else {
			return
		}
		self.currentLocation = latestLocation
		saveLocation(latestLocation)
	}

	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("Location manager failed with error: \(error.localizedDescription)")
	}

	private func saveLocation(_ location: CLLocation) {
		guard let context = modelContext else {
			return
		}

		let newLocationEntry = 	LocationEntry(location: location)
		context.insert(newLocationEntry)

		do {
			try context.save()
		} catch {
			print("Failed to save location: \(error)")
		}
	}

	func clearSavedLocations() {
		guard let context = modelContext else {
			 return
		 }
		let fetchDescriptor = FetchDescriptor<LocationEntry>()
		do {
			let locations = try context.fetch(fetchDescriptor)
			for location in locations {
				context.delete(location)
			}
			try context.save()
			print("Cleared all saved locations.")
		} catch {
			print("Failed to clear locations: \(error)")
		}
	}
}
