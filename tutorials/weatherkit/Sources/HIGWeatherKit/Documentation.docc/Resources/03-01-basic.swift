import WeatherKit
import CoreLocation

// CurrentWeather 기본 요청

func getCurrentWeather(location: CLLocation) async throws -> CurrentWeather {
    let service = WeatherService.shared
    
    // 현재 날씨만 요청
    let currentWeather = try await service.weather(
        for: location,
        including: .current
    )
    
    return currentWeather
}

// 사용 예시
func displayCurrentWeather() async {
    let seoul = CLLocation(latitude: 37.5665, longitude: 126.9780)
    
    do {
        let current = try await getCurrentWeather(location: seoul)
        print("현재 온도: \(current.temperature)")
        print("날씨 상태: \(current.condition.description)")
    } catch {
        print("오류: \(error)")
    }
}
