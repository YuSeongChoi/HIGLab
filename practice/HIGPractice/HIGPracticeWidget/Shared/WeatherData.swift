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
    let dailyForecast: [DailyWeather]
}

enum WeatherCondition: String, CaseIterable, Codable {
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

struct HourlyWeather: Identifiable {
    let id = UUID()
    let hour: String
    let temperature: Int
    let condition: WeatherCondition
}

struct DailyWeather: Identifiable {
    let id = UUID()
    let dayOfWeek: String
    let high: Int
    let low: Int
    let condition: WeatherCondition
}

// MARK: - Preview / Mock Data

extension WeatherData {
    static let preview = WeatherData(
        cityName: "서울",
        temperature: 23,
        highTemperature: 27,
        lowTemperature: 18,
        condition: .sunny,
        humidity: 65,
        windSpeed: 3.2,
        hourlyForecast: [
            HourlyWeather(hour: "지금", temperature: 23, condition: .sunny),
            HourlyWeather(hour: "1시", temperature: 24, condition: .sunny),
            HourlyWeather(hour: "2시", temperature: 25, condition: .cloudy),
            HourlyWeather(hour: "3시", temperature: 24, condition: .cloudy),
            HourlyWeather(hour: "4시", temperature: 22, condition: .rainy),
            HourlyWeather(hour: "5시", temperature: 21, condition: .rainy),
        ],
        dailyForecast: [
            DailyWeather(dayOfWeek: "오늘", high: 27, low: 18, condition: .sunny),
            DailyWeather(dayOfWeek: "내일", high: 24, low: 16, condition: .rainy),
            DailyWeather(dayOfWeek: "모레", high: 22, low: 15, condition: .cloudy),
            DailyWeather(dayOfWeek: "목", high: 25, low: 17, condition: .sunny),
            DailyWeather(dayOfWeek: "금", high: 26, low: 18, condition: .sunny),
        ]
    )
    
    static let rainyPreview = WeatherData(
        cityName: "부산",
        temperature: 18,
        highTemperature: 20,
        lowTemperature: 15,
        condition: .rainy,
        humidity: 85,
        windSpeed: 5.1,
        hourlyForecast: [
            HourlyWeather(hour: "지금", temperature: 18, condition: .rainy),
            HourlyWeather(hour: "1시", temperature: 17, condition: .rainy),
            HourlyWeather(hour: "2시", temperature: 17, condition: .stormy),
            HourlyWeather(hour: "3시", temperature: 16, condition: .rainy),
            HourlyWeather(hour: "4시", temperature: 16, condition: .cloudy),
            HourlyWeather(hour: "5시", temperature: 17, condition: .cloudy),
        ],
        dailyForecast: [
            DailyWeather(dayOfWeek: "오늘", high: 20, low: 15, condition: .rainy),
            DailyWeather(dayOfWeek: "내일", high: 22, low: 16, condition: .cloudy),
            DailyWeather(dayOfWeek: "모레", high: 24, low: 17, condition: .sunny),
        ]
    )
}
