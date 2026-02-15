import Foundation
import WeatherKit
import CoreLocation

// MARK: - Weather Service
// Actor로 스레드 안전한 날씨 서비스를 구현합니다.
// WeatherKit을 사용하면 Apple의 공식 날씨 데이터를 받을 수 있습니다.

actor WeatherService {
    static let shared = WeatherService()
    
    private let service = WeatherKit.WeatherService.shared
    
    // MARK: - 도시별 좌표
    private let cityCoordinates: [CityOption: CLLocation] = [
        .seoul: CLLocation(latitude: 37.5665, longitude: 126.9780),
        .busan: CLLocation(latitude: 35.1796, longitude: 129.0756),
        .jeju: CLLocation(latitude: 33.4996, longitude: 126.5312),
        .daejeon: CLLocation(latitude: 36.3504, longitude: 127.3845),
        .gwangju: CLLocation(latitude: 35.1595, longitude: 126.8526)
    ]
    
    // MARK: - Fetch Weather
    func fetchWeather(for city: CityOption = .seoul) async -> WeatherData {
        guard let location = cityCoordinates[city] else {
            return .preview
        }
        
        do {
            let weather = try await service.weather(for: location)
            let current = weather.currentWeather
            let daily = weather.dailyForecast.first
            
            // 시간별 예보 변환
            let hourly = weather.hourlyForecast
                .filter { $0.date >= .now }
                .prefix(6)
                .enumerated()
                .map { index, forecast in
                    HourlyWeather(
                        hour: index == 0 ? "지금" : forecast.date.formatted(.dateTime.hour()),
                        temperature: Int(forecast.temperature.value),
                        condition: WeatherCondition.from(forecast.condition)
                    )
                }
            
            return WeatherData(
                cityName: city.rawValue,
                temperature: Int(current.temperature.value),
                highTemperature: Int(daily?.highTemperature.value ?? 0),
                lowTemperature: Int(daily?.lowTemperature.value ?? 0),
                condition: WeatherCondition.from(current.condition),
                humidity: Int(current.humidity * 100),
                windSpeed: current.wind.speed.value,
                hourlyForecast: Array(hourly)
            )
        } catch {
            print("WeatherKit error: \(error)")
            return .preview
        }
    }
}

// MARK: - WeatherKit Condition Mapping
extension WeatherCondition {
    static func from(_ condition: WeatherKit.WeatherCondition) -> WeatherCondition {
        switch condition {
        case .clear, .mostlyClear, .hot:
            return .sunny
        case .cloudy, .mostlyCloudy, .partlyCloudy, .foggy, .haze, .smoky:
            return .cloudy
        case .rain, .drizzle, .heavyRain, .isolatedThunderstorms:
            return .rainy
        case .snow, .flurries, .heavySnow, .sleet, .freezingRain:
            return .snowy
        case .thunderstorms, .tropicalStorm, .hurricane:
            return .stormy
        default:
            return .cloudy
        }
    }
}
