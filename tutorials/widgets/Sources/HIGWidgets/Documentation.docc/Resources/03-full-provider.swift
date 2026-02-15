import WidgetKit
import SwiftUI

// MARK: - Configurable Timeline Provider
// App Intent Configuration을 지원하는 Provider입니다.

struct WeatherProvider: AppIntentTimelineProvider {
    typealias Entry = WeatherEntry
    typealias Intent = SelectCityIntent
    
    func placeholder(in context: Context) -> WeatherEntry {
        WeatherEntry(date: .now, weather: .preview)
    }
    
    func snapshot(for configuration: SelectCityIntent, in context: Context) async -> WeatherEntry {
        if context.isPreview {
            return WeatherEntry(date: .now, weather: .preview, configuration: configuration)
        }
        let weather = await WeatherService.shared.fetchWeather(for: configuration.city)
        return WeatherEntry(date: .now, weather: weather, configuration: configuration)
    }
    
    func timeline(for configuration: SelectCityIntent, in context: Context) async -> Timeline<WeatherEntry> {
        // 1. 선택된 도시의 날씨 데이터 가져오기
        let weather = await WeatherService.shared.fetchWeather(for: configuration.city)
        
        // 2. 현재 엔트리 생성
        let currentEntry = WeatherEntry(
            date: .now,
            weather: weather,
            configuration: configuration
        )
        
        // 3. 시간별 엔트리 생성 (1시간 간격, 6개)
        var entries: [WeatherEntry] = [currentEntry]
        
        for hourOffset in 1..<6 {
            let entryDate = Calendar.current.date(
                byAdding: .hour,
                value: hourOffset,
                to: .now
            )!
            
            // 시간별로 다른 데이터를 미리 계산해둘 수 있습니다
            let hourlyWeather = weather.shifting(byHours: hourOffset)
            entries.append(WeatherEntry(
                date: entryDate,
                weather: hourlyWeather,
                configuration: configuration
            ))
        }
        
        // 4. 타임라인 정책: 마지막 엔트리 이후 자동 갱신
        return Timeline(entries: entries, policy: .atEnd)
    }
}
