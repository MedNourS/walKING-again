// MapViewModel.swift
// Refactored from MapView.swift for clarity and testability

import Foundation
import CoreLocation
import CoreData

struct GridCell: Hashable, Codable, Identifiable {
    let x: Int
    let y: Int
	var id: String { "\(x)_\(y)" }
}

struct ExploredCellVisit: Hashable, Codable {
    let cell: GridCell
    let timestamp: Date
}

// Core Data entity for persistence
extension ExploredCellVisit {
    init(entity: ExploredCellVisitEntity) {
        self.cell = GridCell(x: Int(entity.x), y: Int(entity.y))
        self.timestamp = entity.timestamp ?? Date()
    }
}

class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var exploredCells: Set<GridCell> = []
    @Published var cellVisitHistory: [GridCell: [Date]] = [:]
    public let cellSize: Double = 0.0005
    public var center: CLLocationCoordinate2D?
    private let locationManager: CLLocationManager?
    private let context: NSManagedObjectContext
    private let enableLocation: Bool

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext, enableLocation: Bool = true) {
        self.context = context
        self.enableLocation = enableLocation
		//if enableLocation {
				//    self.locationManager = CLLocationManager()
				//} else {
				//    self.locationManager = nil
				//}
		self.locationManager = nil
        super.init()
        loadData()
        //if enableLocation, let locationManager = locationManager {
        //    locationManager.delegate = self
        //    locationManager.requestAlwaysAuthorization()
        //    #if os(iOS)
        //    locationManager.allowsBackgroundLocationUpdates = true
        //    #endif
        //    locationManager.pausesLocationUpdatesAutomatically = false
        //    locationManager.startUpdatingLocation()
        //}
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        if center == nil {
            center = loc.coordinate
        }
        updateExplored(for: loc.coordinate)
    }

    func simulateVisit(x: Int, y: Int) {
        // For preview/testing: simulate a visit to a cell
        let cell = GridCell(x: x, y: y)
        exploredCells.insert(cell)
        let now = Date()
        if cellVisitHistory[cell] != nil {
            cellVisitHistory[cell]?.append(now)
        } else {
            cellVisitHistory[cell] = [now]
        }
        saveVisit(cell: cell, timestamp: now)
    }

    private func updateExplored(for coordinate: CLLocationCoordinate2D) {
        guard let center = center else { return }
        let dx = Int(((coordinate.latitude - center.latitude) / cellSize).rounded())
        let dy = Int(((coordinate.longitude - center.longitude) / cellSize).rounded())
        let cell = GridCell(x: dx, y: dy)
        exploredCells.insert(cell)
        let now = Date()
        if cellVisitHistory[cell] != nil {
            cellVisitHistory[cell]?.append(now)
        } else {
            cellVisitHistory[cell] = [now]
        }
        saveVisit(cell: cell, timestamp: now)
    }

    func isExplored(x: Int, y: Int) -> Bool {
        exploredCells.contains(GridCell(x: x, y: y))
    }

    func lastVisitTimestamp(x: Int, y: Int) -> Date? {
        cellVisitHistory[GridCell(x: x, y: y)]?.last
    }

    func coordinate(for cell: GridCell) -> CLLocationCoordinate2D {
        guard let center = center else {
            // Default to some coordinate if center is not set
            return CLLocationCoordinate2D(latitude: 48.858844, longitude: 2.294351)
        }
        let lat = center.latitude + (Double(cell.x) * cellSize)
        let lon = center.longitude + (Double(cell.y) * cellSize)
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    // MARK: - Core Data Persistence

    private func saveVisit(cell: GridCell, timestamp: Date) {
        let entity = ExploredCellVisitEntity(context: context)
        entity.x = Int32(cell.x)
        entity.y = Int32(cell.y)
        entity.timestamp = timestamp
        do {
            try context.save()
        } catch {
            print("Failed to save visit: \(error)")
        }
    }

    private func loadData() {
        let fetchRequest: NSFetchRequest<ExploredCellVisitEntity> = ExploredCellVisitEntity.fetchRequest()
        do {
            let results = try context.fetch(fetchRequest)
            for entity in results {
                let cell = GridCell(x: Int(entity.x), y: Int(entity.y))
                exploredCells.insert(cell)
                let ts = entity.timestamp ?? Date()
                if cellVisitHistory[cell] != nil {
                    cellVisitHistory[cell]?.append(ts)
                } else {
                    cellVisitHistory[cell] = [ts]
                }
            }
        } catch {
            print("Failed to load visits: \(error)")
        }
    }
}
