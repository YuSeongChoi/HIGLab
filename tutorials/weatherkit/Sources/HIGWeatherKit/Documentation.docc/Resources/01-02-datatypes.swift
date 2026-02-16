import WeatherKit
import CoreLocation

// WeatherKit이 제공하는 데이터 종류
/*
 ┌─────────────────────────────────────────────────┐
 │ DataSet              │ 설명                      │
 ├─────────────────────────────────────────────────┤
 │ .current             │ 현재 날씨                 │
 │ .hourly              │ 시간별 예보 (최대 240시간) │
 │ .daily               │ 일별 예보 (최대 10일)     │
 │ .minute              │ 분별 강수 예보 (1시간)    │
 │ .alerts              │ 기상 특보                 │
 └─────────────────────────────────────────────────┘
 */

// 현재 날씨만 요청하는 예시
func fetchCurrentWeather(for location: CLLocation) async throws {
    let weather = try await WeatherService.shared.weather(
        for: location,
        including: .current
    )
    print("현재 온도: \(weather.temperature)")
}
