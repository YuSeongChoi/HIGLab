import WeatherKit
import SwiftUI

// 강수 확률 표시가 포함된 시간별 카드

struct HourlyCardWithRain: View {
    let hour: HourWeather
    
    var body: some View {
        VStack(spacing: 6) {
            // 시간
            Text(formattedTime)
                .font(.caption2)
                .foregroundStyle(.secondary)
            
            // 날씨 아이콘
            Image(systemName: hour.condition.symbolName)
                .symbolRenderingMode(.multicolor)
                .font(.title3)
            
            // 강수 확률 (20% 이상일 때만 표시)
            if hour.precipitationChance >= 0.2 {
                HStack(spacing: 2) {
                    Image(systemName: "drop.fill")
                        .font(.caption2)
                        .foregroundStyle(.cyan)
                    Text("\(Int(hour.precipitationChance * 100))%")
                        .font(.caption2)
                        .foregroundStyle(.cyan)
                }
            } else {
                Text(" ")
                    .font(.caption2)
            }
            
            // 온도
            Text("\(Int(hour.temperature.value))°")
                .font(.callout)
                .fontWeight(.medium)
        }
        .frame(width: 50)
        .padding(.vertical, 8)
    }
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "ha"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: hour.date)
    }
}
