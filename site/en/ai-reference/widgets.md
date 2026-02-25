# WidgetKit AI Reference

> iOS 홈 화면/잠금 화면 위젯 구현 가이드. 이 문서를 읽고 위젯 코드를 생성할 수 있습니다.

## 개요

WidgetKit은 홈 화면과 잠금 화면에 앱 콘텐츠를 표시하는 위젯을 만드는 프레임워크입니다.
위젯은 **Timeline 기반**으로 동작하며, 시스템이 정해진 시간에 콘텐츠를 갱신합니다.

## 필수 Import

```swift
import WidgetKit
import SwiftUI
```

## 핵심 구성요소

### 1. Widget 프로토콜 (진입점)

```swift
@main
struct MyWidget: Widget {
    let kind: String = "MyWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MyProvider()) { entry in
            MyWidgetView(entry: entry)
        }
        .configurationDisplayName("내 위젯")
        .description("위젯 설명")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
```

### 2. TimelineEntry (데이터 모델)

```swift
struct MyEntry: TimelineEntry {
    let date: Date  // 필수
    let title: String
    let value: Int
}
```

### 3. TimelineProvider (데이터 제공자)

```swift
struct MyProvider: TimelineProvider {
    // 위젯 갤러리 미리보기용
    func placeholder(in context: Context) -> MyEntry {
        MyEntry(date: Date(), title: "제목", value: 0)
    }
    
    // 위젯 추가 시 미리보기
    func getSnapshot(in context: Context, completion: @escaping (MyEntry) -> Void) {
        let entry = MyEntry(date: Date(), title: "스냅샷", value: 42)
        completion(entry)
    }
    
    // 실제 타임라인 생성
    func getTimeline(in context: Context, completion: @escaping (Timeline<MyEntry>) -> Void) {
        var entries: [MyEntry] = []
        let currentDate = Date()
        
        // 1시간마다 갱신되는 5개 엔트리 생성
        for hourOffset in 0..<5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = MyEntry(date: entryDate, title: "항목 \(hourOffset)", value: hourOffset * 10)
            entries.append(entry)
        }
        
        // .atEnd: 마지막 엔트리 후 새 타임라인 요청
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}
```

### 4. Widget View (SwiftUI 뷰)

```swift
struct MyWidgetView: View {
    var entry: MyEntry
    
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallView(entry: entry)
        case .systemMedium:
            MediumView(entry: entry)
        case .systemLarge:
            LargeView(entry: entry)
        default:
            SmallView(entry: entry)
        }
    }
}

struct SmallView: View {
    let entry: MyEntry
    
    var body: some View {
        VStack {
            Text(entry.title)
                .font(.headline)
            Text("\(entry.value)")
                .font(.largeTitle)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}
```

## 전체 작동 예제: 날씨 위젯

```swift
import WidgetKit
import SwiftUI

// MARK: - Entry
struct WeatherEntry: TimelineEntry {
    let date: Date
    let city: String
    let temperature: Int
    let condition: String
    let icon: String
}

// MARK: - Provider
struct WeatherProvider: TimelineProvider {
    func placeholder(in context: Context) -> WeatherEntry {
        WeatherEntry(date: Date(), city: "서울", temperature: 20, condition: "맑음", icon: "sun.max.fill")
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WeatherEntry) -> Void) {
        let entry = WeatherEntry(date: Date(), city: "서울", temperature: 23, condition: "구름 조금", icon: "cloud.sun.fill")
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherEntry>) -> Void) {
        // 실제로는 API 호출
        let entry = WeatherEntry(date: Date(), city: "서울", temperature: 25, condition: "맑음", icon: "sun.max.fill")
        
        // 15분 후 갱신
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - View
struct WeatherWidgetView: View {
    var entry: WeatherEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: entry.icon)
                    .font(.title)
                    .foregroundStyle(.yellow)
                Spacer()
            }
            
            Spacer()
            
            Text("\(entry.temperature)°")
                .font(.system(size: family == .systemSmall ? 40 : 56, weight: .bold))
            
            Text(entry.city)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .containerBackground(for: .widget) {
            LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom)
        }
    }
}

// MARK: - Widget
@main
struct WeatherWidget: Widget {
    let kind: String = "WeatherWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WeatherProvider()) { entry in
            WeatherWidgetView(entry: entry)
        }
        .configurationDisplayName("날씨")
        .description("현재 날씨를 확인하세요")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    WeatherWidget()
} timeline: {
    WeatherEntry(date: Date(), city: "서울", temperature: 25, condition: "맑음", icon: "sun.max.fill")
}
```

