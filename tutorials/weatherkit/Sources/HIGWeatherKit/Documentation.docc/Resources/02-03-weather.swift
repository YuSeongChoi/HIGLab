import WeatherKit
import CoreLocation

// Weather 객체 구조

func exploreWeatherObject(location: CLLocation) async throws {
    let weather = try await WeatherService.shared.weather(for: location)
    
    // Weather 객체는 다양한 날씨 데이터를 포함
    
    // 현재 날씨
    let current = weather.currentWeather
    print("현재 온도: \(current.temperature)")
    
    // 시간별 예보
    let hourly = weather.hourlyForecast
    print("시간별 예보 수: \(hourly.count)")
    
    // 일별 예보
    let daily = weather.dailyForecast
    print("일별 예보 수: \(daily.count)")
    
    // 분별 강수 예보 (지원 지역에서만)
    if let minute = weather.minuteForecast {
        print("분별 예보 수: \(minute.count)")
    }
    
    // 기상 특보
    let alerts = weather.weatherAlerts
    print("활성 특보 수: \(alerts?.count ?? 0)")
}
