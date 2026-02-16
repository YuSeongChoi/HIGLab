import WeatherKit
import CoreLocation

// API 호출 최적화 전략

class OptimizedWeatherManager {
    private let weatherService = WeatherService.shared
    private var cachedWeather: Weather?
    private var lastFetchTime: Date?
    
    // 캐시 유효 시간 (15분)
    private let cacheValidityInterval: TimeInterval = 15 * 60
    
    func getWeather(for location: CLLocation) async throws -> Weather {
        // 캐시가 유효하면 재사용
        if let cached = cachedWeather,
           let fetchTime = lastFetchTime,
           Date().timeIntervalSince(fetchTime) < cacheValidityInterval {
            return cached
        }
        
        // 새로운 데이터 요청 (필요한 것만)
        let weather = try await weatherService.weather(for: location)
        
        // 캐시 업데이트
        cachedWeather = weather
        lastFetchTime = Date()
        
        return weather
    }
}
