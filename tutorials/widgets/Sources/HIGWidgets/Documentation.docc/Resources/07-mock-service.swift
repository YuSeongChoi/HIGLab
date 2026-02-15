import Foundation
import CoreLocation

// MARK: - Mock Weather Service
// 개발/테스트 중 실제 API 없이 사용할 수 있는 Mock 서비스입니다.
// Xcode Preview에서도 위젯을 미리 볼 수 있습니다.

actor WeatherService {
    static let shared = WeatherService()
    
    /// Mock 모드 활성화 (DEBUG 빌드에서 true)
    #if DEBUG
    private let useMockData = true
    #else
    private let useMockData = false
    #endif
    
    // MARK: - Fetch Weather
    func fetchWeather(for city: CityOption = .seoul) async -> WeatherData {
        if useMockData {
            // 개발 중에는 Mock 데이터 사용
            return mockWeather(for: city)
        }
        
        // 실제 구현은 WeatherKit 사용
        // (07-weather-service.swift 참조)
        return .preview
    }
    
    // MARK: - Mock Data Generator
    private func mockWeather(for city: CityOption) -> WeatherData {
        // 도시별로 약간 다른 온도 제공
        let baseTemp: Int
        let condition: WeatherCondition
        
        switch city {
        case .seoul:
            baseTemp = 23
            condition = .sunny
        case .busan:
            baseTemp = 25
            condition = .cloudy
        case .jeju:
            baseTemp = 27
            condition = .sunny
        case .daejeon:
            baseTemp = 24
            condition = .cloudy
        case .gwangju:
            baseTemp = 22
            condition = .rainy
        }
        
        // 시간별 예보 생성
        let hourly = (0..<6).map { offset -> HourlyWeather in
            let hour = Calendar.current.date(byAdding: .hour, value: offset, to: .now)!
            let hourString = offset == 0 ? "지금" : hour.formatted(.dateTime.hour())
            
            // 온도 변화: 오후에 올라갔다 저녁에 내림
            let tempVariation = [0, 2, 3, 2, 0, -2]
            
            return HourlyWeather(
                hour: hourString,
                temperature: baseTemp + tempVariation[offset],
                condition: offset < 3 ? condition : .cloudy
            )
        }
        
        return WeatherData(
            cityName: city.rawValue,
            temperature: baseTemp,
            highTemperature: baseTemp + 4,
            lowTemperature: baseTemp - 5,
            condition: condition,
            humidity: 55,
            windSpeed: 3.5,
            hourlyForecast: hourly
        )
    }
}

// MARK: - Debug Preview
#if DEBUG
extension WeatherData {
    /// 다양한 날씨 조건 테스트용
    static func testData(condition: WeatherCondition) -> WeatherData {
        WeatherData(
            cityName: "테스트",
            temperature: 20,
            highTemperature: 25,
            lowTemperature: 15,
            condition: condition,
            humidity: 50,
            windSpeed: 3.0,
            hourlyForecast: [
                HourlyWeather(hour: "지금", temperature: 20, condition: condition),
                HourlyWeather(hour: "14시", temperature: 22, condition: condition),
            ]
        )
    }
}
#endif
