import Foundation
import SwiftData // Import SwiftData for @Model

/// The SwiftData model for storing walking session data.
@Model
final class WalkingData {
	var timestamp: Date          // The exact time this data point was recorded
	var latitude: Double         // Latitude coordinate
	var longitude: Double        // Longitude coordinate
	var altitude: Double         // Altitude in meters

	init(timestamp: Date, latitude: Double, longitude: Double, altitude: Double) {
		self.timestamp = timestamp
		self.latitude = latitude
		self.longitude = longitude
		self.altitude = altitude
	}
}
//
//  WalkingData.swift
//  walKING
//
//  Created by Chariot 3 - Ordinateur 4- User7 on 2025-06-11.
//

