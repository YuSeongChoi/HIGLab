# TipShowcase

iOS 17+ **TipKit** 프레임워크의 다양한 사용법을 보여주는 샘플 프로젝트입니다.

## 📱 스크린샷

| 인라인 팁 | 팝오버 팁 | 이벤트 팁 | 설정 |
|:---:|:---:|:---:|:---:|
| TipView | .popoverTip() | 조건부 표시 | 리셋 도구 |

## 🎯 프로젝트 목표

- TipKit의 핵심 개념 이해
- 다양한 팁 표시 방식 학습
- 이벤트 기반 팁 조건 설정
- 팁 데이터 관리 및 디버깅

## 📂 프로젝트 구조

```
TipShowcase/
├── Shared/
│   ├── AppTips.swift        # Tip 프로토콜 구현체들
│   └── TipEvents.swift      # Tips.Event 정의
│
├── TipShowcaseApp/
│   ├── TipShowcaseApp.swift # 앱 엔트리, Tips.configure()
│   ├── ContentView.swift    # 메인 탭뷰
│   ├── InlineTipView.swift  # TipView 인라인 예제
│   ├── PopoverTipView.swift # .popoverTip() 예제
│   ├── EventTipView.swift   # 이벤트 기반 팁 예제
│   └── SettingsView.swift   # 팁 리셋 및 디버그
│
└── README.md
```

## 🔧 핵심 개념

### 1. Tip 프로토콜

```swift
struct FavoriteTip: Tip {
    var title: Text { Text("즐겨찾기 추가") }
    var message: Text? { Text("하트 버튼을 눌러 즐겨찾기에 추가하세요.") }
    var image: Image? { Image(systemName: "heart.fill") }
}
```

### 2. TipKit 초기화

```swift
try Tips.configure([
    .displayFrequency(.immediate),  // 팁 표시 빈도
    .datastoreLocation(.applicationDefault)  // 저장 위치
])
```

### 3. 인라인 팁 (TipView)

```swift
TipView(favoriteTip)
    .tipBackground(.blue.opacity(0.1))
```

### 4. 팝오버 팁

```swift
Button("공유하기") { ... }
    .popoverTip(shareTip, arrowEdge: .bottom)
```

### 5. 이벤트 기반 팁

```swift
struct ProTip: Tip {
    static let appOpenedEvent = Tips.Event(id: "appOpened")
    
    var rules: [Rule] {
        #Rule(Self.appOpenedEvent) { event in
            event.donations.count >= 3  // 3회 이상 발생 시 표시
        }
    }
}

// 이벤트 기록
await ProTip.appOpenedEvent.donate()
```

### 6. 액션 버튼 팁

```swift
struct ActionTip: Tip {
    var actions: [Action] {
        Action(id: "learn-more", title: "자세히 보기")
        Action(id: "dismiss", title: "닫기")
    }
}

// 액션 처리
TipView(actionTip) { action in
    switch action.id {
    case "learn-more": // 처리
    default: break
    }
}
```

### 7. 팁 무효화

```swift
// 사용자가 액션을 수행한 경우
tip.invalidate(reason: .actionPerformed)

// 사용자가 팁을 닫은 경우
tip.invalidate(reason: .tipClosed)

// 더 이상 관련이 없는 경우
tip.invalidate(reason: .displayCountExceeded)
```

### 8. 팁 리셋 (디버깅)

```swift
// 모든 팁 데이터 초기화
try Tips.resetDatastore()
```

## 📋 시스템 요구사항

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## 🎓 학습 포인트

1. **Tip 프로토콜**: 팁의 기본 구조 이해
2. **Rules**: 팁 표시 조건 설정
3. **Events**: 사용자 행동 추적 및 조건부 팁
4. **Actions**: 사용자 상호작용 처리
5. **invalidate()**: 팁 상태 관리
6. **Tips.configure()**: 전역 설정

## 📚 관련 자료

- [Apple TipKit Documentation](https://developer.apple.com/documentation/tipkit)
- [WWDC23: Make features discoverable with TipKit](https://developer.apple.com/videos/play/wwdc2023/10229/)
- [Human Interface Guidelines: Onboarding](https://developer.apple.com/design/human-interface-guidelines/onboarding)

## ⚠️ 주의사항

- TipKit은 iOS 17 이상에서만 사용 가능합니다.
- 시뮬레이터에서 팁이 표시되지 않으면 `Tips.resetDatastore()`를 호출하세요.
- 프로덕션에서는 `.displayFrequency(.daily)` 등 적절한 빈도를 설정하세요.

---

Made with ❤️ for HIG Lab
