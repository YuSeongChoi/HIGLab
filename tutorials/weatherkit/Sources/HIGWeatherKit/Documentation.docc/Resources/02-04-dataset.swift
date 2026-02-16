import WeatherKit
import CoreLocation

// 특정 DataSet만 요청하기

func fetchSpecificData(location: CLLocation) async throws {
    let service = WeatherService.shared
    
    // 현재 날씨만 요청
    let current = try await service.weather(
        for: location,
        including: .current
    )
    print("온도: \(current.temperature)")
    
    // 시간별 예보만 요청
    let hourly = try await service.weather(
        for: location,
        including: .hourly
    )
    print("첫 시간 온도: \(hourly.first?.temperature ?? .init(value: 0, unit: .celsius))")
    
    // 일별 예보만 요청
    let daily = try await service.weather(
        for: location,
        including: .daily
    )
    print("내일 최고 온도: \(daily.dropFirst().first?.highTemperature ?? .init(value: 0, unit: .celsius))")
}
