# TipShowcase

iOS 17+ **TipKit** 프레임워크의 모든 기능을 시연하는 시니어급 샘플 프로젝트입니다.

## 📱 주요 기능

| 인라인 팁 | 팝오버 팁 | 이벤트 기반 | 온보딩 | 조건부 | 설정 |
|:---:|:---:|:---:|:---:|:---:|:---:|
| TipView | .popoverTip() | #Rule | 시퀀스 | @Parameter | 디버그 |

## 🎯 프로젝트 목표

- TipKit의 **모든 핵심 API** 완벽 시연
- 시니어 개발자 수준의 코드 품질
- 실제 프로덕션에서 사용 가능한 패턴
- 한글 주석으로 학습 용이성 확보

## 📂 프로젝트 구조

```
TipShowcase/
├── Shared/                           # 공유 모듈
│   ├── TipConfiguration.swift        # Tips.configure() 설정 관리자
│   ├── TipParameters.swift           # @Parameter 정의 (온보딩, 기능발견, 사용자설정, 시간기반)
│   ├── TipEvents.swift               # Tips.Event 정의 및 헬퍼
│   ├── TipDefinitions.swift          # 모든 Tip 프로토콜 구현체
│   └── TipGroups.swift               # 팁 그룹화 및 우선순위 관리
│
├── TipShowcaseApp/                   # 앱 모듈
│   ├── TipShowcaseApp.swift          # 앱 진입점, TipKit 초기화
│   ├── ContentView.swift             # 메인 탭뷰, 공통 컴포넌트
│   ├── InlineTipView.swift           # TipView 인라인 팁 예제
│   ├── PopoverTipView.swift          # .popoverTip() 팝오버 예제
│   ├── EventTipView.swift            # 이벤트 기반 팁 (#Rule, donate)
│   ├── OnboardingView.swift          # 순차적 온보딩 시퀀스
│   ├── ConditionalTipView.swift      # 조건부 팁 (@Parameter 기반)
│   └── SettingsView.swift            # 설정, 디버그 도구, API 레퍼런스
│
└── README.md
```

## 🔧 TipKit API 완벽 가이드

### 1. Tips.configure() - 전역 설정

```swift
try Tips.configure([
    .displayFrequency(.immediate),     // .hourly, .daily, .weekly, .monthly
    .datastoreLocation(.applicationDefault)
])
```

### 2. Tip 프로토콜 - 기본 팁 정의

```swift
struct FavoriteTip: Tip {
    var title: Text { Text("즐겨찾기 추가") }
    var message: Text? { Text("하트 버튼을 눌러 즐겨찾기에 추가하세요.") }
    var image: Image? { Image(systemName: "heart.fill") }
    
    // 선택적: 액션 버튼
    var actions: [Action] {
        Action(id: "learn-more", title: "자세히 보기")
        Action(id: "dismiss", title: "닫기")
    }
    
    // 선택적: 표시 옵션
    var options: [TipOption] {
        MaxDisplayCount(3)  // 최대 3회 표시
    }
}
```

### 3. TipView - 인라인 팁 표시

```swift
// 기본 사용
TipView(favoriteTip)

// 배경 커스터마이징
TipView(favoriteTip)
    .tipBackground(Color.blue.opacity(0.1))

// 액션 처리
TipView(actionTip) { action in
    switch action.id {
    case "learn-more": openHelp()
    case "dismiss": dismissTip()
    default: break
    }
}
```

### 4. .popoverTip() - 팝오버 팁

```swift
Button("공유하기") { share() }
    .popoverTip(shareTip, arrowEdge: .bottom)
    // arrowEdge: .top, .bottom, .leading, .trailing
```

### 5. @Parameter - 규칙 파라미터

```swift
struct OnboardingParameters {
    @Parameter
    static var hasSeenWelcome: Bool = false
    
    @Parameter
    static var hasCompletedOnboarding: Bool = false
}

// 값 변경 시 관련 팁 규칙 자동 재평가
OnboardingParameters.hasSeenWelcome = true
```

### 6. Tips.Event - 이벤트 정의 및 기록

```swift
// 이벤트 정의
static let appLaunchedEvent = Tips.Event(id: "com.app.launched")

// 이벤트 기록 (donate)
await appLaunchedEvent.donate()
```

### 7. #Rule 매크로 - 조건부 규칙

