import Foundation
import CoreLocation

// MARK: - Weather Service
// WeatherKit 사용 시 실제 API로 교체 가능한 구조

actor WeatherService {
    static let shared = WeatherService()
    
    // Mock 데이터 기반 (WeatherKit 구독 없이 개발/테스트)
    func fetchWeather(for city: CityOption = .seoul) async -> WeatherData {
        // 실제 앱에서는 WeatherKit API 호출
        // let weather = try await WeatherKit.WeatherService.shared.weather(for: city.coordinate)
        
        // 시뮬레이션: 도시별 다른 날씨 반환
        switch city {
        case .seoul:
            return .preview
        case .busan:
            return .rainyPreview
        case .jeju:
            return WeatherData(
                cityName: "제주",
                temperature: 26,
                highTemperature: 29,
                lowTemperature: 22,
                condition: .sunny,
                humidity: 70,
                windSpeed: 4.5,
                hourlyForecast: generateHourly(base: 26, condition: .sunny),
                dailyForecast: generateDaily()
            )
        case .daejeon:
            return WeatherData(
                cityName: "대전",
                temperature: 24,
                highTemperature: 28,
                lowTemperature: 19,
                condition: .cloudy,
                humidity: 55,
                windSpeed: 2.1,
                hourlyForecast: generateHourly(base: 24, condition: .cloudy),
                dailyForecast: generateDaily()
            )
        case .gwangju:
            return WeatherData(
                cityName: "광주",
                temperature: 25,
                highTemperature: 29,
                lowTemperature: 20,
                condition: .sunny,
                humidity: 60,
                windSpeed: 3.0,
                hourlyForecast: generateHourly(base: 25, condition: .sunny),
                dailyForecast: generateDaily()
            )
        case .incheon:
            return WeatherData(
                cityName: "인천",
                temperature: 21,
                highTemperature: 24,
                lowTemperature: 17,
                condition: .cloudy,
                humidity: 72,
                windSpeed: 5.8,
                hourlyForecast: generateHourly(base: 21, condition: .cloudy),
                dailyForecast: generateDaily()
            )
        case .daegu:
            return WeatherData(
                cityName: "대구",
                temperature: 28,
                highTemperature: 32,
                lowTemperature: 23,
                condition: .sunny,
                humidity: 45,
                windSpeed: 1.5,
                hourlyForecast: generateHourly(base: 28, condition: .sunny),
                dailyForecast: generateDaily()
            )
        }
    }
    
    // MARK: - Helpers
    
    private func generateHourly(base: Int, condition: WeatherCondition) -> [HourlyWeather] {
        let conditions: [WeatherCondition] = [condition, condition, .cloudy, .cloudy, .rainy, .rainy]
        return (0..<6).map { i in
            HourlyWeather(
                hour: i == 0 ? "지금" : "\(Calendar.current.component(.hour, from: .now) + i)시",
                temperature: base + Int.random(in: -2...2),
                condition: conditions[i]
            )
        }
    }
    
    private func generateDaily() -> [DailyWeather] {
        let days = ["오늘", "내일", "모레", "목", "금"]
        let conditions: [WeatherCondition] = [.sunny, .rainy, .cloudy, .sunny, .sunny]
        return (0..<5).map { i in
            DailyWeather(
                dayOfWeek: days[i],
                high: Int.random(in: 24...30),
                low: Int.random(in: 15...20),
                condition: conditions[i]
            )
        }
    }
}
