import SwiftUI
import WidgetKit

// MARK: - Accessory Rectangular Widget
// 잠금 화면 직사각형 위젯입니다.
// accessoryCircular보다 넓어서 도시명 + 기온 + 조건을 모두 표시할 수 있습니다.

struct RectangularWeatherView: View {
    let weather: WeatherData
    
    var body: some View {
        HStack(spacing: 8) {
            // 왼쪽: 날씨 아이콘
            Image(systemName: weather.condition.symbol)
                .font(.title)
                .symbolRenderingMode(.hierarchical)
                .frame(width: 36)
            
            // 오른쪽: 텍스트 정보
            VStack(alignment: .leading, spacing: 2) {
                // 도시명 + 기온
                HStack(spacing: 4) {
                    Text(weather.cityName)
                        .font(.headline)
                    Text("\(weather.temperature)°")
                        .font(.system(.headline, design: .rounded))
                }
                
                // 날씨 조건
                Text(weather.condition.rawValue)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                // 최고/최저
                Text("H:\(weather.highTemperature)° L:\(weather.lowTemperature)°")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Compact Version
struct RectangularWeatherCompactView: View {
    let weather: WeatherData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // 상단: 도시 + 아이콘
            HStack {
                Text(weather.cityName)
                    .font(.headline)
                Spacer()
                Image(systemName: weather.condition.symbol)
                    .symbolRenderingMode(.hierarchical)
            }
            
            // 하단: 기온 + 범위
            HStack(alignment: .lastTextBaseline) {
                Text("\(weather.temperature)°")
                    .font(.system(.title2, design: .rounded, weight: .medium))
                
                Spacer()
                
                Text("\(weather.condition.rawValue) · H:\(weather.highTemperature)° L:\(weather.lowTemperature)°")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - With Hourly Preview
struct RectangularWeatherWithHourlyView: View {
    let weather: WeatherData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // 상단: 현재 날씨
            HStack {
                Text(weather.cityName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(weather.temperature)° \(weather.condition.rawValue)")
                    .font(.caption)
            }
            
            // 하단: 다음 3시간 예보
            HStack(spacing: 12) {
                ForEach(weather.hourlyForecast.prefix(3)) { hourly in
                    VStack(spacing: 2) {
                        Text(hourly.hour)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Image(systemName: hourly.condition.symbol)
                            .symbolRenderingMode(.hierarchical)
                            .font(.caption)
                        Text("\(hourly.temperature)°")
                            .font(.caption2)
                    }
                }
            }
        }
    }
}

#Preview("Rectangular", as: .accessoryRectangular) {
    WeatherWidget()
} timeline: {
    WeatherEntry(date: .now, weather: .preview)
}
