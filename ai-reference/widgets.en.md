# WidgetKit AI Reference

> iOS Home Screen/Lock Screen widget implementation guide. Read this document to generate widget code.

## Overview

WidgetKit is a framework for creating widgets that display app content on the Home Screen and Lock Screen.
Widgets operate on a **Timeline basis**, where the system updates content at scheduled times.

## Required Import

```swift
import WidgetKit
import SwiftUI
```

## Core Components

### 1. Widget Protocol (Entry Point)

```swift
@main
struct MyWidget: Widget {
    let kind: String = "MyWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MyProvider()) { entry in
            MyWidgetView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("Widget description")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
```

### 2. TimelineEntry (Data Model)

```swift
struct MyEntry: TimelineEntry {
    let date: Date  // Required
    let title: String
    let value: Int
}
```

### 3. TimelineProvider (Data Provider)

```swift
struct MyProvider: TimelineProvider {
    // For widget gallery preview
    func placeholder(in context: Context) -> MyEntry {
        MyEntry(date: Date(), title: "Title", value: 0)
    }
    
    // Preview when adding widget
    func getSnapshot(in context: Context, completion: @escaping (MyEntry) -> Void) {
        let entry = MyEntry(date: Date(), title: "Snapshot", value: 42)
        completion(entry)
    }
    
    // Create actual timeline
    func getTimeline(in context: Context, completion: @escaping (Timeline<MyEntry>) -> Void) {
        var entries: [MyEntry] = []
        let currentDate = Date()
        
        // Create 5 entries that update every hour
        for hourOffset in 0..<5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = MyEntry(date: entryDate, title: "Item \(hourOffset)", value: hourOffset * 10)
            entries.append(entry)
        }
        
        // .atEnd: Request new timeline after last entry
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}
```

### 4. Widget View (SwiftUI View)

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

## Complete Working Example: Weather Widget

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
        WeatherEntry(date: Date(), city: "Seoul", temperature: 20, condition: "Clear", icon: "sun.max.fill")
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WeatherEntry) -> Void) {
        let entry = WeatherEntry(date: Date(), city: "Seoul", temperature: 23, condition: "Partly Cloudy", icon: "cloud.sun.fill")
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherEntry>) -> Void) {
        // In practice, make API call
        let entry = WeatherEntry(date: Date(), city: "Seoul", temperature: 25, condition: "Clear", icon: "sun.max.fill")
        
        // Refresh after 15 minutes
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
        .configurationDisplayName("Weather")
        .description("Check current weather")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    WeatherWidget()
} timeline: {
    WeatherEntry(date: Date(), city: "Seoul", temperature: 25, condition: "Clear", icon: "sun.max.fill")
}
```

## Interactive Widgets (iOS 17+)

```swift
import AppIntents

// Define button action
struct RefreshIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh"
    
    func perform() async throws -> some IntentResult {
        // Data refresh logic
        WidgetCenter.shared.reloadTimelines(ofKind: "WeatherWidget")
        return .result()
    }
}

// Use in view
struct InteractiveWidgetView: View {
    var body: some View {
        Button(intent: RefreshIntent()) {
            Label("Refresh", systemImage: "arrow.clockwise")
        }
    }
}
```

## Configurable Widgets (AppIntentConfiguration)

```swift
import AppIntents

// Define configuration options
struct CitySelection: AppIntent, WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select City"
    
    @Parameter(title: "City")
    var city: String?
    
    static var parameterSummary: some ParameterSummary {
        Summary("Selected city: \(\.$city)")
    }
}

// Modify Provider
struct ConfigurableProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> WeatherEntry { ... }
    
    func snapshot(for configuration: CitySelection, in context: Context) async -> WeatherEntry { ... }
    
    func timeline(for configuration: CitySelection, in context: Context) async -> Timeline<WeatherEntry> {
        let city = configuration.city ?? "Seoul"
        // Fetch data using city
        ...
    }
}

// Modify Widget
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

## Lock Screen Widgets

```swift
.supportedFamilies([
    .systemSmall,
    .systemMedium,
    .accessoryCircular,    // Lock Screen circular
    .accessoryRectangular, // Lock Screen rectangular
    .accessoryInline       // Lock Screen inline (above clock)
])

// Lock Screen view
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
                Text("Seoul")
                    .font(.headline)
                Text("25°")
                    .font(.title)
            }
            
        case .accessoryInline:
            Label("Seoul 25°", systemImage: "sun.max.fill")
            
        default:
            EmptyView()
        }
    }
}
```

## Important Notes

1. **Widgets are not apps**: Cannot run independently, tapping opens the app
2. **Timeline-based**: Not real-time updates, system refreshes at scheduled times
3. **Memory limitations**: Small memory allocation, avoid heavy operations
4. **containerBackground required** (iOS 17+): `.containerBackground(for: .widget)`
5. **Widget Extension target required**: File > New > Target > Widget Extension

## Widget Refresh Triggers

```swift
// Refresh specific widget
WidgetCenter.shared.reloadTimelines(ofKind: "MyWidget")

// Refresh all widgets
WidgetCenter.shared.reloadAllTimelines()
```

## File Structure

```
MyApp/
├── MyApp/
│   └── MyApp.swift
└── MyWidgetExtension/
    ├── MyWidget.swift
    ├── MyWidgetBundle.swift (for multiple widgets)
    └── Assets.xcassets
```
