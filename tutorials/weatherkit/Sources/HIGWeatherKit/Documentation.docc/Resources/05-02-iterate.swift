import WeatherKit
import Foundation

// 일별 예보 순회

func iterateDailyForecast(_ daily: Forecast<DayWeather>) {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "ko_KR")
    dateFormatter.dateFormat = "E"  // 요일 (월, 화, 수...)
    
    for day in daily {
        let weekday = dateFormatter.string(from: day.date)
        let condition = day.condition.description
        let high = Int(day.highTemperature.value)
        let low = Int(day.lowTemperature.value)
        
        print("\(weekday): \(condition), \(low)° ~ \(high)°")
    }
    
    // 이번 주 평균 최고 기온
    let avgHigh = daily.reduce(0.0) { $0 + $1.highTemperature.value } / Double(daily.count)
    print("평균 최고 기온: \(Int(avgHigh))°")
    
    // 비 오는 날 찾기
    let rainyDays = daily.filter { $0.precipitationChance > 0.5 }
    print("비 올 확률 높은 날: \(rainyDays.count)일")
}
