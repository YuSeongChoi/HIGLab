# Core Location AI Reference

> Location services and geofencing guide. Read this document to generate Core Location code.

## Overview

Core Location is a framework that provides device location, altitude, and heading information.
It uses GPS, Wi-Fi, cellular, and beacons to determine location.

## Required Import

```swift
import CoreLocation
```

## Project Setup (Info.plist)

```xml
<!-- Location while using app -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>Required to display your current location on the map.</string>

<!-- Always location (background) -->
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Required to send location-based notifications in the background.</string>
```

## Core Components

### 1. CLLocationManager

```swift
@Observable
class LocationManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    var location: CLLocation?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func startUpdating() {
        manager.startUpdatingLocation()
    }
    
    func stopUpdating() {
        manager.stopUpdatingLocation()
    }
    
    // MARK: - Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
}
```

### 2. Authorization Status

```swift
switch manager.authorizationStatus {
case .notDetermined:
    // Not yet requested
    manager.requestWhenInUseAuthorization()
case .restricted, .denied:
    // Direct to settings
    if let url = URL(string: UIApplication.openSettingsURLString) {
        UIApplication.shared.open(url)
    }
case .authorizedWhenInUse:
    // Allowed while using app
    manager.startUpdatingLocation()
case .authorizedAlways:
    // Always allowed (background possible)
    manager.startUpdatingLocation()
@unknown default:
    break
}
```

### 3. Accuracy Settings

```swift
// Best accuracy (high battery consumption)
manager.desiredAccuracy = kCLLocationAccuracyBest

// For navigation
manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation

// 10 meter accuracy
manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters

// 100 meter accuracy (battery saving)
manager.desiredAccuracy = kCLLocationAccuracyHundredMeters

// Kilometer accuracy
manager.desiredAccuracy = kCLLocationAccuracyKilometer

// Minimum movement distance (meters)
manager.distanceFilter = 10  // Update every 10m movement
```

## Complete Working Example

```swift
import SwiftUI
import CoreLocation

// MARK: - Location Manager
@Observable
class LocationManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    var location: CLLocation?
    var placemark: CLPlacemark?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var isLoading = false
    var error: Error?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 10
        authorizationStatus = manager.authorizationStatus
    }
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func requestLocation() {
        isLoading = true
        manager.requestLocation()  // Single location request
    }
    
    func startContinuousUpdates() {
        manager.startUpdatingLocation()
    }
    
    func stopUpdates() {
        manager.stopUpdatingLocation()
    }
    
    private func reverseGeocode(_ location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            self?.placemark = placemarks?.first
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        isLoading = false
        guard let newLocation = locations.last else { return }
        
        // Accuracy filtering
        guard newLocation.horizontalAccuracy > 0 && newLocation.horizontalAccuracy < 100 else { return }
        
        location = newLocation
        reverseGeocode(newLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isLoading = false
        self.error = error
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            requestLocation()
        }
    }
}

// MARK: - View
struct LocationView: View {
    @State private var locationManager = LocationManager()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Authorization status
                StatusBadge(status: locationManager.authorizationStatus)
                
                // Current location
                if let location = locationManager.location {
                    VStack(spacing: 8) {
                        Text("Current Location")
                            .font(.headline)
                        
                        Text("\(location.coordinate.latitude, specifier: "%.4f"), \(location.coordinate.longitude, specifier: "%.4f")")
                            .font(.system(.body, design: .monospaced))
                        
                        if let placemark = locationManager.placemark {
                            Text(formatAddress(placemark))
                                .foregroundStyle(.secondary)
                        }
                        
                        Text("Accuracy: \(Int(location.horizontalAccuracy))m")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                } else if locationManager.isLoading {
                    ProgressView("Getting location...")
                }
                
                // Buttons
                VStack(spacing: 12) {
                    if locationManager.authorizationStatus == .notDetermined {
                        Button("Request Location Permission") {
                            locationManager.requestPermission()
                        }
                        .buttonStyle(.borderedProminent)
                    } else if locationManager.authorizationStatus == .authorizedWhenInUse ||
                              locationManager.authorizationStatus == .authorizedAlways {
                        Button("Refresh Current Location") {
                            locationManager.requestLocation()
                        }
                        .buttonStyle(.bordered)
                    } else {
                        Button("Allow Permission in Settings") {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Location")
        }
    }
    
    func formatAddress(_ placemark: CLPlacemark) -> String {
        [placemark.locality, placemark.thoroughfare, placemark.subThoroughfare]
            .compactMap { $0 }
            .joined(separator: " ")
    }
}

struct StatusBadge: View {
    let status: CLAuthorizationStatus
    
    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(text)
        }
        .font(.caption)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color.opacity(0.2))
        .foregroundStyle(color)
        .clipShape(Capsule())
    }
    
    var icon: String {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse: return "checkmark.circle.fill"
        case .denied, .restricted: return "xmark.circle.fill"
        default: return "questionmark.circle.fill"
        }
    }
    
    var text: String {
        switch status {
        case .authorizedAlways: return "Always Allowed"
        case .authorizedWhenInUse: return "While Using App"
        case .denied: return "Denied"
        case .restricted: return "Restricted"
        case .notDetermined: return "Permission Required"
        @unknown default: return "Unknown"
        }
    }
    
    var color: Color {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse: return .green
        case .denied, .restricted: return .red
        default: return .orange
        }
    }
}
```

## Advanced Patterns

### 1. Geofencing

```swift
func setupGeofence(center: CLLocationCoordinate2D, radius: Double, identifier: String) {
    let region = CLCircularRegion(
        center: center,
        radius: radius,
        identifier: identifier
    )
    region.notifyOnEntry = true
    region.notifyOnExit = true
    
    manager.startMonitoring(for: region)
}

// Delegate
func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
    print("Entered: \(region.identifier)")
    // Local notification, etc.
}

func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
    print("Exited: \(region.identifier)")
}
```

### 2. Background Location

```swift
// 1. Capabilities: Background Modes → Location updates check
// 2. Info.plist: NSLocationAlwaysAndWhenInUseUsageDescription

func enableBackgroundLocation() {
    manager.allowsBackgroundLocationUpdates = true
    manager.pausesLocationUpdatesAutomatically = false
    manager.showsBackgroundLocationIndicator = true  // Show blue bar
}
```

### 3. Heading (Direction)

```swift
func startHeadingUpdates() {
    if CLLocationManager.headingAvailable() {
        manager.startUpdatingHeading()
    }
}

func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    let trueHeading = newHeading.trueHeading  // True north based (0-360)
    let magneticHeading = newHeading.magneticHeading  // Magnetic north based
    print("Heading: \(trueHeading)°")
}
```

### 4. Distance Calculation

```swift
let seoul = CLLocation(latitude: 37.5665, longitude: 126.9780)
let busan = CLLocation(latitude: 35.1796, longitude: 129.0756)

let distance = seoul.distance(from: busan)  // In meters
print("Seoul-Busan: \(distance / 1000) km")  // ~325 km
```

## Important Notes

1. **Permission Request Timing**
   - Don't request immediately at app launch ❌
   - Request right before feature use ✅
   - Add UI explaining why it's needed

2. **Battery Optimization**
   - Only call `startUpdatingLocation()` when needed
   - Use `requestLocation()` for single requests
   - Set `distanceFilter` appropriately

3. **Accuracy vs Battery**
   - `kCLLocationAccuracyBest`: Uses GPS, high battery consumption
   - `kCLLocationAccuracyHundredMeters`: Wi-Fi/Cell, battery saving

4. **Simulator Testing**
   - Features → Location → Custom Location
   - Or simulate routes with GPX files
