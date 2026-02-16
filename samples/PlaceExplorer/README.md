# PlaceExplorer

주변 장소를 탐색하는 iOS 앱 샘플입니다. **iOS 17+ MapKit API**를 활용하여 Apple Human Interface Guidelines의 지도 UI 원칙을 따릅니다.

## 스크린샷

| 지도 뷰 | 장소 상세 | 검색 |
|---------|----------|------|
| 🗺️ Map with Markers | 📍 Look Around | 🔍 Search UI |

## 주요 기능

- **지도 탐색**: iOS 17+ `Map` 뷰와 `Marker`/`Annotation` 사용
- **카테고리 검색**: 음식점, 카페, 병원, 약국 등 8개 카테고리
- **Look Around**: 장소 상세에서 360° 거리뷰 프리뷰
- **길찾기**: 도보/자동차/대중교통 경로 계산
- **Apple Maps 연동**: 선택한 장소를 Maps 앱에서 열기

## 파일 구조

```
PlaceExplorer/
├── Shared/
│   ├── Place.swift           # 장소 모델 (name, coordinate, category, rating)
│   ├── LocationManager.swift # CLLocationManager 래퍼 (@Observable)
│   └── PlaceService.swift    # MKLocalSearch 기반 검색 서비스
│
├── PlaceExplorerApp/
│   ├── PlaceExplorerApp.swift # @main 앱 진입점
│   ├── ContentView.swift      # 메인 화면 (Map + 리스트)
│   ├── MapView.swift          # Map with Markers, Annotations
│   ├── PlaceDetailView.swift  # 장소 상세 (Look Around, Directions)
│   └── SearchView.swift       # 검색 UI
│
└── README.md
```

## 요구 사항

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Info.plist 권한 설정

앱이 위치 서비스를 사용하려면 `Info.plist`에 다음 키를 추가해야 합니다:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>주변 장소를 검색하기 위해 현재 위치가 필요합니다.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>주변 장소를 검색하기 위해 현재 위치가 필요합니다.</string>
```

### Xcode에서 추가하기

1. Project Navigator에서 프로젝트 선택
2. **Targets** → **Info** 탭 선택
3. **Custom iOS Target Properties** 섹션에서 **+** 클릭
4. `Privacy - Location When In Use Usage Description` 추가
5. 값에 사용 목적 설명 입력

## 사용된 iOS 17+ MapKit API

### Map 뷰

```swift
Map(position: $cameraPosition, selection: $selectedMarker) {
    UserAnnotation()
    
    ForEach(places) { place in
        Marker(place.name, systemImage: place.category.symbol, coordinate: place.coordinate)
            .tint(Color(place.category.color))
            .tag(place)
    }
}
.mapStyle(.standard(elevation: .realistic))
.mapControls {
    MapCompass()
    MapScaleView()
    MapPitchToggle()
}
```

### Look Around

```swift
LookAroundPreview(scene: .constant(scene))
    .frame(height: 220)
    .clipShape(RoundedRectangle(cornerRadius: 16))
```

### MKLocalSearch

```swift
let request = MKLocalSearch.Request()
request.naturalLanguageQuery = "카페"
request.region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
request.resultTypes = .pointOfInterest

let search = MKLocalSearch(request: request)
let response = try await search.start()
```

## HIG 가이드라인 준수 사항

### 지도 UI (Maps)

- ✅ 시스템 지도 컨트롤 사용 (MapCompass, MapScaleView)
- ✅ 사용자 위치 명확히 표시 (UserAnnotation)
- ✅ 마커에 일관된 색상 체계 적용
- ✅ 탭 가능한 요소에 적절한 터치 영역 제공

### 위치 서비스 (Location)

- ✅ 위치 사용 목적 명확히 설명
- ✅ 권한 거부 시 대체 동작 제공 (서울 시청 기본 좌표)
- ✅ 필요한 순간에만 위치 요청

### 검색 (Search)

- ✅ 검색 바에 명확한 placeholder 텍스트
- ✅ 최근 검색어 제공
- ✅ 검색 결과에 관련 정보 표시 (평점, 주소)
- ✅ 검색 중 로딩 상태 표시

## 참고 링크

- [Human Interface Guidelines - Maps](https://developer.apple.com/design/human-interface-guidelines/maps)
- [MapKit Documentation](https://developer.apple.com/documentation/mapkit)
- [What's new in MapKit - WWDC23](https://developer.apple.com/videos/play/wwdc2023/10043/)

## 라이선스

이 샘플은 학습 목적으로 제공됩니다.
