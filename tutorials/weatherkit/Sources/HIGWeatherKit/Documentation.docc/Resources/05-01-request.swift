import WeatherKit
import CoreLocation

// 일별 예보 요청

func getDailyForecast(location: CLLocation) async throws -> Forecast<DayWeather> {
    let service = WeatherService.shared
    
    let dailyForecast = try await service.weather(
        for: location,
        including: .daily
    )
    
    return dailyForecast
}

// 사용 예시
func displayDailyForecast() async {
    let seoul = CLLocation(latitude: 37.5665, longitude: 126.9780)
    
    do {
        let daily = try await getDailyForecast(location: seoul)
        
        print("일별 예보 개수: \(daily.count)")
        
        for day in daily {
            let date = day.date.formatted(date: .abbreviated, time: .omitted)
            let high = day.highTemperature.formatted()
            let low = day.lowTemperature.formatted()
            print("\(date): \(low) ~ \(high)")
        }
    } catch {
        print("오류: \(error)")
    }
}