```swift
struct ProTip: Tip {
    // 이벤트 기반 규칙
    var rules: [Rule] {
        #Rule(Self.appLaunchedEvent) { event in
            event.donations.count >= 3  // 3회 이상 발생 시 표시
        }
    }
}

struct BeginnerTip: Tip {
    // 파라미터 기반 규칙
    var rules: [Rule] {
        #Rule(UserSettings.$isNewUser) { $0 == true }
        #Rule(OnboardingParams.$hasSeenWelcome) { $0 == true }
    }
}
```

### 8. InvalidationReason - 팁 무효화

```swift
// 사용자가 팁에서 안내한 동작 수행
tip.invalidate(reason: .actionPerformed)

// 사용자가 팁을 직접 닫음
tip.invalidate(reason: .tipClosed)

// 표시 횟수 초과
tip.invalidate(reason: .displayCountExceeded)
```

### 9. Tips.resetDatastore() - 데이터 초기화

```swift
// 모든 팁 데이터 초기화 (디버그/테스트용)
try Tips.resetDatastore()
```

### 10. Tips.showAllTipsForTesting() - 테스트 모드

```swift
#if DEBUG
// 모든 팁 강제 표시 (규칙 무시)
Tips.showAllTipsForTesting()
#endif
```

## 📊 시나리오별 구현

### 온보딩 팁 시퀀스
```swift
// 1단계: 환영 → 2단계: 첫 기능 → 3단계: 두번째 기능 → 완료
// @Parameter로 각 단계 완료 추적, #Rule로 순차 표시
```

### 기능 발견 팁
```swift
// 사용자가 아직 사용하지 않은 기능에 대해 팁 표시
#Rule(FeatureParams.$hasUsedFavorites) { $0 == false }
```

### 이벤트 기반 팁 (3회 사용 후)
```swift
#Rule(Self.usageEvent) { $0.donations.count >= 3 }
```

### 조건부 팁 (설정에 따라)
```swift
#Rule(UserSettings.$isProUser) { $0 == true }
#Rule(TimeParams.$currentHour) { $0 >= 6 && $0 < 12 }  // 아침에만
```

### 팁 그룹화 및 우선순위
```swift
// TipGroupManager로 관련 팁 그룹화
// TipScheduler로 표시 순서 관리
// TipStatistics로 사용 통계 추적
```

## 📋 시스템 요구사항

- **iOS 17.0+** (TipKit 필수)
- Xcode 15.0+
- Swift 5.9+

## 📈 코드 통계

| 항목 | 수치 |
|:---|---:|
| 총 파일 수 | 13개 |
| 총 코드 줄 수 | 6,694줄 |
| Tip 정의 | 30개+ |
| 이벤트 정의 | 25개+ |
| 파라미터 정의 | 20개+ |

## 🎓 학습 포인트

1. **Tip 프로토콜**: 팁의 완전한 구조 (title, message, image, actions, rules, options)
2. **TipView vs .popoverTip()**: 인라인 vs 팝오버 사용 시기
3. **@Parameter**: 규칙에 사용되는 관찰 가능한 값
4. **Tips.Event**: 사용자 행동 추적 및 조건부 팁
5. **#Rule 매크로**: 복잡한 조건부 규칙 작성
6. **InvalidationReason**: 팁 상태 관리의 중요성
7. **그룹화 및 우선순위**: 프로덕션급 팁 관리
8. **디버그 도구**: 개발 효율성을 위한 도구

## 📚 관련 자료

- [Apple TipKit Documentation](https://developer.apple.com/documentation/tipkit)
- [WWDC23: Make features discoverable with TipKit](https://developer.apple.com/videos/play/wwdc2023/10229/)
- [Human Interface Guidelines: Onboarding](https://developer.apple.com/design/human-interface-guidelines/onboarding)

## ⚠️ 주의사항

- TipKit은 **iOS 17 이상**에서만 사용 가능
- 시뮬레이터에서 팁이 표시되지 않으면 `Tips.resetDatastore()` 호출
- 프로덕션에서는 `.displayFrequency(.daily)` 등 적절한 빈도 설정
- `showAllTipsForTesting()`은 개발/QA 환경에서만 사용

## 🏆 시니어급 코드 특징

- **SOLID 원칙** 준수
- **단일 책임**: 각 파일이 명확한 역할
- **의존성 주입**: EnvironmentObject 활용
- **확장성**: 새 팁 추가가 용이한 구조
- **테스트 용이성**: 모든 상태를 리셋 가능
- **문서화**: 모든 public API에 한글 주석

---

Made with ❤️ for HIG Lab | TipKit 완전 정복
