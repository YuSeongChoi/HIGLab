# MapKit AI Reference

> 지도 및 위치 기반 서비스 가이드. 이 문서를 읽고 MapKit 코드를 생성할 수 있습니다.

## 개요

MapKit은 앱에 대화형 지도를 추가하는 프레임워크입니다.
위치 검색, 경로 안내, 커스텀 마커 등을 지원합니다.

## 필수 Import

```swift
import MapKit
import SwiftUI
```

## 핵심 구성요소

### 1. 기본 지도 (iOS 17+)

```swift
struct SimpleMapView: View {
    var body: some View {
        Map()  // 현재 위치 기반 기본 지도
    }
}

// 특정 위치로 시작
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

### 2. 마커 & 어노테이션

```swift
struct Place: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

struct MarkerMapView: View {
    let places = [
        Place(name: "서울역", coordinate: CLLocationCoordinate2D(latitude: 37.5547, longitude: 126.9707)),
        Place(name: "강남역", coordinate: CLLocationCoordinate2D(latitude: 37.4979, longitude: 127.0276))
    ]
    
    var body: some View {
        Map {
            // 기본 마커
            ForEach(places) { place in
                Marker(place.name, coordinate: place.coordinate)
                    .tint(.red)
            }
            
            // 커스텀 어노테이션
            Annotation("카페", coordinate: CLLocationCoordinate2D(latitude: 37.52, longitude: 127.0)) {
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

### 3. 지도 스타일 & 컨트롤

```swift
struct StyledMapView: View {
    @State private var position = MapCameraPosition.automatic
    
    var body: some View {
        Map(position: $position) {
            // 콘텐츠
        }
        .mapStyle(.imagery(elevation: .realistic))  // 위성 + 3D
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

## 전체 작동 예제

```swift
import SwiftUI
import MapKit

// MARK: - 모델
struct Landmark: Identifiable {
    let id = UUID()
    let name: String
    let category: Category
    let coordinate: CLLocationCoordinate2D
    
    enum Category: String, CaseIterable {
        case restaurant = "식당"
        case cafe = "카페"
        case attraction = "명소"
        
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
            
            // 결과로 카메라 이동
            if let first = landmarks.first {
                cameraPosition = .region(MKCoordinateRegion(
                    center: first.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                ))
            }
        } catch {
            print("검색 실패: \(error)")
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
            
            // 현재 위치
            UserAnnotation()
        }
        .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .including([.cafe, .restaurant])))
        .mapControls {
            MapUserLocationButton()
            MapCompass()
        }
        .safeAreaInset(edge: .top) {
            HStack {
                TextField("장소 검색", text: $viewModel.searchText)
                    .textFieldStyle(.roundedBorder)
                
                Button("검색") {
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
            
            // 길찾기 버튼
            Button("Apple 지도에서 열기") {
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

## 고급 패턴

### 1. 경로 표시

```swift
struct RouteMapView: View {
    @State private var route: MKRoute?
    
    let start = CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780)
    let end = CLLocationCoordinate2D(latitude: 37.4979, longitude: 127.0276)
    
    var body: some View {
        Map {
            Marker("출발", coordinate: start).tint(.green)
            Marker("도착", coordinate: end).tint(.red)
            
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
            print("경로 계산 실패: \(error)")
        }
    }
}
```

### 2. Look Around (스트리트 뷰)

```swift
struct LookAroundView: View {
    let coordinate: CLLocationCoordinate2D
    @State private var scene: MKLookAroundScene?
    
    var body: some View {
        Group {
            if let scene {
                LookAroundPreview(scene: scene)
            } else {
                ContentUnavailableView("Look Around 불가", systemImage: "eye.slash")
            }
        }
        .task {
            let request = MKLookAroundSceneRequest(coordinate: coordinate)
            scene = try? await request.scene
        }
    }
}
```

### 3. 클러스터링

```swift
struct ClusteredMapView: View {
    let places: [Place]
    
    var body: some View {
        Map {
            ForEach(places) { place in
                Marker(place.name, coordinate: place.coordinate)
                    .annotationTitles(.hidden)  // 클러스터링 시 제목 숨김
            }
        }
        .mapStyle(.standard(pointsOfInterest: .excludingAll))
    }
}
```

### 4. 지오코딩

```swift
class GeocodingService {
    private let geocoder = CLGeocoder()
    
    // 주소 → 좌표
    func geocode(address: String) async throws -> CLLocationCoordinate2D {
        let placemarks = try await geocoder.geocodeAddressString(address)
        guard let location = placemarks.first?.location else {
            throw GeocodingError.notFound
        }
        return location.coordinate
    }
    
    // 좌표 → 주소
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

## 주의사항

1. **권한 설정**
   - Info.plist: `NSLocationWhenInUseUsageDescription`
   - 지도 표시만은 권한 불필요
   - 현재 위치 버튼 사용 시 필요

2. **iOS 17+ API**
   - `Map { }` 문법은 iOS 17+
   - iOS 16: `Map(coordinateRegion:)`

3. **성능**
   - 마커가 많으면 클러스터링 고려
   - 경로 계산은 비동기로

4. **제한사항**
   - Look Around은 일부 지역만 지원
   - 중국에서는 GCJ-02 좌표계 사용
