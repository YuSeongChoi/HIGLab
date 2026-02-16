import WeatherKit
import Foundation

// 특정 날짜의 예보 찾기

func findDayForecast(_ daily: Forecast<DayWeather>, for targetDate: Date) -> DayWeather? {
    let calendar = Calendar.current
    
    return daily.first { day in
        calendar.isDate(day.date, inSameDayAs: targetDate)
    }
}

// 사용 예시
func exampleFindDay(_ daily: Forecast<DayWeather>) {
    let calendar = Calendar.current
    
    // 오늘 예보
    if let today = findDayForecast(daily, for: Date()) {
        print("오늘: \(today.condition.description)")
    }
    
    // 내일 예보
    let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
    if let tomorrowWeather = findDayForecast(daily, for: tomorrow) {
        print("내일: \(tomorrowWeather.highTemperature.formatted())")
    }
    
    // 주말 예보
    let weekendDays = daily.filter { day in
        let weekday = calendar.component(.weekday, from: day.date)
        return weekday == 1 || weekday == 7  // 일요일(1) 또는 토요일(7)
    }
    
    for weekend in weekendDays {
        let date = weekend.date.formatted(date: .abbreviated, time: .omitted)
        print("주말: \(date) - \(weekend.condition.description)")
    }
}
