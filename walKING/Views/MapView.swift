//
//  MapView.swift
//  walKING
//
//  Created by Chariot 4 - Ordinateur19 - User3 on 2025-06-11.
//

import SwiftUI
import CoreData
import CoreLocation
import MapKit

struct MapView: View {
    @StateObject private var viewModel: MapViewModel
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 48.858844, longitude: 2.294351), // Example: Paris
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )

    init(viewModel: MapViewModel = MapViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
//            Map(coordinateRegion: $region, annotationItems: Array(viewModel.exploredCells)) { cell in
//                // Convert your grid cell to a coordinate
//                let coord = viewModel.coordinate(for: cell)
//                return MapAnnotation(coordinate: coord) {
//                    Rectangle()
//                        .fill(Color.green.opacity(0.4))
//                        .frame(width: 20, height: 20)
//                        .border(Color.black, width: 1)
//                }
//            }
//            // ...add controls for zoom, etc...
			MapPageView()
        }
    }
}

#Preview {
    // Use in-memory CoreData and mock data for Preview
    let previewContext = PersistenceController.preview.container.viewContext
    let mockViewModel = MapViewModel(context: previewContext, enableLocation: false)
    // Simulate some explored cells
    mockViewModel.simulateVisit(x: 0, y: 0)
    mockViewModel.simulateVisit(x: 1, y: 1)
    mockViewModel.simulateVisit(x: -1, y: -1)
    return MapView(viewModel: mockViewModel)
}
