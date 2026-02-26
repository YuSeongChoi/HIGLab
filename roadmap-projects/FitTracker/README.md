# 🚴 FitTracker

피트니스 추적 앱 통합 샘플 프로젝트입니다.

## 사용 프레임워크

| 프레임워크 | 용도 |
|-----------|------|
| **SwiftUI** | 선언적 UI |
| **HealthKit** | 건강 데이터 읽기/쓰기 |
| **MapKit** | 운동 경로 지도 표시 |
| **CoreLocation** | GPS 위치 추적 |
| **ActivityKit** | Live Activity (운동 중 표시) |
| **WidgetKit** | 홈화면 위젯 |

## 주요 기능

- 👟 걸음수/거리/칼로리 추적 (HealthKit)
- 🗺️ 운동 경로 지도 표시 (MapKit)
- 📍 실시간 위치 추적 (CoreLocation)
- 🏃 운동 중 Live Activity (ActivityKit)
- 📊 홈화면 건강 위젯 (WidgetKit)

## 프로젝트 구조

```
FitTracker/
├── FitTrackerApp.swift         # 앱 진입점
├── Models/
│   ├── Workout.swift           # 운동 데이터 모델
│   └── HealthStats.swift       # 건강 통계 모델
├── Views/
│   ├── DashboardView.swift     # 메인 대시보드
│   ├── WorkoutView.swift       # 운동 추적 화면
│   └── HistoryView.swift       # 운동 기록
├── Managers/
│   ├── HealthManager.swift     # HealthKit 관리
│   ├── LocationManager.swift   # 위치 추적 관리
│   └── ActivityManager.swift   # Live Activity 관리
└── Widget/
    └── FitWidget.swift         # 위젯 확장
```

## 필요 권한

- HealthKit 읽기/쓰기 권한
- 위치 서비스 권한 (항상 허용)
- Live Activity 권한

## Info.plist 키

```xml
<key>NSHealthShareUsageDescription</key>
<string>건강 데이터를 읽어 운동 기록을 표시합니다.</string>
<key>NSHealthUpdateUsageDescription</key>
<string>운동 기록을 건강 앱에 저장합니다.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>운동 경로를 기록합니다.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>백그라운드에서 운동 경로를 기록합니다.</string>
```

## 학습 포인트

1. **HealthKit 통합**: 건강 데이터 쿼리 및 저장
2. **실시간 위치 추적**: CoreLocation + MapKit 연동
3. **Live Activity**: 운동 중 Dynamic Island 표시
4. **WidgetKit**: 건강 데이터 위젯 구현
