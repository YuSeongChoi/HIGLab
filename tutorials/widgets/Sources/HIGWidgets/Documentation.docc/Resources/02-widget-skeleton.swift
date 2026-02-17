import WidgetKit
import SwiftUI

// MARK: - Widget Entry
struct CurrentWeatherEntry: TimelineEntry {
    let date: Date
    let weather: WeatherData
}

// MARK: - Timeline Provider
struct CurrentWeatherProvider: TimelineProvider {
    func placeholder(in context: Context) -> CurrentWeatherEntry {
        CurrentWeatherEntry(date: .now, weather: .preview)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (CurrentWeatherEntry) -> Void) {
        completion(CurrentWeatherEntry(date: .now, weather: .preview))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<CurrentWeatherEntry>) -> Void) {
        let entry = CurrentWeatherEntry(date: .now, weather: .preview)
        let timeline = Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(900)))
        completion(timeline)
    }
}

// MARK: - Widget View
struct WeatherWidgetEntryView: View {
    let entry: CurrentWeatherEntry
    
    var body: some View {
        Text("날씨 위젯")
    }
}

// MARK: - Widget Configuration
struct WeatherWidget: Widget {
    let kind = "WeatherWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CurrentWeatherProvider()) { entry in
            WeatherWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("날씨")
        .description("현재 날씨와 예보를 확인하세요.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
