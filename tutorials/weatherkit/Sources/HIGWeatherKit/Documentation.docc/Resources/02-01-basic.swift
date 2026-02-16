import WeatherKit
import CoreLocation

// WeatherService 기본 사용법

func fetchWeather() async {
    let weatherService = WeatherService.shared
    
    // 서울의 좌표
    let seoul = CLLocation(latitude: 37.5665, longitude: 126.9780)
    
    do {
        // 모든 날씨 데이터 요청
        let weather = try await weatherService.weather(for: seoul)
        
        print("현재 온도: \(weather.currentWeather.temperature)")
        print("날씨 상태: \(weather.currentWeather.condition)")
    } catch {
        print("날씨 데이터 요청 실패: \(error)")
    }
}
