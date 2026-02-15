import Foundation

// MARK: - 날씨 데이터 모델
struct WeatherData {
    let cityName: String
    let temperature: Int
    let highTemperature: Int
    let lowTemperature: Int
    let condition: WeatherCondition
    let humidity: Int
    let windSpeed: Double
    let hourlyForecast: [HourlyWeather]
}

// MARK: - 날씨 조건
enum WeatherCondition: String, CaseIterable {
    case sunny = "맑음"
    case cloudy = "흐림"
    case rainy = "비"
    case snowy = "눈"
    case stormy = "뇌우"
    
    var symbol: String {
        switch self {
        case .sunny: "sun.max.fill"
        case .cloudy: "cloud.fill"
        case .rainy: "cloud.rain.fill"
        case .snowy: "cloud.snow.fill"
        case .stormy: "cloud.bolt.rain.fill"
        }
    }
}

// MARK: - 시간별 날씨
struct HourlyWeather: Identifiable {
    let id = UUID()
    let hour: String
    let temperature: Int
    let condition: WeatherCondition
}

// MARK: - 주간 날씨
struct DailyWeather: Identifiable {
    let id = UUID()
    let day: String
    let highTemperature: Int
    let lowTemperature: Int
    let condition: WeatherCondition
}
