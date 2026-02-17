// WeatherTool.swift
// 날씨 정보 도구
// iOS 26+ | FoundationModels
//
// Foundation Models Tool 프로토콜을 구현한 날씨 조회 도구
// 실제로는 WeatherKit이나 외부 API와 연동 가능

import Foundation
import FoundationModels

// MARK: - 날씨 도구

/// 날씨 정보를 제공하는 도구
/// Foundation Models의 Tool 프로토콜을 구현
@Generable
struct WeatherTool: Tool {
    
    // MARK: - Tool 프로토콜 구현
    
    /// 도구 이름 (AI가 호출할 때 사용)
    static let name = "weather"
    
    /// 도구 설명 (AI가 도구 선택 시 참고)
    static let description = """
        특정 도시의 현재 날씨 정보를 가져옵니다.
        온도, 날씨 상태, 습도, 체감 온도 등을 제공합니다.
        """
    
    /// 도구 인자 스키마
    struct Arguments: Codable, Sendable {
        /// 조회할 도시 이름
        @Guide(description: "날씨를 조회할 도시 이름 (예: 서울, 부산, Tokyo)")
        let city: String
        
        /// 온도 단위 (celsius 또는 fahrenheit)
        @Guide(description: "온도 단위: celsius(섭씨) 또는 fahrenheit(화씨)")
        let unit: String?
    }
    
    /// 도구 실행
    /// - Parameter arguments: 입력 인자
    /// - Returns: 날씨 정보 문자열
    func call(arguments: Arguments) async throws -> String {
        let city = arguments.city
        let unit = arguments.unit ?? "celsius"
        
        // 날씨 데이터 가져오기 (시뮬레이션)
        let weather = try await fetchWeather(city: city, unit: unit)
        
        return formatWeatherResponse(weather, unit: unit)
    }
}

// MARK: - 날씨 데이터

/// 날씨 데이터 모델
struct WeatherData: Sendable {
    let city: String
    let condition: WeatherCondition
    let temperature: Double
    let feelsLike: Double
    let humidity: Int
    let windSpeed: Double
    let windDirection: String
    let uvIndex: Int
    let visibility: Double
    let pressure: Double
    let sunrise: String
    let sunset: String
    let updatedAt: Date
}

/// 날씨 상태
enum WeatherCondition: String, Sendable, CaseIterable {
    case sunny = "맑음"
    case cloudy = "흐림"
    case partlyCloudy = "구름 조금"
    case rainy = "비"
    case snowy = "눈"
    case stormy = "폭풍"
    case foggy = "안개"
    case windy = "바람"
    
    /// 날씨 아이콘
    var icon: String {
        switch self {
        case .sunny: return "☀️"
        case .cloudy: return "☁️"
        case .partlyCloudy: return "⛅"
        case .rainy: return "🌧️"
        case .snowy: return "🌨️"
        case .stormy: return "⛈️"
        case .foggy: return "🌫️"
        case .windy: return "💨"
        }
    }
    
    /// SF Symbol 아이콘 이름
    var symbolName: String {
        switch self {
        case .sunny: return "sun.max.fill"
        case .cloudy: return "cloud.fill"
        case .partlyCloudy: return "cloud.sun.fill"
        case .rainy: return "cloud.rain.fill"
        case .snowy: return "cloud.snow.fill"
        case .stormy: return "cloud.bolt.rain.fill"
        case .foggy: return "cloud.fog.fill"
        case .windy: return "wind"
        }
    }
}

// MARK: - 날씨 조회 로직

extension WeatherTool {
    
    /// 날씨 데이터 가져오기 (시뮬레이션)
    /// 실제 앱에서는 WeatherKit 또는 외부 API 사용
    func fetchWeather(city: String, unit: String) async throws -> WeatherData {
        // 실제 API 호출 대신 시뮬레이션 데이터 반환
        // TODO: WeatherKit 또는 OpenWeatherMap API 연동
        
        // 도시별 시뮬레이션 데이터
        let weatherMap: [String: (condition: WeatherCondition, temp: Double)] = [
            "서울": (.partlyCloudy, 18),
            "부산": (.sunny, 22),
            "대구": (.sunny, 24),
            "인천": (.cloudy, 17),
            "광주": (.partlyCloudy, 20),
            "대전": (.sunny, 19),
            "울산": (.sunny, 23),
            "세종": (.partlyCloudy, 18),
            "제주": (.rainy, 21),
            "Tokyo": (.cloudy, 20),
            "Osaka": (.partlyCloudy, 22),
            "New York": (.rainy, 15),
            "Los Angeles": (.sunny, 28),
            "London": (.foggy, 12),
            "Paris": (.partlyCloudy, 16),
            "Berlin": (.cloudy, 14),
        ]
        
        // 도시 찾기 (대소문자 무시)
        let normalizedCity = city.trimmingCharacters(in: .whitespaces)
        let weather = weatherMap.first {
            $0.key.lowercased() == normalizedCity.lowercased()
        }
        
        let (condition, baseTemp) = weather?.value ?? (.partlyCloudy, 20)
        
        // 온도 변환
        let temperature: Double
        if unit.lowercased() == "fahrenheit" {
            temperature = baseTemp * 9/5 + 32
        } else {
            temperature = baseTemp
        }
        
        // 체감 온도 (바람과 습도 고려한 시뮬레이션)
        let feelsLike = temperature + Double.random(in: -3...3)
        
        return WeatherData(
            city: normalizedCity,
            condition: condition,
            temperature: temperature,
            feelsLike: feelsLike,
            humidity: Int.random(in: 40...80),
            windSpeed: Double.random(in: 0...15),
            windDirection: ["북", "북동", "동", "남동", "남", "남서", "서", "북서"].randomElement()!,
            uvIndex: Int.random(in: 1...11),
            visibility: Double.random(in: 5...20),
            pressure: Double.random(in: 1000...1030),
            sunrise: "06:30",
            sunset: "18:45",
            updatedAt: Date()
        )
    }
    
