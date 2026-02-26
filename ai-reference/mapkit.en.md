# MapKit AI Reference

> Maps and location-based services guide. Read this document to generate MapKit code.

## Overview

MapKit is a framework for adding interactive maps to your app.
It supports location search, directions, custom markers, and more.

## Required Import

```swift
import MapKit
import SwiftUI
```

## Core Components

### 1. Basic Map (iOS 17+)

```swift
struct SimpleMapView: View {
    var body: some View {
        Map()  // Default map based on current location
    }
}

// Start at a specific location
struct SeoulMapView: View {
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
    
    var body: some View {
        Map(position: $position)
    }
}
```

### 2. Markers & Annotations

```swift
struct Place: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

struct MarkerMapView: View {
    let places = [
        Place(name: "Seoul Station", coordinate: CLLocationCoordinate2D(latitude: 37.5547, longitude: 126.9707)),
        Place(name: "Gangnam Station", coordinate: CLLocationCoordinate2D(latitude: 37.4979, longitude: 127.0276))
    ]
    
    var body: some View {
        Map {
            // Basic markers
            ForEach(places) { place in
                Marker(place.name, coordinate: place.coordinate)
                    .tint(.red)
            }
            
            // Custom annotation
            Annotation("Cafe", coordinate: CLLocationCoordinate2D(latitude: 37.52, longitude: 127.0)) {
                Image(systemName: "cup.and.saucer.fill")
                    .padding(8)
                    .background(.white)
                    .clipShape(Circle())
                    .shadow(radius: 2)
            }
        }
    }
}
```

### 3. Map Styles & Controls

```swift
struct StyledMapView: View {
    @State private var position = MapCameraPosition.automatic
    
    var body: some View {
        Map(position: $position) {
            // Content
        }
        .mapStyle(.imagery(elevation: .realistic))  // Satellite + 3D
        // .mapStyle(.standard)
        // .mapStyle(.hybrid)
        .mapControls {
            MapCompass()
            MapScaleView()
            MapUserLocationButton()
            MapPitchToggle()
        }
    }
}
```

## Complete Working Example

```swift
import SwiftUI
import MapKit

// MARK: - Model
struct Landmark: Identifiable {
    let id = UUID()
    let name: String
    let category: Category
    let coordinate: CLLocationCoordinate2D
    
    enum Category: String, CaseIterable {
        case restaurant = "Restaurant"
        case cafe = "Cafe"
        case attraction = "Attraction"
        
        var icon: String {
            switch self {
            case .restaurant: return "fork.knife"
            case .cafe: return "cup.and.saucer.fill"
            case .attraction: return "star.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .restaurant: return .orange
            case .cafe: return .brown
            case .attraction: return .yellow
            }
        }
    }
}

// MARK: - ViewModel
@Observable
class MapViewModel {
    var landmarks: [Landmark] = []
    var selectedLandmark: Landmark?
    var searchText = ""
    var cameraPosition = MapCameraPosition.automatic
    
    func search() async {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.resultTypes = .pointOfInterest
        
        let search = MKLocalSearch(request: request)
        
        do {
            let response = try await search.start()
            landmarks = response.mapItems.map { item in
                Landmark(
                    name: item.name ?? "Unknown",
                    category: .attraction,
                    coordinate: item.placemark.coordinate
                )
            }
            
            // Move camera to results
            if let first = landmarks.first {
                cameraPosition = .region(MKCoordinateRegion(
                    center: first.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                ))
            }
        } catch {
            print("Search failed: \(error)")
        }
    }
    
    func selectLandmark(_ landmark: Landmark) {
        selectedLandmark = landmark
        cameraPosition = .camera(MapCamera(
            centerCoordinate: landmark.coordinate,
            distance: 1000,
            heading: 0,
            pitch: 60
        ))
    }
}

// MARK: - View
struct PlaceExplorerView: View {
    @State private var viewModel = MapViewModel()
    @State private var showingDetail = false
    
    var body: some View {
        Map(position: $viewModel.cameraPosition, selection: $viewModel.selectedLandmark) {
            ForEach(viewModel.landmarks) { landmark in
                Marker(landmark.name, systemImage: landmark.category.icon, coordinate: landmark.coordinate)
                    .tint(landmark.category.color)
                    .tag(landmark)
            }
            
            // Current location
            UserAnnotation()
        }
        .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .including([.cafe, .restaurant])))
        .mapControls {
            MapUserLocationButton()
            MapCompass()
        }
        .safeAreaInset(edge: .top) {
            HStack {
                TextField("Search places", text: $viewModel.searchText)
                    .textFieldStyle(.roundedBorder)
                
                Button("Search") {
                    Task { await viewModel.search() }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(.ultraThinMaterial)
        }
        .sheet(item: $viewModel.selectedLandmark) { landmark in
            LandmarkDetailView(landmark: landmark)
                .presentationDetents([.medium])
        }
    }
}

struct LandmarkDetailView: View {
    let landmark: Landmark
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(landmark.name)
                .font(.title2.bold())
            
            Label(landmark.category.rawValue, systemImage: landmark.category.icon)
                .foregroundStyle(landmark.category.color)
            
            // Directions button
            Button("Open in Apple Maps") {
                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: landmark.coordinate))
                mapItem.name = landmark.name
                mapItem.openInMaps(launchOptions: [
                    MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
                ])
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
```

