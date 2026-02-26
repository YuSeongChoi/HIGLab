import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Timeline Entry

struct WeatherEntry: TimelineEntry {
    let date: Date
    let weather: WeatherData
}

// MARK: - Timeline Provider

struct WeatherProvider: AppIntentTimelineProvider {
    
    // 위젯 갤러리 미리보기용 (HIG: 로딩 스피너 대신 실제 형태 데이터)
    func placeholder(in context: Context) -> WeatherEntry {
        WeatherEntry(date: .now, weather: .preview)
    }
    
    // 위젯 추가 시 스냅샷
    func snapshot(for configuration: SelectCityIntent, in context: Context) async -> WeatherEntry {
        let weather = await WeatherService.shared.fetchWeather(for: configuration.city)
        return WeatherEntry(date: .now, weather: weather)
    }
    
    // 실제 타임라인 생성 — 15분 간격 갱신
    func timeline(for configuration: SelectCityIntent, in context: Context) async -> Timeline<WeatherEntry> {
        let weather = await WeatherService.shared.fetchWeather(for: configuration.city)
        let entry = WeatherEntry(date: .now, weather: weather)
        
        // HIG: 날씨 데이터는 15분 간격 갱신이 적절
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: .now)!
        
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
}

// MARK: - Widget Definition

struct WeatherWidget: Widget {
    let kind = "WeatherWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectCityIntent.self,
            provider: WeatherProvider()
        ) { entry in
            WeatherWidgetEntryView(entry: entry)
                // HIG: containerBackground로 배경 처리 (iOS 17+)
                .containerBackground(
                    entry.weather.condition.gradient,
                    for: .widget
                )
        }
        .configurationDisplayName("날씨")
        .description("현재 날씨와 시간별 예보를 확인하세요.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

// MARK: - Widget Bundle

@main
struct WeatherWidgetBundle: WidgetBundle {
    var body: some Widget {
        WeatherWidget()
    }
}