    /// 날씨 응답 포맷팅
    func formatWeatherResponse(_ weather: WeatherData, unit: String) -> String {
        let tempUnit = unit.lowercased() == "fahrenheit" ? "°F" : "°C"
        
        return """
            🌍 \(weather.city) 날씨 정보
            
            \(weather.condition.icon) 현재 날씨: \(weather.condition.rawValue)
            🌡️ 기온: \(String(format: "%.1f", weather.temperature))\(tempUnit)
            🤒 체감 온도: \(String(format: "%.1f", weather.feelsLike))\(tempUnit)
            💧 습도: \(weather.humidity)%
            💨 바람: \(String(format: "%.1f", weather.windSpeed))m/s (\(weather.windDirection)풍)
            ☀️ 자외선 지수: \(weather.uvIndex)
            👁️ 가시거리: \(String(format: "%.1f", weather.visibility))km
            🌅 일출: \(weather.sunrise) | 일몰: \(weather.sunset)
            
            ⏰ 업데이트: \(formatTime(weather.updatedAt))
            """
    }
    
    /// 시간 포맷팅
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    /// 간단한 날씨 조회 (레거시 인터페이스)
    func getWeather(city: String) async throws -> String {
        let weather = try await fetchWeather(city: city, unit: "celsius")
        return formatWeatherResponse(weather, unit: "celsius")
    }
}

// MARK: - 날씨 예보

/// 날씨 예보 데이터
struct WeatherForecast: Sendable {
    let date: Date
    let highTemp: Double
    let lowTemp: Double
    let condition: WeatherCondition
    let precipitationChance: Int
}

extension WeatherTool {
    
    /// 주간 예보 가져오기 (시뮬레이션)
    func fetchForecast(city: String, days: Int = 7) async throws -> [WeatherForecast] {
        var forecasts: [WeatherForecast] = []
        let calendar = Calendar.current
        
        for i in 0..<days {
            let date = calendar.date(byAdding: .day, value: i, to: Date())!
            let condition = WeatherCondition.allCases.randomElement()!
            
            forecasts.append(WeatherForecast(
                date: date,
                highTemp: Double.random(in: 15...30),
                lowTemp: Double.random(in: 5...18),
                condition: condition,
                precipitationChance: condition == .rainy ? Int.random(in: 60...100) : Int.random(in: 0...30)
            ))
        }
        
        return forecasts
    }
    
    /// 예보 포맷팅
    func formatForecast(_ forecasts: [WeatherForecast]) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d (E)"
        formatter.locale = Locale(identifier: "ko_KR")
        
        var result = "📅 주간 날씨 예보\n\n"
        
        for forecast in forecasts {
            result += """
                \(formatter.string(from: forecast.date)): \(forecast.condition.icon) \(forecast.condition.rawValue)
                  ⬆️ \(String(format: "%.0f", forecast.highTemp))° / ⬇️ \(String(format: "%.0f", forecast.lowTemp))°
                  🌧️ 강수확률: \(forecast.precipitationChance)%
                
                """
        }
        
        return result
    }
}

// MARK: - 프리뷰 데이터

extension WeatherData {
    
    /// 프리뷰용 샘플 데이터
    static let preview = WeatherData(
        city: "서울",
        condition: .partlyCloudy,
        temperature: 18.5,
        feelsLike: 17.2,
        humidity: 55,
        windSpeed: 3.2,
        windDirection: "북서",
        uvIndex: 4,
        visibility: 15.0,
        pressure: 1015,
        sunrise: "06:30",
        sunset: "18:45",
        updatedAt: Date()
    )
}
