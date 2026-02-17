# LocationTracker

CoreLocation을 활용한 위치 추적 샘플 앱입니다.

## 개요

이 앱은 iOS의 CoreLocation 프레임워크를 사용하여 다음 기능을 구현합니다:

- **실시간 위치 추적**: 현재 위치, 속도, 고도, 방향 정보 표시
- **경로 기록**: 이동 경로를 기록하고 저장
- **지오펜싱**: 특정 지역 진입/이탈 시 알림
- **경로 시각화**: MapKit을 사용한 경로 지도 표시

## 프로젝트 구조

```
LocationTracker/
├── Shared/
│   ├── LocationData.swift       # 위치 데이터 모델
│   ├── LocationManager.swift    # CLLocationManager 래퍼
│   └── GeofenceManager.swift    # 지오펜싱 관리
├── LocationTrackerApp/
│   ├── LocationTrackerApp.swift # 앱 진입점
│   ├── ContentView.swift        # 메인 화면 (현재 위치)
│   ├── MapTrackView.swift       # 경로 지도
│   ├── GeofenceSetupView.swift  # 지오펜스 설정
│   ├── HistoryView.swift        # 기록 관리
│   └── SettingsView.swift       # 설정
└── README.md
```

## 주요 기능

### 1. 현재 위치 (`ContentView`)
- 위치 권한 상태 표시
- 실시간 위치 좌표 표시
- 고도, 속도, 방향 정보
- 경로 기록 시작/중지

### 2. 경로 지도 (`MapTrackView`)
- MapKit을 사용한 경로 시각화
- 저장된 경로 목록
- 지도 스타일 변경 (기본/위성/하이브리드)
- 경로 통계 표시 (거리, 시간, 속도)

### 3. 지오펜싱 (`GeofenceSetupView`)
- 지오펜스 추가/삭제
- 진입/이탈 알림 설정
- 이벤트 기록 확인

### 4. 기록 관리 (`HistoryView`)
- 저장된 경로 목록
- 경로 상세 정보
- 총 통계 (거리, 시간)
- 경로 삭제/이름 변경

### 5. 설정 (`SettingsView`)
- 위치 정확도 설정
- 백그라운드 업데이트 설정
- 데이터 관리

## 필요한 권한

### Info.plist 설정

```xml
<!-- 위치 권한 (사용 중) -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>경로 기록 및 현재 위치 표시를 위해 위치 권한이 필요합니다.</string>

<!-- 위치 권한 (항상) -->
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>백그라운드에서 경로 기록 및 지오펜스 알림을 위해 '항상' 위치 권한이 필요합니다.</string>

<!-- 백그라운드 모드 -->
<key>UIBackgroundModes</key>
<array>
    <string>location</string>
</array>
```

## CoreLocation 주요 API

### CLLocationManager

```swift
// 위치 관리자 생성 및 설정
let locationManager = CLLocationManager()
locationManager.delegate = self
locationManager.desiredAccuracy = kCLLocationAccuracyBest
locationManager.distanceFilter = 10  // 최소 이동 거리 (미터)

// 권한 요청
locationManager.requestWhenInUseAuthorization()
locationManager.requestAlwaysAuthorization()

// 위치 업데이트
locationManager.startUpdatingLocation()
locationManager.stopUpdatingLocation()
```

### 지오펜싱

```swift
// 지역 생성
let region = CLCircularRegion(
    center: coordinate,
    radius: 100,  // 반경 (미터)
    identifier: "unique-id"
)
region.notifyOnEntry = true
region.notifyOnExit = true

// 모니터링
locationManager.startMonitoring(for: region)
locationManager.stopMonitoring(for: region)
```

### CLLocationManagerDelegate

```swift
// 위치 업데이트
func locationManager(_ manager: CLLocationManager, 
                     didUpdateLocations locations: [CLLocation])

// 지역 진입
func locationManager(_ manager: CLLocationManager, 
                     didEnterRegion region: CLRegion)

// 지역 이탈
func locationManager(_ manager: CLLocationManager, 
                     didExitRegion region: CLRegion)

// 권한 변경
func locationManagerDidChangeAuthorization(_ manager: CLLocationManager)
```

## 데이터 모델

### LocationPoint
```swift
struct LocationPoint {
    let latitude: Double       // 위도
    let longitude: Double      // 경도
    let altitude: Double       // 고도
    let horizontalAccuracy: Double
    let speed: Double          // 속도 (m/s)
    let course: Double         // 방향 (도)
    let timestamp: Date
}
```

### LocationTrack
```swift
struct LocationTrack {
    let id: UUID
    var name: String
    var points: [LocationPoint]
    let startTime: Date
    var endTime: Date?
    var totalDistance: Double  // 총 거리
    var duration: TimeInterval // 소요 시간
}
```

### GeofenceRegion
```swift
struct GeofenceRegion {
    let id: UUID
    var name: String
    let latitude: Double
    let longitude: Double
    var radius: Double         // 반경 (미터)
    var notifyOnEntry: Bool
    var notifyOnExit: Bool
}
```

## 배터리 최적화 팁

1. **정확도 조절**: `kCLLocationAccuracyBest` 대신 `kCLLocationAccuracyHundredMeters` 사용
2. **distanceFilter**: 필요한 만큼만 업데이트 받기
3. **pausesLocationUpdatesAutomatically**: 정지 시 자동 일시정지
4. **significantLocationChanges**: 대략적인 위치 변경만 감지 (배터리 효율적)

## 지오펜스 제한사항

- **최대 개수**: 앱당 최대 20개
- **최소 반경**: 100미터 권장
- **정확도**: Wi-Fi, 셀룰러 기반으로 정확도가 달라질 수 있음
- **지연**: 진입/이탈 감지에 약간의 지연이 있을 수 있음

## HIG 가이드라인

### 위치 권한 요청
- 권한이 필요한 기능 사용 직전에 요청
- 명확한 사용 목적 설명 제공
- 거부해도 앱 기본 기능은 사용 가능하게

### 위치 표시
- 파란색 점으로 현재 위치 표시 (Apple Maps 스타일)
- 정확도에 따른 원형 범위 표시
- 방향 표시 (나침반 아이콘)

### 백그라운드 동작
- 상태 바에 위치 사용 인디케이터 표시
- 배터리 사용량 최적화
- 사용자에게 백그라운드 동작 알림

## 실행 방법

1. Xcode에서 프로젝트 열기
2. 시뮬레이터 또는 실제 기기 선택
3. Info.plist에 위치 권한 설명 추가
4. 빌드 및 실행

## 시뮬레이터에서 테스트

1. **위치 시뮬레이션**: 
   - Debug > Simulate Location
   - 또는 GPX 파일 사용

2. **지오펜스 테스트**:
   - 시뮬레이터에서 위치를 지오펜스 안/밖으로 변경

## 참고 자료

- [Apple CoreLocation Documentation](https://developer.apple.com/documentation/corelocation)
- [Human Interface Guidelines - Privacy](https://developer.apple.com/design/human-interface-guidelines/privacy)
- [Monitoring the User's Proximity to Geographic Regions](https://developer.apple.com/documentation/corelocation/monitoring_the_user_s_proximity_to_geographic_regions)