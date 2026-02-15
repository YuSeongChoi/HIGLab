import SwiftUI
import WidgetKit

// MARK: - Small Widget with Animation
// contentTransition(.numericText())로 기온 변화를 부드럽게 애니메이션

struct SmallWeatherView: View {
    let weather: WeatherData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // 날씨 아이콘
            Image(systemName: weather.condition.symbol)
                .font(.title2)
                .symbolRenderingMode(.multicolor)
                // 날씨 조건 변화 시 부드러운 전환
                .contentTransition(.symbolEffect(.replace))
            
            Spacer()
            
            // 기온 — 숫자 변화 애니메이션
            Text("\(weather.temperature)°")
                .font(.system(size: 36, weight: .light, design: .rounded))
                .contentTransition(.numericText(value: Double(weather.temperature)))
            
            VStack(alignment: .leading, spacing: 0) {
                Text(weather.cityName)
                    .font(.caption)
                    .fontWeight(.semibold)
                
                // 최고/최저도 애니메이션 적용
                HStack(spacing: 4) {
                    Text("최고")
                        .foregroundStyle(.secondary)
                    Text("\(weather.highTemperature)°")
                        .contentTransition(.numericText())
                    Text("최저")
                        .foregroundStyle(.secondary)
                    Text("\(weather.lowTemperature)°")
                        .contentTransition(.numericText())
                }
                .font(.caption2)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}
