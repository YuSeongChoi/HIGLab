# 🍎 HIGLab 10년차 Apple 개발자 코드 리뷰

> 리뷰어: 10년차 iOS 시니어 개발자 관점
> 리뷰일: 2026-02-17

---

## 📊 종합 평가

| 항목 | 점수 | 평가 |
|------|------|------|
| **코드 품질** | 8.5/10 | 시니어급 |
| **Swift 컨벤션** | 9/10 | 우수 |
| **아키텍처** | 8/10 | 양호 |
| **문서화** | 9/10 | 우수 |
| **접근성** | 6/10 | 개선 필요 |
| **테스트 가능성** | 7/10 | 양호 |

**총평: 8/10** - 프로덕션 수준의 학습 프로젝트. 실무에서 바로 사용 가능한 코드.

---

## ✅ 잘된 점 (Best Practices)

### 1. Swift Concurrency 활용
```swift
// WeatherService.swift - Actor 패턴 우수 사례
actor WeatherService {
    static let shared = WeatherService()
    private var weatherCache: [CityOption: CachedWeather] = [:]
    
    func fetchWeather(for city: CityOption) async -> WeatherData {
        if let cached = weatherCache[city], !cached.isExpired(minutes: 10) {
            return cached.data
        }
        // ...
    }
}
```
- ✅ Actor로 thread-safety 보장
- ✅ async/await 일관된 사용
- ✅ Task 기반 백그라운드 작업

### 2. 열거형 활용
```swift
// BiometryType - 완벽한 열거형 설계
enum BiometryType: String, CaseIterable, Identifiable, Codable {
    case faceID, touchID, opticID, none
    
    var displayName: String { ... }
    var iconName: String { ... }
    var color: Color { ... }
}
```
- ✅ CaseIterable, Identifiable, Codable 준수
- ✅ 표시 로직 캡슐화
- ✅ @unknown default 처리

### 3. 문서화
```swift
/// 날씨 데이터 제공 서비스 (Actor로 thread-safe 보장)
actor WeatherService {
    /// 도시별 날씨 데이터 가져오기
    /// - Parameter city: 조회할 도시
    /// - Returns: 날씨 데이터
    func fetchWeather(for city: CityOption) async -> WeatherData
}
```
- ✅ /// 문서화 주석 일관성
- ✅ MARK 섹션 분리
- ✅ 파라미터/리턴 설명

### 4. SwiftUI 베스트 프랙티스
```swift
// ContentView.swift - 깔끔한 구조
struct ContentView: View {
    @State private var currentActivity: Activity<DeliveryAttributes>?
    @State private var currentState: DeliveryState = .previewOrdered
    
    var body: some View {
        NavigationStack {
            // View 컴포넌트 분리
            headerSection
            controlSection
            manualControlSection
        }
    }
    
    // MARK: - View Components
    private var headerSection: some View { ... }
    private var controlSection: some View { ... }
}
```
- ✅ 뷰 컴포넌트 분리
- ✅ @State/@Binding 적절한 사용
- ✅ Preview 지원

### 5. 에러 처리
```swift
// BiometricStatus - LAError 케이스별 처리
switch laError.code {
case .biometryNotAvailable:
    return .notAvailable
case .biometryNotEnrolled:
    return .notEnrolled(biometryType)
case .biometryLockout:
    return .lockedOut(biometryType)
case .passcodeNotSet:
    return .passcodeNotSet
default:
    return .notAvailable
}
```
- ✅ 구체적인 에러 타입 처리
- ✅ 사용자 친화적 에러 메시지

### 6. Foundation Models Tool 구현
```swift
// WeatherTool.swift - 최신 API 활용
@Generable
struct WeatherTool: Tool {
    static let name = "weather"
    static let description = "날씨 정보를 가져옵니다"
    
    struct Arguments: Codable, Sendable {
        @Guide(description: "도시 이름")
        let city: String
    }
    
    func call(arguments: Arguments) async throws -> String { ... }
}
```
- ✅ iOS 26 Foundation Models 정확한 사용
- ✅ Sendable 준수
- ✅ @Guide 어노테이션

---

## ⚠️ 개선 필요 사항

### 1. 접근성 (Accessibility) - 중요도: 높음
**현재 문제**: 접근성 레이블 부족

