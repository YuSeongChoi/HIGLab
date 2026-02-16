import WeatherKit
import CoreLocation

// 시간별 예보 요청

func getHourlyForecast(location: CLLocation) async throws -> Forecast<HourWeather> {
    let service = WeatherService.shared
    
    let hourlyForecast = try await service.weather(
        for: location,
        including: .hourly
    )
    
    return hourlyForecast
}

// 사용 예시
func displayHourlyForecast() async {
    let seoul = CLLocation(latitude: 37.5665, longitude: 126.9780)
    
    do {
        let hourly = try await getHourlyForecast(location: seoul)
        
        print("시간별 예보 개수: \(hourly.count)")
        print("예보 시작: \(hourly.first?.date ?? Date())")
        print("예보 종료: \(hourly.last?.date ?? Date())")
    } catch {
        print("오류: \(error)")
    }
}
