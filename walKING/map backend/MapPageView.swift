import SwiftUI
import MapKit
import CoreLocation
import SwiftData
import CoreGraphics

let montrealCoordinate = CLLocationCoordinate2D(latitude: 45.5, longitude: -73.7)

// Helper function to compute the convex hull of an array of coordinates
func convexHull(of coordinates: [CLLocationCoordinate2D]) -> [CLLocationCoordinate2D] {
	guard coordinates.count > 2 else {
		return coordinates
	}

	let points: [CGPoint] = coordinates.map { CGPoint(x: $0.longitude, y: $0.latitude) }

	func crossProduct(_ o: CGPoint, _ a: CGPoint, _ b: CGPoint) -> CGFloat {
		return (a.x - o.x) * (b.y - o.y) - (a.y - o.y) * (b.x - o.x)
	}

	let sortedPoints = points.sorted { $0.x < $1.x || ($0.x == $1.x && $0.y < $1.y) }

	var hull: [CGPoint] = []

	for point in sortedPoints {
		while hull.count >= 2 && crossProduct(hull[hull.count-2], hull.last!, point) <= 0 {
			hull.removeLast()
		}
		hull.append(point)
	}

	for point in sortedPoints.reversed() {
		while hull.count >= 2 && crossProduct(hull[hull.count-2], hull.last!, point) <= 0 {
			hull.removeLast()
		}
		hull.append(point)
	}

	hull.removeLast()

	let hullCoordinates = hull.map { CLLocationCoordinate2D(latitude: $0.y, longitude: $0.x) }

	return hullCoordinates
}


struct MKMapViewContainer: UIViewRepresentable {

	@Binding var visitedAreaPolygon: MKPolygon?
	@Binding var currentLocationCircle: MKCircle?

	var coordinatorDidFinishSetup: ((Coordinator) -> Void)? = nil

	func makeCoordinator() -> Coordinator {
		let coordinator = Coordinator(self)
		coordinatorDidFinishSetup?(coordinator)
		return coordinator
	}

	func makeUIView(context: Context) -> MKMapView {
		let mapView = MKMapView()
		mapView.mapType = .hybrid

		mapView.isZoomEnabled = true
		mapView.isScrollEnabled = true
		mapView.isPitchEnabled = true
		mapView.isRotateEnabled = true

		mapView.showsUserLocation = true

		let defaultCenterCoordinate = montrealCoordinate
		let defaultDistance: CLLocationDistance = 150_000
		let defaultRegion = MKCoordinateRegion(center: defaultCenterCoordinate, latitudinalMeters: defaultDistance, longitudinalMeters: defaultDistance)
		mapView.setRegion(defaultRegion, animated: false)

		mapView.delegate = context.coordinator
		context.coordinator.mapView = mapView

		return mapView
	}

	func updateUIView(_ uiView: MKMapView, context: Context) {
		uiView.removeOverlays(uiView.overlays)

		if let polygon = visitedAreaPolygon {
			uiView.addOverlay(polygon)
		}

		if let circle = currentLocationCircle {
			uiView.addOverlay(circle)
		}
	}

	class Coordinator: NSObject, MKMapViewDelegate {
		var parent: MKMapViewContainer
		var mapView: MKMapView?

		init(_ parent: MKMapViewContainer) {
			self.parent = parent
		}

		// Provides a renderer for each overlay
		func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
			if let polygon = overlay as? MKPolygon {
				let renderer = MKPolygonRenderer(polygon: polygon)
				renderer.fillColor = UIColor.blue.withAlphaComponent(0.3)
				renderer.strokeColor = .blue
				renderer.lineWidth = 2
				return renderer
			}
			else if let circle = overlay as? MKCircle {
				let renderer = MKCircleRenderer(circle: circle)
				renderer.fillColor = UIColor.blue.withAlphaComponent(0.2)
				renderer.strokeColor = .systemBlue
				renderer.lineWidth = 1
				return renderer
			}
			return MKOverlayRenderer(overlay: overlay)
		}

		func centerMap(on coordinate: CLLocationCoordinate2D, animated: Bool = true) {
			let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
			let region = MKCoordinateRegion(center: coordinate, span: span)
			mapView?.setRegion(region, animated: animated)
		}
	}
}

struct MapPageView: View {
	@Environment(\.modelContext) private var modelContext

	@StateObject private var locationManager = LocationManager()

	@Query(sort: \LocationEntry.timestamp) private var locationEntries: [LocationEntry]

	@State private var visitedAreaPolygon: MKPolygon?
	@State private var currentLocationCircle: MKCircle?

	@State private var initialUserCenterDone = false
	@State private var mapViewCoordinator: MKMapViewContainer.Coordinator?

	var body: some View {
		ZStack {
			MKMapViewContainer(
				visitedAreaPolygon: $visitedAreaPolygon,
				currentLocationCircle: $currentLocationCircle,
				coordinatorDidFinishSetup: { coordinator in
					self.mapViewCoordinator = coordinator
				}
			)
			.ignoresSafeArea()

			VStack {
				Spacer()
				Button("Clear Tracked Path") {
					locationManager.clearSavedLocations()
				}
				.padding()
				.background(Color.red.opacity(0.8))
				.foregroundColor(.white)
				.cornerRadius(10)
				.padding(.bottom)
			}
		}
		.onAppear {
			locationManager.setModelContext(modelContext)
			updateMapOverlays()
		}
		.onChange(of: locationEntries) { _, _ in
			updateMapOverlays()
		}
		.onChange(of: locationManager.currentLocation) { _, newLocation in
			updateCurrentLocationCircle(newLocation)

			if let location = newLocation, !initialUserCenterDone {
				mapViewCoordinator?.centerMap(on: location.coordinate)
				initialUserCenterDone = true
			}
		}
	}

	private func updateMapOverlays() {
		guard locationEntries.count > 2 else {
			visitedAreaPolygon = nil
			return
		}

		let coordinates = locationEntries.map { $0.coordinate }
		let hullCoordinates = convexHull(of: coordinates)

		guard hullCoordinates.count > 2 else {
			 visitedAreaPolygon = nil
			 return
		}

		self.visitedAreaPolygon = MKPolygon(coordinates: hullCoordinates, count: hullCoordinates.count)
	}

	private func updateCurrentLocationCircle(_ location: CLLocation?) {
		if let location = location {
			let radius = location.horizontalAccuracy > 0 ? location.horizontalAccuracy : 50.0
			self.currentLocationCircle = MKCircle(center: location.coordinate, radius: radius)
		} else {
			self.currentLocationCircle = nil
		}
	}
}

#Preview {
	MapPageView()
		.modelContainer(for: LocationEntry.self, inMemory: true)
}
