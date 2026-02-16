import WeatherKit
import CoreLocation

// WeatherKit과 CoreLocation을 함께 import
// 위치 기반 날씨 데이터를 요청하기 위해 둘 다 필요

struct WeatherManager {
    let weatherService = WeatherService.shared
    
    func getWeather(latitude: Double, longitude: Double) async throws -> Weather {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        return try await weatherService.weather(for: location)
    }
}
