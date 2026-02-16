import WeatherKit
import CoreLocation

// 에러 처리 기본

func fetchWeatherWithErrorHandling(location: CLLocation) async {
    do {
        let weather = try await WeatherService.shared.weather(for: location)
        print("날씨: \(weather.currentWeather.condition)")
    } catch {
        // 에러 발생 시 처리
        handleWeatherError(error)
    }
}

func handleWeatherError(_ error: Error) {
    if let weatherError = error as? WeatherError {
        switch weatherError {
        case .permissionDenied:
            print("WeatherKit 권한이 거부되었습니다.")
            print("App Store Connect에서 capability를 확인하세요.")
        case .unknown:
            print("알 수 없는 WeatherKit 에러가 발생했습니다.")
        @unknown default:
            print("처리되지 않은 WeatherKit 에러: \(weatherError)")
        }
    } else {
        print("일반 에러: \(error.localizedDescription)")
    }
}
