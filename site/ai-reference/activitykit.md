# ActivityKit AI Reference

> Live Activity와 Dynamic Island 구현 가이드. 이 문서를 읽고 Live Activity를 생성할 수 있습니다.

## 개요

ActivityKit은 잠금 화면과 Dynamic Island에 실시간 진행 상황을 표시하는 Live Activity를 만드는 프레임워크입니다.
배달 추적, 스포츠 경기, 타이머 등 **진행 중인 작업**에 적합합니다.

## 필수 Import

```swift
import ActivityKit
import WidgetKit
import SwiftUI
```

## 핵심 구성요소

### 1. ActivityAttributes (데이터 모델)

```swift
struct DeliveryAttributes: ActivityAttributes {
    // 정적 데이터 (Activity 생성 시 설정, 변경 불가)
    let orderNumber: String
    let restaurantName: String
    
    // 동적 데이터 (업데이트 가능)
    struct ContentState: Codable, Hashable {
        let status: DeliveryStatus
        let estimatedArrival: Date
        let driverName: String?
    }
}

enum DeliveryStatus: String, Codable {
    case ordered = "주문 완료"
    case preparing = "준비 중"
    case pickedUp = "픽업 완료"
    case delivering = "배달 중"
    case delivered = "배달 완료"
}
```

### 2. Live Activity Widget

```swift
struct DeliveryLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DeliveryAttributes.self) { context in
            // 잠금 화면 뷰
            LockScreenView(context: context)
        } dynamicIsland: { context in
            // Dynamic Island 뷰
            DynamicIsland {
                // Expanded (길게 누름)
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "bicycle")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.estimatedArrival, style: .timer)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.status.rawValue)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ProgressView(value: 0.7)
                }
            } compactLeading: {
                // Compact 좌측
                Image(systemName: "bicycle")
            } compactTrailing: {
                // Compact 우측
                Text(context.state.estimatedArrival, style: .timer)
            } minimal: {
                // Minimal (다른 Activity와 함께 표시)
                Image(systemName: "bicycle")
            }
        }
    }
}
```

### 3. 잠금 화면 뷰

```swift
struct LockScreenView: View {
    let context: ActivityViewContext<DeliveryAttributes>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "bicycle")
                    .foregroundStyle(.blue)
                Text(context.attributes.restaurantName)
                    .font(.headline)
                Spacer()
                Text(context.state.estimatedArrival, style: .timer)
                    .font(.title2.monospacedDigit())
            }
            
            Text(context.state.status.rawValue)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            ProgressView(value: progressValue)
                .tint(.blue)
        }
        .padding()
        .activityBackgroundTint(.black.opacity(0.8))
    }
    
    var progressValue: Double {
        switch context.state.status {
        case .ordered: return 0.2
        case .preparing: return 0.4
        case .pickedUp: return 0.6
        case .delivering: return 0.8
        case .delivered: return 1.0
        }
    }
}
```

## 전체 작동 예제

