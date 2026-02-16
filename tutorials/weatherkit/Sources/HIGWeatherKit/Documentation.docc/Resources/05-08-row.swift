import WeatherKit
import SwiftUI

// 일별 예보 행 UI

struct DailyForecastRow: View {
    let day: DayWeather
    let tempRange: ClosedRange<Double>
    
    var body: some View {
        HStack {
            // 요일
            Text(weekdayString)
                .frame(width: 40, alignment: .leading)
            
            // 날씨 아이콘
            Image(systemName: day.condition.symbolName)
                .symbolRenderingMode(.multicolor)
                .frame(width: 30)
            
            // 강수 확률
            if day.precipitationChance >= 0.2 {
                Text("\(Int(day.precipitationChance * 100))%")
                    .font(.caption)
                    .foregroundStyle(.cyan)
                    .frame(width: 35)
            } else {
                Text("")
                    .frame(width: 35)
            }
            
            // 최저 온도
            Text("\(Int(day.lowTemperature.value))°")
                .foregroundStyle(.secondary)
                .frame(width: 35)
            
            // 온도 막대
            TemperatureBar(
                low: day.lowTemperature.value,
                high: day.highTemperature.value,
                range: tempRange
            )
            
            // 최고 온도
            Text("\(Int(day.highTemperature.value))°")
                .frame(width: 35)
        }
        .padding(.vertical, 8)
    }
    
    private var weekdayString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "E"
        return formatter.string(from: day.date)
    }
}
