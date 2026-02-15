import SwiftUI
import WidgetKit

// MARK: - Medium Widget View
// HIG: Medium은 두 배 넓은 공간 — 더 많은 정보 표시 가능
// 왼쪽: 현재 날씨 | 오른쪽: 시간별 예보

struct MediumWeatherView: View {
    let weather: WeatherData
    
    var body: some View {
        HStack(spacing: 16) {
            // MARK: 왼쪽 - 현재 날씨
            VStack(alignment: .leading, spacing: 4) {
                Text(weather.cityName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("\(weather.temperature)°")
                    .font(.system(size: 44, weight: .light, design: .rounded))
                    .contentTransition(.numericText())
                
                Text(weather.condition.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text("최고 \(weather.highTemperature)° 최저 \(weather.lowTemperature)°")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // 구분선
            Divider()
            
            // MARK: 오른쪽 - 시간별 예보
            HStack(spacing: 12) {
                ForEach(weather.hourlyForecast.prefix(5)) { hourly in
                    VStack(spacing: 6) {
                        Text(hourly.hour)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        
                        Image(systemName: hourly.condition.symbol)
                            .symbolRenderingMode(.multicolor)
                            .font(.body)
                        
                        Text("\(hourly.temperature)°")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }
            }
        }
    }
}
