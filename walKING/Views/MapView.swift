//
//  MapView.swift
//  walKING
//
//  Created by Chariot 4 - Ordinateur19 - User3 on 2025-06-11.
//

import SwiftUI
import CoreLocation
import CoreData

struct GridCell: Hashable, Codable {
    let x: Int
    let y: Int
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
    private let cellSize: Double = 0.0005
    private var center: CLLocationCoordinate2D?
    private let locationManager = CLLocationManager()
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        super.init()
        loadData()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        #if os(iOS)
        locationManager.allowsBackgroundLocationUpdates = true
        #endif
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        if center == nil {
            center = loc.coordinate
        }
        updateExplored(for: loc.coordinate)
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

struct MapView: View {
    @StateObject private var viewModel = MapViewModel()
    @State private var zoomLevel: Int = 1 // 1 = default, higher = zoomed out, lower = zoomed in

    private var cellsPerSide: Int {
        max(4, 20 * zoomLevel) // Minimum 4x4 grid, scales with zoom
    }
    private var cellSize: CGFloat {
        max(4, 16 / CGFloat(zoomLevel)) // Minimum size 4, scales with zoom
    }

    var body: some View {
        VStack(spacing: 2) {
            HStack {
                Text("Exploration Map")
                    .font(.headline)
                Spacer()
                Button(action: { if zoomLevel > 1 { zoomLevel -= 1 } }) {
                    Image(systemName: "minus.magnifyingglass")
                }
                .padding(.horizontal, 4)
                Button(action: { zoomLevel += 1 }) {
                    Image(systemName: "plus.magnifyingglass")
                }
            }
            .padding(.horizontal)
            ForEach(-(cellsPerSide/2)..<(cellsPerSide/2), id: \.self) { row in
                HStack(spacing: 2) {
                    ForEach(-(cellsPerSide/2)..<(cellsPerSide/2), id: \.self) { col in
                        Rectangle()
                            .fill(viewModel.isExplored(x: row, y: col) ? Color.green : Color.gray)
                            .frame(width: cellSize, height: cellSize)
                            .border(Color.black, width: 0.5)
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    MapView()
}
