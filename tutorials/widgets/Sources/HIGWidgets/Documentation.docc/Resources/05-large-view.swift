import SwiftUI
import WidgetKit

// MARK: - Large Widget View
// HIG: Large는 가장 풍부한 정보 — 현재 + 시간별 + 주간 예보

struct LargeWeatherView: View {
    let weather: WeatherData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // MARK: 상단 - 현재 날씨
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(weather.cityName)
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("\(weather.temperature)°")
                        .font(.system(size: 54, weight: .thin, design: .rounded))
                        .contentTransition(.numericText())
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Image(systemName: weather.condition.symbol)
                        .font(.largeTitle)
                        .symbolRenderingMode(.multicolor)
                    
                    Text(weather.condition.rawValue)
                        .font(.callout)
                    
                    Text("H:\(weather.highTemperature)° L:\(weather.lowTemperature)°")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Divider()
            
            // MARK: 중단 - 시간별 예보
            HStack(spacing: 0) {
                ForEach(Array(weather.hourlyForecast.prefix(6).enumerated()), id: \.element.id) { index, hourly in
                    VStack(spacing: 8) {
                        Text(index == 0 ? "지금" : hourly.hour)
                            .font(.caption2)
                            .foregroundStyle(index == 0 ? .primary : .secondary)
                        
                        Image(systemName: hourly.condition.symbol)
                            .symbolRenderingMode(.multicolor)
                            .font(.title3)
                        
                        Text("\(hourly.temperature)°")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            
            Divider()
            
            // MARK: 하단 - 주간 예보
            VStack(spacing: 8) {
                ForEach(WeatherData.previewDaily.prefix(4)) { daily in
                    HStack {
                        Text(daily.day)
                            .font(.subheadline)
                            .frame(width: 40, alignment: .leading)
                        
                        Image(systemName: daily.condition.symbol)
                            .symbolRenderingMode(.multicolor)
                            .font(.body)
                            .frame(width: 30)
                        
                        Spacer()
                        
                        // 기온 범위 바
                        TemperatureRangeBar(
                            low: daily.lowTemperature,
                            high: daily.highTemperature,
                            globalLow: 15,
                            globalHigh: 30
                        )
                        .frame(width: 100)
                        
                        HStack(spacing: 4) {
                            Text("\(daily.lowTemperature)°")
                                .foregroundStyle(.secondary)
                            Text("\(daily.highTemperature)°")
                        }
                        .font(.caption)
                        .frame(width: 50, alignment: .trailing)
                    }
                }
            }
        }
    }
}

// MARK: - Temperature Range Bar
struct TemperatureRangeBar: View {
    let low: Int
    let high: Int
    let globalLow: Int
    let globalHigh: Int
    
    var body: some View {
        GeometryReader { geometry in
            let range = CGFloat(globalHigh - globalLow)
            let startRatio = CGFloat(low - globalLow) / range
            let endRatio = CGFloat(high - globalLow) / range
            
            ZStack(alignment: .leading) {
                // 배경
                Capsule()
                    .fill(.quaternary)
                
                // 범위 표시
                Capsule()
                    .fill(temperatureGradient)
                    .frame(width: geometry.size.width * (endRatio - startRatio))
                    .offset(x: geometry.size.width * startRatio)
            }
        }
        .frame(height: 4)
    }
    
    var temperatureGradient: LinearGradient {
        LinearGradient(
            colors: [.blue, .green, .yellow, .orange],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

#Preview("Large Widget", as: .systemLarge) {
    WeatherWidget()
} timeline: {
    CurrentWeatherEntry(date: .now, weather: .preview)
}
