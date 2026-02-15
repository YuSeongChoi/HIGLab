import Foundation

// MARK: - Preview Data
// 개발, 테스트, Xcode Preview에서 사용할 샘플 데이터입니다.

extension WeatherData {
    /// 기본 미리보기 데이터
    static let preview = WeatherData(
        cityName: "서울",
        temperature: 23,
        highTemperature: 27,
        lowTemperature: 18,
        condition: .sunny,
        humidity: 45,
        windSpeed: 3.2,
        hourlyForecast: previewHourly
    )
    
    /// 비 오는 날 미리보기
    static let rainyPreview = WeatherData(
        cityName: "서울",
        temperature: 18,
        highTemperature: 20,
        lowTemperature: 15,
        condition: .rainy,
        humidity: 85,
        windSpeed: 5.0,
        hourlyForecast: previewRainyHourly
    )
    
    /// 시간별 예보 샘플
    private static let previewHourly: [HourlyWeather] = [
        HourlyWeather(hour: "지금", temperature: 23, condition: .sunny),
        HourlyWeather(hour: "14시", temperature: 25, condition: .sunny),
        HourlyWeather(hour: "15시", temperature: 26, condition: .cloudy),
        HourlyWeather(hour: "16시", temperature: 27, condition: .cloudy),
        HourlyWeather(hour: "17시", temperature: 25, condition: .sunny),
        HourlyWeather(hour: "18시", temperature: 23, condition: .sunny),
    ]
    
    private static let previewRainyHourly: [HourlyWeather] = [
        HourlyWeather(hour: "지금", temperature: 18, condition: .rainy),
        HourlyWeather(hour: "14시", temperature: 17, condition: .rainy),
        HourlyWeather(hour: "15시", temperature: 17, condition: .rainy),
        HourlyWeather(hour: "16시", temperature: 18, condition: .cloudy),
        HourlyWeather(hour: "17시", temperature: 19, condition: .cloudy),
        HourlyWeather(hour: "18시", temperature: 18, condition: .cloudy),
    ]
    
    /// 주간 예보 샘플
    static let previewDaily: [DailyWeather] = [
        DailyWeather(day: "오늘", highTemperature: 27, lowTemperature: 18, condition: .sunny),
        DailyWeather(day: "내일", highTemperature: 25, lowTemperature: 17, condition: .cloudy),
        DailyWeather(day: "수", highTemperature: 22, lowTemperature: 16, condition: .rainy),
        DailyWeather(day: "목", highTemperature: 24, lowTemperature: 17, condition: .cloudy),
        DailyWeather(day: "금", highTemperature: 26, lowTemperature: 18, condition: .sunny),
    ]
    
    /// 시간 이동 (타임라인용)
    func shifting(byHours hours: Int) -> WeatherData {
        guard hours < hourlyForecast.count else { return self }
        let shifted = hourlyForecast[hours]
        return WeatherData(
            cityName: cityName,
            temperature: shifted.temperature,
            highTemperature: highTemperature,
            lowTemperature: lowTemperature,
            condition: shifted.condition,
            humidity: humidity,
            windSpeed: windSpeed,
            hourlyForecast: Array(hourlyForecast.dropFirst(hours))
        )
    }
}
