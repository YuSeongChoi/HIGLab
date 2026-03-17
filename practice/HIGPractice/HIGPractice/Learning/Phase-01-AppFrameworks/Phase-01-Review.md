# Phase 01 Review - Beginner Notes

Phase 1에서 학습한 App Frameworks를 "초보자도 다시 읽으면 흐름이 잡히는 요약"으로 정리한다.

이 문서는 아래 질문에 답할 수 있도록 만드는 것이 목표다.

- 이 프레임워크는 왜 쓰는가
- 기존 방식과 무엇이 다른가
- 실제 앱에서는 어떤 코드 모양으로 쓰는가
- 어디서 많이 헷갈리는가

---

## 1. WidgetKit

### WidgetKit이란?
- 홈 화면, 잠금 화면, StandBy 등에 들어가는 위젯 UI를 만드는 프레임워크다.
- 앱 본체와 별개의 "작은 읽기 전용 화면"을 만든다고 생각하면 이해하기 쉽다.
- 위젯은 앱처럼 계속 살아서 움직이는 화면이 아니라, 시스템이 정해진 시점에 데이터를 받아 렌더링한다.

### 핵심 개념
- `TimelineEntry`
  - 특정 시점에 위젯이 보여줄 데이터 한 묶음이다.
- `TimelineProvider`
  - placeholder, snapshot, timeline을 만들어 시스템에 넘긴다.
- `WidgetFamily`
  - small, medium, large처럼 위젯 크기별 레이아웃 분기다.
- `AppIntentConfiguration`
  - 사용자가 위젯별 설정을 고를 수 있게 해준다.

### 예제 코드
```swift
import WidgetKit
import SwiftUI

struct WeatherEntry: TimelineEntry {
    let date: Date
    let cityName: String
    let temperature: Int
}

struct WeatherProvider: TimelineProvider {
    func placeholder(in context: Context) -> WeatherEntry {
        WeatherEntry(date: .now, cityName: "Seoul", temperature: 22)
    }

    func getSnapshot(in context: Context, completion: @escaping (WeatherEntry) -> Void) {
        completion(WeatherEntry(date: .now, cityName: "Seoul", temperature: 22))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherEntry>) -> Void) {
        let entry = WeatherEntry(date: .now, cityName: "Seoul", temperature: 22)
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: .now) ?? .now
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}
```

### 헷갈리기 쉬운 포인트
- 위젯은 앱처럼 자유롭게 네트워크 호출과 화면 갱신을 계속하지 않는다.
- `body`가 중요하다기보다, "언제 어떤 entry를 시스템에 넘길지"가 더 중요하다.
- family가 늘어나면 같은 데이터를 다른 밀도로 보여주는 설계가 필요하다.

---

## 2. ActivityKit

### ActivityKit이란?
- Live Activity를 만드는 프레임워크다.
- 배달, 운동, 경기, 택시처럼 "지금 진행 중인 일"을 잠금 화면과 Dynamic Island에 실시간에 가깝게 보여줄 때 쓴다.

### 핵심 개념
- `ActivityAttributes`
  - Live Activity가 어떤 종류의 활동인지 정의하는 타입이다.
- `ContentState`
  - 시간이 지나며 바뀌는 현재 상태값이다.
- `Activity.request`
  - Live Activity 시작.
- `activity.update`
  - Live Activity 상태 갱신.
- `activity.end`
  - Live Activity 종료.

### 예제 코드
```swift
import ActivityKit

struct DeliveryAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var statusText: String
        var progress: Double
    }

    var orderNumber: String
}

func startDeliveryActivity() throws {
    let attributes = DeliveryAttributes(orderNumber: "A-1024")
    let state = DeliveryAttributes.ContentState(statusText: "배달 출발", progress: 0.2)
    _ = try Activity.request(attributes: attributes, contentState: state)
}
```

### 헷갈리기 쉬운 포인트
- ActivityKit은 "앱 내부 화면"이 아니라 "시스템 영역 UI"다.
- 앱 코드와 위젯 코드가 역할을 나눠 가진다.
- 시작/업데이트/종료는 앱이 하지만, 실제 표시 UI는 위젯 확장에서 그린다.

---

## 3. App Intents