## 인터랙티브 위젯 (iOS 17+)

```swift
import AppIntents

// 버튼 액션 정의
struct RefreshIntent: AppIntent {
    static var title: LocalizedStringResource = "새로고침"
    
    func perform() async throws -> some IntentResult {
        // 데이터 갱신 로직
        WidgetCenter.shared.reloadTimelines(ofKind: "WeatherWidget")
        return .result()
    }
}

// 뷰에서 사용
struct InteractiveWidgetView: View {
    var body: some View {
        Button(intent: RefreshIntent()) {
            Label("새로고침", systemImage: "arrow.clockwise")
        }
    }
}
```

## 설정 가능한 위젯 (AppIntentConfiguration)

```swift
import AppIntents

// 설정 옵션 정의
struct CitySelection: AppIntent, WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "도시 선택"
    
    @Parameter(title: "도시")
    var city: String?
    
    static var parameterSummary: some ParameterSummary {
        Summary("선택한 도시: \(\.$city)")
    }
}

// Provider 수정
struct ConfigurableProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> WeatherEntry { ... }
    
    func snapshot(for configuration: CitySelection, in context: Context) async -> WeatherEntry { ... }
    
    func timeline(for configuration: CitySelection, in context: Context) async -> Timeline<WeatherEntry> {
        let city = configuration.city ?? "서울"
        // city를 사용해 데이터 가져오기
        ...
    }
}

// Widget 수정
struct ConfigurableWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: "ConfigurableWidget", 
                               intent: CitySelection.self, 
                               provider: ConfigurableProvider()) { entry in
            WeatherWidgetView(entry: entry)
        }
    }
}
```

## 잠금 화면 위젯

```swift
.supportedFamilies([
    .systemSmall,
    .systemMedium,
    .accessoryCircular,    // 잠금 화면 원형
    .accessoryRectangular, // 잠금 화면 직사각형
    .accessoryInline       // 잠금 화면 인라인 (시계 위)
])

// 잠금 화면용 뷰
struct LockScreenView: View {
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            Gauge(value: 0.7) {
                Image(systemName: "thermometer")
            }
            .gaugeStyle(.accessoryCircularCapacity)
            
        case .accessoryRectangular:
            VStack(alignment: .leading) {
                Text("서울")
                    .font(.headline)
                Text("25°")
                    .font(.title)
            }
            
        case .accessoryInline:
            Label("서울 25°", systemImage: "sun.max.fill")
            
        default:
            EmptyView()
        }
    }
}
```

## 주의사항

1. **위젯은 앱이 아님**: 독립 실행 불가, 탭하면 앱으로 이동
2. **Timeline 기반**: 실시간 업데이트 X, 시스템이 정해진 시간에 갱신
3. **메모리 제한**: 작은 메모리 할당, 무거운 작업 금지
4. **containerBackground 필수** (iOS 17+): `.containerBackground(for: .widget)`
5. **Widget Extension 타겟 필요**: File > New > Target > Widget Extension

## 위젯 갱신 트리거

```swift
// 특정 위젯 갱신
WidgetCenter.shared.reloadTimelines(ofKind: "MyWidget")

// 모든 위젯 갱신
WidgetCenter.shared.reloadAllTimelines()
```

## 파일 구조

```
MyApp/
├── MyApp/
│   └── MyApp.swift
└── MyWidgetExtension/
    ├── MyWidget.swift
    ├── MyWidgetBundle.swift (여러 위젯 시)
    └── Assets.xcassets
```
