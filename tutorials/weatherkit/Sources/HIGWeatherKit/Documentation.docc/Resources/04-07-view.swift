import WeatherKit
import SwiftUI

// 시간별 예보 카드

struct HourlyForecastCard: View {
    let hour: HourWeather
    
    var body: some View {
        VStack(spacing: 8) {
            // 시간
            Text(hour.date.formatted(date: .omitted, time: .shortened))
                .font(.caption)
                .foregroundStyle(.secondary)
            
            // 날씨 아이콘
            Image(systemName: hour.condition.symbolName)
                .symbolRenderingMode(.multicolor)
                .font(.title2)
            
            // 온도
            Text(hour.temperature.formatted())
                .font(.headline)
        }
        .frame(width: 60)
        .padding(.vertical, 12)
    }
}