### App Intents란?
- 앱의 특정 기능을 Siri, Spotlight, Shortcuts 같은 시스템 기능에 노출하는 프레임워크다.
- "앱 안 버튼 탭"이 아니라 "시스템에서 앱 기능을 호출할 수 있게 만든다"가 핵심이다.

### 핵심 개념
- `AppIntent`
  - 시스템이 실행할 액션이다.
- `perform()`
  - 실제 동작을 수행하는 함수다.
- `AppShortcutsProvider`
  - 자주 쓰는 intent를 Shortcuts에 추천 형태로 노출한다.
- `@Parameter`
  - intent 실행에 필요한 입력값이다.

### 예제 코드
```swift
import AppIntents

struct AddTodoIntent: AppIntent {
    static var title: LocalizedStringResource = "할 일 추가"

    @Parameter(title: "제목")
    var title: String

    func perform() async throws -> some IntentResult {
        // 여기서 저장 로직 실행
        return .result()
    }
}
```

### 헷갈리기 쉬운 포인트
- App Intents는 UI를 그리는 프레임워크가 아니다.
- `perform()` 안에서는 "실제 기능 실행"에만 집중해야 한다.
- Siri/Shortcuts에 노출한다고 해서 앱 내부 구조가 자동으로 좋아지는 것은 아니고, 도메인 액션이 분리되어 있어야 다루기 쉽다.

---

## 4. SwiftUI

### SwiftUI란?
- Apple의 선언형 UI 프레임워크다.
- "이 상태일 때 화면이 이렇게 보인다"를 코드로 표현한다.
- UIKit처럼 화면을 직접 조작하기보다, 상태를 바꾸면 화면이 다시 계산되는 구조다.

### 핵심 개념
- `View`
  - 화면 조각 하나를 의미한다.
- `body`
  - 현재 상태를 기준으로 어떤 화면이 보여야 하는지 설명한다.
- `NavigationStack`
  - 화면 이동 구조를 만든다.
- `@State`
  - 뷰가 직접 소유하는 로컬 상태다.
- `Binding`
  - 다른 곳의 상태를 연결해 수정할 수 있게 해준다.

### 예제 코드
```swift
import SwiftUI

struct CounterView: View {
    @State private var count = 0

    var body: some View {
        VStack(spacing: 12) {
            Text("현재 값: \(count)")

            Button("증가") {
                count += 1
            }
        }
    }
}
```

### 헷갈리기 쉬운 포인트
- `body`는 한 번만 실행되는 함수처럼 보면 안 된다.
- SwiftUI에서는 "화면을 직접 바꾼다"보다 "상태를 바꾼다"가 더 중요하다.
- `@State`는 단순 변수처럼 보이지만, SwiftUI가 화면 생명주기와 연결해서 관리하는 값이다.

---

## 5. SwiftData

### SwiftData란?
- Apple이 만든 최신 로컬 데이터 저장 프레임워크다.
- Core Data보다 Swift 문법에 더 자연스럽게 녹아들도록 설계되었다.
- 핵심은 `@Model` 타입을 만들고, 그 객체를 앱 안에서 다루면 저장과 조회 흐름이 이어진다는 점이다.

### 핵심 개념
- `@Model`
  - 저장 가능한 모델 타입을 만든다.
- `ModelContainer`
  - 앱의 저장소 전체를 관리한다.
- `ModelContext`
  - 실제 insert, delete, save가 일어나는 작업 공간이다.
- `@Query`
  - 저장된 모델을 SwiftUI 뷰에서 읽는 가장 쉬운 방법이다.
- `@Bindable`
  - 모델 프로퍼티를 폼 입력 등에 바인딩할 때 쓴다.
- `@Relationship`
  - 모델 간 연결을 정의한다.

### 중요한 정리
- `@Model`은 class에 붙인다.
- 변경된 값은 context 안에서 추적되며, 저장 시점에 반영된다.
- 상황에 따라 자동 저장처럼 보일 수 있지만, "항상 자동 저장된다"라고 단순화해서 외우기보다 `ModelContext`가 변경을 추적하고 저장 타이밍이 있다는 점으로 이해하는 편이 안전하다.

### 예제 코드
```swift
import SwiftData

@Model
final class TaskItem {
    var title: String
    var isDone: Bool

    init(title: String, isDone: Bool = false) {
        self.title = title
        self.isDone = isDone
    }
}
```

