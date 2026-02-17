# DeliveryTracker 🚴‍♂️

ActivityKit을 활용한 배달 추적 Live Activity 샘플 프로젝트입니다.

## 📱 기능

- **Live Activity**: 잠금화면에서 실시간 배달 상태 확인
- **Dynamic Island**: iPhone 14 Pro 이상에서 배달 진행 상황 표시
- **StandBy 지원**: 가로 충전 모드에서도 배달 상태 확인

## 🏗️ 프로젝트 구조

```
DeliveryTracker/
├── Shared/                         # 앱과 Extension 공유 코드
│   ├── DeliveryAttributes.swift    # ActivityAttributes 정의
│   └── DeliveryState.swift         # ContentState (동적 상태)
│
├── DeliveryTrackerApp/             # 메인 앱
│   ├── DeliveryTrackerApp.swift    # @main 진입점
│   ├── ContentView.swift           # 주문 시뮬레이션 UI
│   └── OrderStatusView.swift       # 주문 상태 카드 뷰
│
└── DeliveryTrackerExtension/       # Widget Extension
    ├── DeliveryLiveActivity.swift  # Live Activity 메인
    ├── LockScreenView.swift        # 잠금화면 뷰
    └── DynamicIslandView.swift     # 다이나믹 아일랜드 뷰
```

## 🔑 핵심 개념

### ActivityAttributes

Live Activity의 데이터 모델을 정의합니다:

```swift
struct DeliveryAttributes: ActivityAttributes {
    // 정적 데이터 (Activity 생성 시 설정, 변경 불가)
    let orderNumber: String
    let restaurantName: String
    
    // 동적 데이터 타입 지정
    typealias ContentState = DeliveryState
}
```

### ContentState

Activity가 실행되는 동안 업데이트될 수 있는 동적 데이터:

```swift
struct DeliveryState: Codable, Hashable {
    let status: DeliveryStatus
    let remainingMinutes: Int
    let driverName: String?
}
```

### Activity 생명주기

```swift
// 1. Activity 시작
let activity = try Activity.request(
    attributes: attributes,
    content: ActivityContent(state: initialState, staleDate: nil)
)

// 2. 상태 업데이트
await activity.update(
    ActivityContent(state: newState, staleDate: nil)
)

// 3. Activity 종료
await activity.end(
    ActivityContent(state: finalState, staleDate: nil),
    dismissalPolicy: .default
)
```

## 🎨 Dynamic Island 레이아웃

### Compact 모드 (기본)
```
┌─────────────────────────────────────┐
│  [🍳]     [TrueDepth]     [10분]   │
│  Leading    Camera     Trailing    │
└─────────────────────────────────────┘
```

### Minimal 모드 (다른 Activity와 공존)
```
┌──────────────┐     ┌──────────────┐
│ [TrueDepth]  │     │  [Progress]  │
│   Camera     │     │   Circle     │
└──────────────┘     └──────────────┘
```

### Expanded 모드 (길게 눌렀을 때)
```
┌─────────────────────────────────────┐
│ [🚴]        맛있는 치킨집      [10분] │
│ Leading   Center/Camera   Trailing │
│                                     │
│  ═══════════════════●════════      │
│  ● 주문 ─── ● 조리 ─── ● 배달 ─── ○ 도착 │
│                                     │
│  👤 김배달 배달원          [📞]     │
│              Bottom                 │
└─────────────────────────────────────┘
```

## ⚙️ 설정 방법

### 1. Info.plist 설정

메인 앱의 `Info.plist`에 추가:
```xml
<key>NSSupportsLiveActivities</key>
<true/>
```

### 2. Widget Extension 생성

1. File → New → Target
2. "Widget Extension" 선택
3. "Include Live Activity" 체크

### 3. App Groups 설정 (선택)

앱과 Extension 간 데이터 공유가 필요한 경우:
1. Signing & Capabilities → + Capability
2. "App Groups" 추가
3. 동일한 그룹 ID 설정

## 🧪 테스트 방법

### 시뮬레이터
1. 앱 실행 후 "주문하기" 버튼 탭
2. 잠금화면에서 Live Activity 확인
3. "자동 진행" 토글로 상태 변화 시뮬레이션

### 실제 기기 (Dynamic Island)
- iPhone 14 Pro 이상 필요
- Dynamic Island 영역 길게 눌러 확장 모드 확인

## 📝 주요 API

| API | 설명 |
|-----|------|
| `Activity.request()` | Live Activity 시작 |
| `activity.update()` | 상태 업데이트 |
| `activity.end()` | Activity 종료 |
| `ActivityAuthorizationInfo().areActivitiesEnabled` | 권한 확인 |

## 🔗 참고 자료

- [Apple Developer: ActivityKit](https://developer.apple.com/documentation/activitykit)
- [Human Interface Guidelines: Live Activities](https://developer.apple.com/design/human-interface-guidelines/live-activities)
- [WWDC22: Meet ActivityKit](https://developer.apple.com/videos/play/wwdc2022/10184/)

## 📋 요구 사항

- iOS 16.1+
- Xcode 14.0+
- iPhone 14 Pro+ (Dynamic Island 기능)

---

**HIG Lab** 샘플 프로젝트
