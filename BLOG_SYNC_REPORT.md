# HIGLab 블로그 ↔ 샘플 코드 동기화 보고서

**작성일**: 2026-02-17  
**검토 범위**: site/ 폴더 50개 블로그 HTML + samples/ 폴더 43개 샘플 프로젝트

---

## 📊 검토 요약

| 항목 | 상태 |
|------|------|
| 총 블로그 파일 | 50개 |
| 총 샘플 프로젝트 | 43개 (7개 공유) |
| **불일치 발견** | **3건** |
| 링크 형식 불일치 | 2건 |
| 샘플 프로젝트 누락 | 0건 ✅ |

---

## 🔴 불일치 항목 (수정 필요)

### 1. Widgets - TimelineProvider API 버전 차이

**파일**: `site/widgets/01-weather-widget-challenge.html`  
**샘플**: `samples/WeatherWidget/`

| 블로그 코드 (구 버전) | 샘플 코드 (최신) |
|---|---|
| `struct WeatherProvider: TimelineProvider` | `struct CurrentWeatherProvider: AppIntentTimelineProvider` |
| `func getSnapshot(in:completion:)` | `func snapshot(for:in:) async` |
| `func getTimeline(in:completion:)` | `func timeline(for:in:) async` |

**문제**: 블로그는 iOS 16 이전의 completion handler 기반 `TimelineProvider`를 설명하고 있으나, 샘플 코드는 iOS 17+의 `AppIntentTimelineProvider` (async/await + App Intents 통합)를 사용합니다.

**권장 조치**: 블로그의 Ring 2 (TimelineProvider 구현) 섹션을 최신 `AppIntentTimelineProvider` API로 업데이트하거나, 두 방식 모두 설명하고 차이점을 명시.

---

### 2. Foundation Models - API 구조 차이

**파일**: `site/foundationmodels/01-ai-chatbot.html`  
**샘플**: `samples/AIChatbot/`

| 블로그 코드 | 샘플 코드 |
|---|---|
| `LanguageModel.default` | `SystemLanguageModel.default` |
| `model.generate(prompt:)` | `LanguageModelSession(instructions:)` |
| `model.streamGenerate(prompt:)` | `session.streamResponse(to:)` |

**문제**: 블로그는 간략화된 가상 API를 보여주고 있으나, 샘플은 실제 Foundation Models API인 `LanguageModelSession` 기반 구현을 사용합니다.

**권장 조치**: 블로그 코드를 실제 API에 맞게 수정:
```swift
// 수정 전
let model = LanguageModel.default
let result = try await model.generate(prompt: "안녕하세요")

// 수정 후  
let session = LanguageModelSession(instructions: "친절한 AI 어시스턴트")
let stream = session.streamResponse(to: "안녕하세요")
for try await partial in stream {
    print(partial.outputSoFar)
}
```

---

### 3. SwiftUI - ObservableObject vs @Observable

**파일**: `site/swiftui/01-tutorial.html`

**문제**: 블로그 끝부분에서 `ObservableObject` + `@Published` 패턴을 설명하고 있으나, iOS 17+에서는 `@Observable` 매크로가 권장됩니다.

```swift
// 블로그 (레거시)
class TodoViewModel: ObservableObject {
    @Published var todos: [Todo] = []
}

// 권장 (iOS 17+)
@Observable
class TodoViewModel {
    var todos: [Todo] = []
}
```

**권장 조치**: `observation/01-tutorial.html`로의 링크를 추가하여 최신 방식을 안내하거나, 두 방식의 차이를 명시.

---

## 🟡 링크 형식 불일치

### DocC 튜토리얼 링크 형식

일부 블로그 파일에서 DocC 링크 형식이 일관되지 않습니다:

| 파일 | 현재 형식 | 권장 형식 |
|---|---|---|
| `widgets/01-weather-widget-challenge.html` | `../widgets/documentation/higwidgets/tutorials/table-of-contents` | 절대 URL 권장 |
| `activitykit/01-delivery-tracker.html` | `../activitykit/documentation/higactivitykit/tutorials/table-of-contents` | 절대 URL 권장 |
| 기타 블로그 | `https://m1zz.github.io/HIGLab/tutorials/...` | ✅ 올바름 |

**권장 조치**: 모든 DocC 링크를 절대 URL 형식으로 통일:
```html
https://m1zz.github.io/HIGLab/tutorials/{tech}/documentation/hig{tech}/
```

---

## ✅ 검증 완료 항목

### 샘플 프로젝트 매핑 (SSOT.json 기준)

모든 50개 기술에 해당하는 샘플 프로젝트가 존재합니다:

| 기술 | 샘플 프로젝트 | 상태 |
|---|---|---|
| widgets | WeatherWidget | ✅ |
| activitykit | DeliveryTracker | ✅ |
| appintents | SiriTodo | ✅ |
| swiftui | TaskMaster | ✅ |
| swiftdata | TaskMaster (공유) | ✅ |
| observation | TaskMaster (공유) | ✅ |
| foundationmodels | AIChatbot | ✅ |
| storekit | SubscriptionApp | ✅ |
| ... | ... | ✅ |

### GitHub 링크

- 모든 블로그에서 `https://github.com/M1zz/HIGLab` 링크 확인됨 (116개 참조)
- Apple HIG 원문 링크 모두 유효

### API 일관성 검증 통과

- **StoreKit 2**: 블로그와 샘플 모두 최신 async/await API 사용 ✅
- **SwiftData**: 블로그와 샘플 모두 `@Model` 매크로 사용 ✅
- **Observation**: 블로그에서 `@Observable` 정확히 설명 ✅
- **TipKit**: 블로그와 샘플 일치 ✅
- **HealthKit**: 블로그와 샘플 일치 ✅
- **MapKit**: 블로그와 샘플 일치 ✅
- **ARKit**: 블로그와 샘플 일치 ✅

---

## 📝 수정 작업 우선순위

1. **높음** 🔴: Widgets 블로그 - AppIntentTimelineProvider로 업데이트
2. **높음** 🔴: Foundation Models 블로그 - 실제 API에 맞게 수정
3. **중간** 🟡: SwiftUI 블로그 - @Observable 언급 추가
4. **낮음** 🟢: DocC 링크 형식 통일

---

## 🔧 수정 완료 (이 보고서 생성 시점)

- 없음 (검토만 완료)

---

*이 보고서는 자동 검토 후 생성되었습니다.*
