import WidgetKit
import SwiftUI

// MARK: - Configurable Widget
// AppIntentConfiguration으로 사용자 설정을 지원하는 위젯입니다.

struct WeatherWidget: Widget {
    let kind = "WeatherWidget"
    
    var body: some WidgetConfiguration {
        // AppIntentConfiguration: 설정 가능한 위젯
        // StaticConfiguration: 설정 없는 위젯
        AppIntentConfiguration(
            kind: kind,
            intent: SelectCityIntent.self,
            provider: CurrentWeatherProvider()
        ) { entry in
            WeatherWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    entry.weather.condition.gradient
                }
        }
        .configurationDisplayName("날씨")
        .description("선택한 도시의 현재 날씨와 예보를 확인하세요.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
        // 잠금 화면에서 배경 제거 (accessory 위젯용)
        .contentMarginsDisabled()
    }
}

// MARK: - Configurable Provider
// AppIntentTimelineProvider로 설정을 받아 처리합니다.

struct CurrentWeatherProvider: AppIntentTimelineProvider {
    typealias Entry = CurrentWeatherEntry
    typealias Intent = SelectCityIntent
    
    func placeholder(in context: Context) -> CurrentWeatherEntry {
        CurrentWeatherEntry(date: .now, weather: .preview)
    }
    
    func snapshot(for configuration: SelectCityIntent, in context: Context) async -> CurrentWeatherEntry {
        let weather = await WeatherService.shared.fetchWeather(for: configuration.city)
        return CurrentWeatherEntry(date: .now, weather: weather, configuration: configuration)
    }
    
    func timeline(for configuration: SelectCityIntent, in context: Context) async -> Timeline<CurrentWeatherEntry> {
        // 설정된 도시의 날씨 가져오기
        let weather = await WeatherService.shared.fetchWeather(for: configuration.city)
        
        let entry = CurrentWeatherEntry(
            date: .now,
            weather: weather,
            configuration: configuration
        )
        
        // 15분 후 갱신
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: .now)!
        
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
}

// MARK: - Entry View with Configuration
struct WeatherWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: CurrentWeatherEntry
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWeatherView(
                weather: entry.weather,
                unit: entry.configuration?.temperatureUnit ?? .celsius
            )
        case .systemMedium:
            MediumWeatherView(
                weather: entry.weather,
                showHourly: entry.configuration?.showHourlyForecast ?? true
            )
        case .systemLarge:
            LargeWeatherView(weather: entry.weather)
        default:
            SmallWeatherView(weather: entry.weather, unit: .celsius)
        }
    }
}

// MARK: - Views with Configuration Support
struct SmallWeatherView: View {
    let weather: WeatherData
    let unit: TemperatureUnit
    
    var body: some View {
        VStack(alignment: .leading) {
            Image(systemName: weather.condition.symbol)
                .symbolRenderingMode(.multicolor)
            
            Spacer()
            
            // 설정된 단위로 온도 표시
            Text(unit.format(weather.temperature))
                .font(.system(size: 32, weight: .light))
            
            Text(weather.cityName)
                .font(.caption)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}