```swift
import SwiftUI
import SwiftData

struct TaskListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [TaskItem]

    var body: some View {
        List(tasks) { task in
            Text(task.title)
        }
        .toolbar {
            Button("추가") {
                modelContext.insert(TaskItem(title: "새 할 일"))
            }
        }
    }
}
```

### FetchDescriptor는 언제 쓰나?
- `@Query`는 화면에서 바로 읽을 때 편하다.
- 하지만 서비스나 매니저에서 조건을 세밀하게 제어하며 직접 가져오고 싶을 때는 `FetchDescriptor`를 쓴다.

```swift
let descriptor = FetchDescriptor<TaskItem>(
    predicate: #Predicate { $0.isDone == false }
)

let activeTasks = try modelContext.fetch(descriptor)
```

### 헷갈리기 쉬운 포인트
- SwiftData는 "배열에 추가"가 아니라 "context에 insert"하는 구조다.
- `@Model`은 struct가 아니라 class에 붙인다.
- UI가 갱신되는 이유와 데이터가 저장되는 이유를 분리해서 봐야 한다.
  - UI 갱신: SwiftUI/Observation 계층
  - 저장: SwiftData 계층

---

## 6. Observation

### Observation이란?
- iOS 17+에서 사용할 수 있는 새로운 상태 관찰 프레임워크다.
- 기존 `ObservableObject` + `@Published` 조합을 더 자연스럽게 대체하는 방향으로 나왔다.
- 중요한 차이는 "객체 전체가 바뀌었다"보다 "어떤 프로퍼티를 읽었는지"를 더 정교하게 추적한다는 점이다.

### 핵심 개념
- `@Observable`
  - 상태 객체를 관찰 가능하게 만든다.
- `@State`
  - 뷰가 observable 객체를 직접 소유할 때 쓴다.
- `@Environment`
  - observable 객체를 하위 뷰에 공유할 때 쓴다.
- `@Bindable`
  - observable 객체의 프로퍼티를 양방향 바인딩할 때 쓴다.

### 예제 코드
```swift
import Observation

@Observable
final class CounterStore {
    var count = 0

    func increment() {
        count += 1
    }
}
```

```swift
import SwiftUI

struct CounterRootView: View {
    @State private var store = CounterStore()

    var body: some View {
        CounterContentView()
            .environment(store)
    }
}

struct CounterContentView: View {
    @Environment(CounterStore.self) private var store

    var body: some View {
        VStack(spacing: 12) {
            Text("값: \(store.count)")

            Button("증가") {
                store.increment()
            }
        }
    }
}
```

### 기존 ObservableObject와 무엇이 다른가?
- 예전 방식
  - `ObservableObject`
  - `@Published`
  - `@StateObject`
  - `@EnvironmentObject`
- Observation 방식
  - `@Observable`
  - 읽기 추적 기반 갱신
  - `@State`
  - `@Environment`

### 헷갈리기 쉬운 포인트
- Observation은 저장 프레임워크가 아니다.
- 비동기 작업을 대신 처리하는 프레임워크도 아니다.
- 핵심은 "누가 상태를 소유하는가"와 "어떤 뷰가 어떤 값을 읽는가"를 더 잘 표현하는 데 있다.

---

## 세 프레임워크를 한 번에 연결해서 보기

### SwiftUI + SwiftData + Observation 관계
- SwiftUI
  - 화면을 어떻게 표현할지 담당한다.
- SwiftData
  - 데이터를 어디에 저장하고 어떻게 불러올지 담당한다.
- Observation
  - 상태가 바뀔 때 어떤 뷰가 다시 그려질지 담당한다.

### 아주 짧게 요약하면
- SwiftUI = 화면
- SwiftData = 저장
- Observation = 상태 추적

---

## 지금 시점의 한 줄 정리

- WidgetKit: 시스템이 갱신 시점을 관리하는 위젯 UI
- ActivityKit: 진행 중인 활동을 시스템 영역에 띄우는 Live Activity
- App Intents: 앱 기능을 Siri/Shortcuts에 노출하는 액션 계층
- SwiftUI: 상태 기반 선언형 UI
- SwiftData: `@Model` 기반 로컬 저장
- Observation: 읽기 추적 기반 상태 관찰

이 문서는 "처음 다시 읽는 복습용" 문서다.
더 자세한 구현 메모는 각 프레임워크별 개별 문서를 참고한다.
