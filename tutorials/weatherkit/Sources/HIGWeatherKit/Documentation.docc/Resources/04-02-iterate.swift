import WeatherKit
import CoreLocation

// Forecast 순회하기

func iterateHourlyForecast(_ hourly: Forecast<HourWeather>) {
    // for-in 루프
    for hour in hourly {
        print("\(hour.date): \(hour.temperature.formatted())")
    }
    
    // 고차함수 사용
    let temperatures = hourly.map { $0.temperature }
    let rainyHours = hourly.filter { $0.precipitationChance > 0.3 }
    
    print("비 올 확률이 높은 시간: \(rainyHours.count)개")
    
    // 처음 24시간만
    let next24Hours = Array(hourly.prefix(24))
    for hour in next24Hours {
        let time = hour.date.formatted(date: .omitted, time: .shortened)
        print("\(time): \(hour.condition.description)")
    }
}
