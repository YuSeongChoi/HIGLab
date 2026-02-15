import WidgetKit
import SwiftUI

// MARK: - Widget Entry
struct WeatherEntry: TimelineEntry {
    let date: Date
    let weather: WeatherData
}

// MARK: - Timeline Provider
struct WeatherProvider: TimelineProvider {
    func placeholder(in context: Context) -> WeatherEntry {
        WeatherEntry(date: .now, weather: .preview)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WeatherEntry) -> Void) {
        completion(WeatherEntry(date: .now, weather: .preview))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherEntry>) -> Void) {
        let entry = WeatherEntry(date: .now, weather: .preview)
        let timeline = Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(900)))
        completion(timeline)
    }
}

// MARK: - Widget View
struct WeatherWidgetEntryView: View {
    let entry: WeatherEntry
    
    var body: some View {
        Text("날씨 위젯")
    }
}

// MARK: - Widget Configuration
struct WeatherWidget: Widget {
    let kind = "WeatherWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WeatherProvider()) { entry in
            WeatherWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("날씨")
        .description("현재 날씨와 예보를 확인하세요.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
