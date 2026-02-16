import WeatherKit
import CoreLocation

// 여러 DataSet 동시 요청

func fetchMultipleDataSets(location: CLLocation) async throws {
    let service = WeatherService.shared
    
    // 현재 날씨 + 시간별 예보
    let (current, hourly) = try await service.weather(
        for: location,
        including: .current, .hourly
    )
    
    print("현재: \(current.temperature)")
    print("다음 시간: \(hourly.first?.temperature ?? .init(value: 0, unit: .celsius))")
    
    // 현재 날씨 + 일별 예보 + 특보
    let (current2, daily, alerts) = try await service.weather(
        for: location,
        including: .current, .daily, .alerts
    )
    
    print("현재: \(current2.condition.description)")
    print("내일: \(daily.dropFirst().first?.condition.description ?? "없음")")
    print("특보 수: \(alerts?.count ?? 0)")
}
