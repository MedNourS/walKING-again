//
//  LocationEntry.swift
//  walKING
//
//  Created by Chariot 3 - Ordinateur 4- User7 on 2025-06-11.
//

import Foundation
import SwiftData
import CoreLocation

// Define the SwiftData model for a saved location point
@Model
final class LocationEntry {
	var latitude: Double
	var longitude: Double
	var timestamp: Date

	init(latitude: Double, longitude: Double, timestamp: Date) {
		self.latitude = latitude
		self.longitude = longitude
		self.timestamp = timestamp
	}

	// Convenience initializer from CLLocation
	convenience init(location: CLLocation) {
		self.init(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, timestamp: location.timestamp)
	}

	// Computed property to get CLLocationCoordinate2D
	var coordinate: CLLocationCoordinate2D {
		CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
	}
}
