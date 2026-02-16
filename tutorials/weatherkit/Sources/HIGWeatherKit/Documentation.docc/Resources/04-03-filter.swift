import WeatherKit
import Foundation

// 특정 시간 범위 필터링

func filterHourlyForecast(_ hourly: Forecast<HourWeather>) {
    let now = Date()
    let calendar = Calendar.current
    
    // 오늘 남은 시간
    let todayEnd = calendar.startOfDay(for: now).addingTimeInterval(24 * 60 * 60)
    let todayForecast = hourly.filter { $0.date >= now && $0.date < todayEnd }
    print("오늘 남은 예보: \(todayForecast.count)시간")
    
    // 다음 24시간
    let next24h = now.addingTimeInterval(24 * 60 * 60)
    let next24hForecast = hourly.filter { $0.date >= now && $0.date < next24h }
    
    // 내일 예보
    let tomorrowStart = todayEnd
    let tomorrowEnd = tomorrowStart.addingTimeInterval(24 * 60 * 60)
    let tomorrowForecast = hourly.filter { 
        $0.date >= tomorrowStart && $0.date < tomorrowEnd 
    }
    print("내일 예보: \(tomorrowForecast.count)시간")
}