```swift
// ❌ 현재
Button {
    startOrder()
} label: {
    Label("주문하기", systemImage: "cart.fill")
}

// ✅ 개선
Button {
    startOrder()
} label: {
    Label("주문하기", systemImage: "cart.fill")
}
.accessibilityLabel("새 배달 주문 시작")
.accessibilityHint("탭하면 Live Activity가 시작됩니다")
```

**권장 사항**:
- 모든 인터랙티브 요소에 accessibilityLabel 추가
- 상태 변화 시 accessibilityValue 업데이트
- Dynamic Type 지원 확인

### 2. 로컬라이제이션 - 중요도: 중간
**현재 문제**: 하드코딩된 한글 문자열

```swift
// ❌ 현재
Text("배달 추적")

// ✅ 개선
Text("delivery_tracking", bundle: .main)
// 또는
Text(String(localized: "delivery_tracking"))
```

**권장 사항**:
- String Catalog (Localizable.xcstrings) 활용
- 숫자/날짜 포맷터 Locale 적용

### 3. 의존성 주입 - 중요도: 중간
**현재 문제**: 싱글톤 직접 사용으로 테스트 어려움

```swift
// ❌ 현재
let weather = await WeatherService.shared.fetchWeather(for: city)

// ✅ 개선 (프로토콜 기반)
protocol WeatherServiceProtocol {
    func fetchWeather(for city: CityOption) async -> WeatherData
}

@Observable
class WeatherViewModel {
    private let service: WeatherServiceProtocol
    
    init(service: WeatherServiceProtocol = WeatherService.shared) {
        self.service = service
    }
}
```

### 4. 에러 타입 통일 - 중요도: 낮음
**권장**: 각 도메인별 커스텀 Error 타입 정의

```swift
// 권장 패턴
enum DeliveryError: LocalizedError {
    case activityNotSupported
    case activityCreationFailed(underlying: Error)
    case updateFailed
    
    var errorDescription: String? {
        switch self {
        case .activityNotSupported:
            return "Live Activity를 사용할 수 없습니다"
        case .activityCreationFailed(let error):
            return "Activity 생성 실패: \(error.localizedDescription)"
        case .updateFailed:
            return "상태 업데이트에 실패했습니다"
        }
    }
}
```

### 5. Preview 데이터 분리 - 중요도: 낮음
```swift
// 권장: PreviewContent.swift 파일로 분리
#if DEBUG
extension WeatherData {
    static let preview = WeatherData(...)
    static let rainyPreview = WeatherData(...)
}
#endif
```

---

## 🎯 샘플별 주요 강점

| 샘플 | 주요 강점 | 학습 포인트 |
|------|----------|------------|
| WeatherWidget | Actor 캐싱, Timeline | WidgetKit 전체 패턴 |
| DeliveryTracker | Live Activity 전체 구현 | Dynamic Island, Lock Screen |
| SecureVault | LAError 완벽 처리 | 생체인증 + Keychain |
| AIChatbot | Foundation Models Tool | @Generable, @Guide |
| TaskMaster | SwiftData @Model | CRUD 패턴 |
| BLEScanner | CoreBluetooth delegate | 비동기 스캔/연결 |

---

## 📝 최종 권장사항

### 즉시 적용 (Quick Wins)
1. ✅ 모든 Button에 accessibilityLabel 추가
2. ✅ 주요 뷰에 accessibilityIdentifier 추가 (UI 테스트용)
3. ✅ Preview 데이터 #if DEBUG로 감싸기

### 중기 개선
1. 📋 String Catalog로 문자열 관리
2. 📋 프로토콜 기반 서비스 레이어
3. 📋 도메인별 Error 타입 정의

### 장기 개선
1. 🔮 Unit Test 추가
2. 🔮 UI Test 추가
3. 🔮 SwiftLint 규칙 적용

---

## 🏆 결론

**HIGLab 샘플 프로젝트는 8/10 시니어급 코드 품질**을 보여줍니다.

특히 다음 영역에서 우수합니다:
- Swift Concurrency (Actor, async/await)
- 열거형 기반 상태 관리
- /// 문서화 일관성
- 최신 Apple API 활용 (iOS 26 Foundation Models 등)

접근성과 로컬라이제이션 강화를 권장하며, 이 수준의 코드는 **실무 프로젝트의 참고 자료로 충분히 활용 가능**합니다.

---

*리뷰 작성: 2026-02-17*
