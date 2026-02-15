import WidgetKit
import SwiftUI

// MARK: - Widget with Container Background
// iOS 17+ containerBackground modifier로 배경 처리
// 시스템이 다크모드, 틴트를 자동으로 처리합니다.

struct WeatherWidget: Widget {
    let kind = "WeatherWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectCityIntent.self,
            provider: WeatherProvider()
        ) { entry in
            WeatherWidgetEntryView(entry: entry)
                // HIG: containerBackground로 배경 처리
                // 이전의 padding + background 방식보다 권장됨
                .containerBackground(for: .widget) {
                    entry.weather.condition.gradient
                }
        }
        .configurationDisplayName("날씨")
        .description("현재 날씨와 예보를 확인하세요.")
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

// MARK: - Entry View with Family Switching
struct WeatherWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: WeatherEntry
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWeatherView(weather: entry.weather)
        case .systemMedium:
            MediumWeatherView(weather: entry.weather)
        case .systemLarge:
            LargeWeatherView(weather: entry.weather)
        case .accessoryCircular:
            CircularWeatherView(weather: entry.weather)
        case .accessoryRectangular:
            RectangularWeatherView(weather: entry.weather)
        case .accessoryInline:
            InlineWeatherView(weather: entry.weather)
        @unknown default:
            SmallWeatherView(weather: entry.weather)
        }
    }
}
