import WidgetKit
import SwiftUI

// MARK: - Final Weather Widget
// 모든 크기(Small/Medium/Large + Lock Screen)를 지원하는 완성된 위젯입니다.

@main
struct WeatherWidgetBundle: WidgetBundle {
    var body: some Widget {
        WeatherWidget()
        // 추가 위젯이 있다면 여기에
        // WeatherForecastWidget()
    }
}

struct WeatherWidget: Widget {
    let kind = "WeatherWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectCityIntent.self,
            provider: CurrentWeatherProvider()
        ) { entry in
            WeatherWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    // 홈 화면 위젯: 그래디언트 배경
                    // 잠금 화면 위젯: 시스템이 자동 처리
                    entry.weather.condition.gradient
                }
        }
        .configurationDisplayName("날씨")
        .description("선택한 도시의 현재 날씨와 예보를 확인하세요.")
        .supportedFamilies([
            // 홈 화면 위젯
            .systemSmall,
            .systemMedium,
            .systemLarge,
            // 잠금 화면 위젯
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

// MARK: - Entry View
struct WeatherWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    @Environment(\.widgetRenderingMode) var renderingMode
    let entry: CurrentWeatherEntry
    
    var body: some View {
        switch family {
        // MARK: Home Screen Widgets
        case .systemSmall:
            SmallWeatherView(weather: entry.weather)
                .foregroundStyle(entry.weather.condition.textColor)
            
        case .systemMedium:
            MediumWeatherView(weather: entry.weather)
                .foregroundStyle(entry.weather.condition.textColor)
            
        case .systemLarge:
            LargeWeatherView(weather: entry.weather)
                .foregroundStyle(entry.weather.condition.textColor)
            
        // MARK: Lock Screen Widgets
        case .accessoryCircular:
            CircularWeatherView(weather: entry.weather)
            
        case .accessoryRectangular:
            RectangularWeatherView(weather: entry.weather)
            
        case .accessoryInline:
            InlineWeatherView(weather: entry.weather)
            
        // MARK: Fallback
        @unknown default:
            SmallWeatherView(weather: entry.weather)
        }
    }
}

// MARK: - Preview
#Preview("All Sizes", as: .systemSmall) {
    WeatherWidget()
} timeline: {
    CurrentWeatherEntry(date: .now, weather: .preview)
    CurrentWeatherEntry(date: .now.addingTimeInterval(3600), weather: .rainyPreview)
}

#Preview("Medium", as: .systemMedium) {
    WeatherWidget()
} timeline: {
    CurrentWeatherEntry(date: .now, weather: .preview)
}

#Preview("Large", as: .systemLarge) {
    WeatherWidget()
} timeline: {
    CurrentWeatherEntry(date: .now, weather: .preview)
}

#Preview("Lock Screen - Circular", as: .accessoryCircular) {
    WeatherWidget()
} timeline: {
    CurrentWeatherEntry(date: .now, weather: .preview)
}

#Preview("Lock Screen - Rectangular", as: .accessoryRectangular) {
    WeatherWidget()
} timeline: {
    CurrentWeatherEntry(date: .now, weather: .preview)
}

#Preview("Lock Screen - Inline", as: .accessoryInline) {
    WeatherWidget()
} timeline: {
    CurrentWeatherEntry(date: .now, weather: .preview)
}