```swift
import ActivityKit
import SwiftUI

// MARK: - Attributes
struct DeliveryAttributes: ActivityAttributes {
    let orderNumber: String
    let restaurantName: String
    
    struct ContentState: Codable, Hashable {
        let status: String
        let remainingMinutes: Int
    }
}

// MARK: - Live Activity 시작
func startDeliveryActivity() {
    // 지원 여부 확인
    guard ActivityAuthorizationInfo().areActivitiesEnabled else {
        print("Live Activity 비활성화됨")
        return
    }
    
    let attributes = DeliveryAttributes(
        orderNumber: "12345",
        restaurantName: "맛있는 피자"
    )
    
    let initialState = DeliveryAttributes.ContentState(
        status: "주문 완료",
        remainingMinutes: 30
    )
    
    let content = ActivityContent(
        state: initialState,
        staleDate: Calendar.current.date(byAdding: .hour, value: 1, to: Date())
    )
    
    do {
        let activity = try Activity.request(
            attributes: attributes,
            content: content,
            pushType: nil  // 푸시 업데이트 시 .token
        )
        print("Activity 시작: \(activity.id)")
    } catch {
        print("Activity 시작 실패: \(error)")
    }
}

// MARK: - Live Activity 업데이트
func updateDeliveryActivity(activity: Activity<DeliveryAttributes>, newStatus: String, minutes: Int) async {
    let newState = DeliveryAttributes.ContentState(
        status: newStatus,
        remainingMinutes: minutes
    )
    
    let content = ActivityContent(state: newState, staleDate: nil)
    await activity.update(content)
}

// MARK: - Live Activity 종료
func endDeliveryActivity(activity: Activity<DeliveryAttributes>) async {
    let finalState = DeliveryAttributes.ContentState(
        status: "배달 완료",
        remainingMinutes: 0
    )
    
    let content = ActivityContent(state: finalState, staleDate: nil)
    
    await activity.end(
        content,
        dismissalPolicy: .default  // 즉시 사라짐. .after(Date()) 사용 가능
    )
}

// MARK: - 모든 Activity 조회
func getAllActivities() -> [Activity<DeliveryAttributes>] {
    return Activity<DeliveryAttributes>.activities
}
```

## Dynamic Island 레이아웃

### Compact (기본 상태)

```swift
compactLeading: {
    // 좌측: 아이콘
    Image(systemName: "bicycle")
        .foregroundStyle(.blue)
} compactTrailing: {
    // 우측: 핵심 정보
    Text("12분")
        .font(.caption.monospacedDigit())
}
```

### Minimal (다른 Activity와 공유)

```swift
minimal: {
    // 작은 원형 영역
    Image(systemName: "bicycle")
        .foregroundStyle(.blue)
}
```

### Expanded (길게 누름)

```swift
DynamicIsland {
    DynamicIslandExpandedRegion(.leading) {
        VStack(alignment: .leading) {
            Image(systemName: "bicycle")
                .font(.title)
            Text("배달 중")
                .font(.caption)
        }
    }
    
    DynamicIslandExpandedRegion(.trailing) {
        VStack(alignment: .trailing) {
            Text("12분")
                .font(.title2)
            Text("도착 예정")
                .font(.caption)
        }
    }
    
    DynamicIslandExpandedRegion(.center) {
        Text("맛있는 피자")
            .font(.headline)
    }
    
    DynamicIslandExpandedRegion(.bottom) {
        // 진행률 바, 버튼 등
        ProgressView(value: 0.7)
        
        // 인터랙티브 버튼 (iOS 17+)
        Button(intent: CallDriverIntent()) {
            Label("전화하기", systemImage: "phone.fill")
        }
    }
}
```

## Info.plist 설정

```xml
<key>NSSupportsLiveActivities</key>
<true/>
<key>NSSupportsLiveActivitiesFrequentUpdates</key>
<true/>
```

## 푸시 업데이트

```swift
// Activity 시작 시 푸시 토큰 요청
let activity = try Activity.request(
    attributes: attributes,
    content: content,
    pushType: .token
)

// 토큰 받기
for await tokenData in activity.pushTokenUpdates {
    let token = tokenData.map { String(format: "%02x", $0) }.joined()
    // 서버에 토큰 전송
}
```

## 주의사항

1. **시간 제한**: 최대 8시간 활성, 종료 후 4시간 유지
2. **Widget Extension 필요**: Live Activity는 Widget Extension에 구현
3. **Dynamic Island**: iPhone 14 Pro 이상만 지원 (잠금 화면은 모든 기기)
4. **업데이트 빈도**: 시스템이 throttle 할 수 있음
5. **백그라운드**: 앱이 백그라운드여도 푸시로 업데이트 가능

## 파일 구조

```
MyApp/
├── MyApp/
│   ├── MyApp.swift
│   └── ActivityManager.swift   # Activity 관리 로직
└── MyWidgetExtension/
    ├── MyLiveActivity.swift    # Live Activity Widget
    └── DeliveryAttributes.swift # 공유 모델 (앱과 공유)
```