## Advanced Patterns

### 1. Displaying Routes

```swift
struct RouteMapView: View {
    @State private var route: MKRoute?
    
    let start = CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780)
    let end = CLLocationCoordinate2D(latitude: 37.4979, longitude: 127.0276)
    
    var body: some View {
        Map {
            Marker("Start", coordinate: start).tint(.green)
            Marker("End", coordinate: end).tint(.red)
            
            if let route {
                MapPolyline(route.polyline)
                    .stroke(.blue, lineWidth: 5)
            }
        }
        .task {
            await calculateRoute()
        }
    }
    
    func calculateRoute() async {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: start))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: end))
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        
        do {
            let response = try await directions.calculate()
            route = response.routes.first
        } catch {
            print("Route calculation failed: \(error)")
        }
    }
}
```

### 2. Look Around (Street View)

```swift
struct LookAroundView: View {
    let coordinate: CLLocationCoordinate2D
    @State private var scene: MKLookAroundScene?
    
    var body: some View {
        Group {
            if let scene {
                LookAroundPreview(scene: scene)
            } else {
                ContentUnavailableView("Look Around Unavailable", systemImage: "eye.slash")
            }
        }
        .task {
            let request = MKLookAroundSceneRequest(coordinate: coordinate)
            scene = try? await request.scene
        }
    }
}
```

### 3. Clustering

```swift
struct ClusteredMapView: View {
    let places: [Place]
    
    var body: some View {
        Map {
            ForEach(places) { place in
                Marker(place.name, coordinate: place.coordinate)
                    .annotationTitles(.hidden)  // Hide titles when clustering
            }
        }
        .mapStyle(.standard(pointsOfInterest: .excludingAll))
    }
}
```

### 4. Geocoding

```swift
class GeocodingService {
    private let geocoder = CLGeocoder()
    
    // Address → Coordinates
    func geocode(address: String) async throws -> CLLocationCoordinate2D {
        let placemarks = try await geocoder.geocodeAddressString(address)
        guard let location = placemarks.first?.location else {
            throw GeocodingError.notFound
        }
        return location.coordinate
    }
    
    // Coordinates → Address
    func reverseGeocode(coordinate: CLLocationCoordinate2D) async throws -> String {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let placemarks = try await geocoder.reverseGeocodeLocation(location)
        guard let placemark = placemarks.first else {
            throw GeocodingError.notFound
        }
        return [placemark.locality, placemark.thoroughfare, placemark.subThoroughfare]
            .compactMap { $0 }
            .joined(separator: " ")
    }
}
```

## Important Notes

1. **Permission Setup**
   - Info.plist: `NSLocationWhenInUseUsageDescription`
   - No permission required just for displaying maps
   - Required when using current location button

2. **iOS 17+ API**
   - `Map { }` syntax is iOS 17+
   - iOS 16: `Map(coordinateRegion:)`

3. **Performance**
   - Consider clustering for many markers
   - Calculate routes asynchronously

4. **Limitations**
   - Look Around only supported in some regions
   - Uses GCJ-02 coordinate system in China
