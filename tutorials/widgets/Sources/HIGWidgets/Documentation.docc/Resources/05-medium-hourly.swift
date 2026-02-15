import SwiftUI
import WidgetKit

// MARK: - Hourly Forecast Component
// 재사용 가능한 시간별 예보 뷰 컴포넌트

struct HourlyForecastView: View {
    let hourly: HourlyWeather
    let isNow: Bool
    
    init(hourly: HourlyWeather, isNow: Bool = false) {
        self.hourly = hourly
        self.isNow = isNow
    }
    
    var body: some View {
        VStack(spacing: 6) {
            // 시간 라벨
            Text(isNow ? "지금" : hourly.hour)
                .font(.caption2)
                .foregroundStyle(isNow ? .primary : .secondary)
                .fontWeight(isNow ? .semibold : .regular)
            
            // 날씨 아이콘
            Image(systemName: hourly.condition.symbol)
                .symbolRenderingMode(.multicolor)
                .font(.body)
                .frame(height: 24)
            
            // 기온
            Text("\(hourly.temperature)°")
                .font(.caption)
                .fontWeight(.medium)
        }
        .frame(minWidth: 36)
    }
}

// MARK: - Medium Widget with Hourly Component
struct MediumWeatherView: View {
    let weather: WeatherData
    
    var body: some View {
        HStack(spacing: 16) {
            // 현재 날씨 섹션
            CurrentWeatherSection(weather: weather)
            
            Divider()
            
            // 시간별 예보 섹션
            HStack(spacing: 10) {
                ForEach(Array(weather.hourlyForecast.prefix(5).enumerated()), id: \.element.id) { index, hourly in
                    HourlyForecastView(hourly: hourly, isNow: index == 0)
                }
            }
        }
    }
}

struct CurrentWeatherSection: View {
    let weather: WeatherData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(weather.cityName)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Text("\(weather.temperature)°")
                .font(.system(size: 44, weight: .light, design: .rounded))
            
            Text(weather.condition.rawValue)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text("H:\(weather.highTemperature)° L:\(weather.lowTemperature)°")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
