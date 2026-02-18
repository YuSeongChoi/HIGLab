# Core Location AI Reference

> 위치 서비스 및 지오펜싱 가이드. 이 문서를 읽고 Core Location 코드를 생성할 수 있습니다.

## 개요

Core Location은 기기의 위치, 고도, 방향 정보를 제공하는 프레임워크입니다.
GPS, Wi-Fi, 셀룰러, 비콘을 활용해 위치를 파악합니다.

## 필수 Import

```swift
import CoreLocation
```

## 프로젝트 설정 (Info.plist)

```xml
<!-- 앱 사용 중 위치 -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>현재 위치를 지도에 표시하기 위해 필요합니다.</string>

<!-- 항상 위치 (백그라운드) -->
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>백그라운드에서 위치 기반 알림을 보내기 위해 필요합니다.</string>
```

## 핵심 구성요소

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

### 2. 권한 상태

```swift
switch manager.authorizationStatus {
case .notDetermined:
    // 아직 요청 안 함
    manager.requestWhenInUseAuthorization()
case .restricted, .denied:
    // 설정으로 유도
    if let url = URL(string: UIApplication.openSettingsURLString) {
        UIApplication.shared.open(url)
    }
case .authorizedWhenInUse:
    // 앱 사용 중만 허용
    manager.startUpdatingLocation()
case .authorizedAlways:
    // 항상 허용 (백그라운드 가능)
    manager.startUpdatingLocation()
@unknown default:
    break
}
```

### 3. 정확도 설정

```swift
// 최고 정확도 (배터리 소모 높음)
manager.desiredAccuracy = kCLLocationAccuracyBest

// 네비게이션용
manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation

// 10미터 정확도
manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters

// 100미터 정확도 (배터리 절약)
manager.desiredAccuracy = kCLLocationAccuracyHundredMeters

// 킬로미터 정확도
manager.desiredAccuracy = kCLLocationAccuracyKilometer

// 최소 이동 거리 (미터)
manager.distanceFilter = 10  // 10m 이동 시마다 업데이트
```

## 전체 작동 예제

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
        manager.requestLocation()  // 단일 위치 요청
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
        
        // 정확도 필터링
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
                // 권한 상태
                StatusBadge(status: locationManager.authorizationStatus)
                
                // 현재 위치
                if let location = locationManager.location {
                    VStack(spacing: 8) {
                        Text("현재 위치")
                            .font(.headline)
                        
                        Text("\(location.coordinate.latitude, specifier: "%.4f"), \(location.coordinate.longitude, specifier: "%.4f")")
                            .font(.system(.body, design: .monospaced))
                        
                        if let placemark = locationManager.placemark {
                            Text(formatAddress(placemark))
                                .foregroundStyle(.secondary)
                        }
                        
                        Text("정확도: \(Int(location.horizontalAccuracy))m")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                } else if locationManager.isLoading {
                    ProgressView("위치 확인 중...")
                }
                
                // 버튼
                VStack(spacing: 12) {
                    if locationManager.authorizationStatus == .notDetermined {
                        Button("위치 권한 요청") {
                            locationManager.requestPermission()
                        }
                        .buttonStyle(.borderedProminent)
                    } else if locationManager.authorizationStatus == .authorizedWhenInUse ||
                              locationManager.authorizationStatus == .authorizedAlways {
                        Button("현재 위치 새로고침") {
                            locationManager.requestLocation()
                        }
                        .buttonStyle(.bordered)
                    } else {
                        Button("설정에서 권한 허용") {
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
            .navigationTitle("위치")
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
        case .authorizedAlways: return "항상 허용"
        case .authorizedWhenInUse: return "앱 사용 중 허용"
        case .denied: return "거부됨"
        case .restricted: return "제한됨"
        case .notDetermined: return "권한 필요"
        @unknown default: return "알 수 없음"
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

## 고급 패턴

### 1. 지오펜싱

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
    print("진입: \(region.identifier)")
    // 로컬 알림 등
}

func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
    print("이탈: \(region.identifier)")
}
```

### 2. 백그라운드 위치

```swift
// 1. Capabilities: Background Modes → Location updates 체크
// 2. Info.plist: NSLocationAlwaysAndWhenInUseUsageDescription

func enableBackgroundLocation() {
    manager.allowsBackgroundLocationUpdates = true
    manager.pausesLocationUpdatesAutomatically = false
    manager.showsBackgroundLocationIndicator = true  // 파란 바 표시
}
```

### 3. 방향 (Heading)

```swift
func startHeadingUpdates() {
    if CLLocationManager.headingAvailable() {
        manager.startUpdatingHeading()
    }
}

func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    let trueHeading = newHeading.trueHeading  // 진북 기준 (0-360)
    let magneticHeading = newHeading.magneticHeading  // 자북 기준
    print("방향: \(trueHeading)°")
}
```

### 4. 거리 계산

```swift
let seoul = CLLocation(latitude: 37.5665, longitude: 126.9780)
let busan = CLLocation(latitude: 35.1796, longitude: 129.0756)

let distance = seoul.distance(from: busan)  // 미터 단위
print("서울-부산: \(distance / 1000) km")  // ~325 km
```

## 주의사항

1. **권한 요청 타이밍**
   - 앱 시작 시 바로 요청 ❌
   - 기능 사용 직전에 요청 ✅
   - 왜 필요한지 설명 UI 추가

2. **배터리 최적화**
   - 필요할 때만 `startUpdatingLocation()`
   - 단일 요청은 `requestLocation()` 사용
   - `distanceFilter` 적절히 설정

3. **정확도 vs 배터리**
   - `kCLLocationAccuracyBest`: GPS 사용, 배터리 많이 소모
   - `kCLLocationAccuracyHundredMeters`: Wi-Fi/Cell, 절약

4. **시뮬레이터 테스트**
   - Features → Location → Custom Location
   - 또는 GPX 파일로 경로 시뮬레이션
