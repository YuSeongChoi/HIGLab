import WeatherKit
import CoreLocation

// WeatherQuery를 사용한 동적 요청

func fetchDynamicData(location: CLLocation, needsAlerts: Bool) async throws {
    let service = WeatherService.shared
    
    // 기본 쿼리: 현재 날씨 + 시간별
    var queries: [WeatherQuery] = [
        .current,
        .hourly
    ]
    
    // 조건에 따라 추가 데이터 요청
    if needsAlerts {
        queries.append(.alerts)
    }
    
    // 참고: 실제로는 개별 요청이 필요
    // 튜플 기반 API가 더 효율적
    
    let current = try await service.weather(for: location, including: .current)
    let hourly = try await service.weather(for: location, including: .hourly)
    
    if needsAlerts {
        let alerts = try await service.weather(for: location, including: .alerts)
        print("특보: \(alerts?.count ?? 0)건")
    }
    
    print("현재 온도: \(current.temperature)")
    print("시간별 예보: \(hourly.count)개")
}
