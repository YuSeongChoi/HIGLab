import Foundation
import SwiftUI

// MARK: - 날씨 데이터 모델
// HIG: 데이터 구조는 위젯에서 필요한 정보만 효율적으로 담아야 함

/// 메인 날씨 데이터 - 모든 위젯에서 공유
struct WeatherData: Codable, Sendable {
    let cityName: String
    let temperature: Int
    let feelsLike: Int
    let highTemperature: Int
    let lowTemperature: Int
    let condition: WeatherCondition
    let humidity: Int
    let windSpeed: Double
    let windDirection: WindDirection
    let pressure: Int
    let visibility: Double
    let dewPoint: Int
    let hourlyForecast: [HourlyWeather]
    let dailyForecast: [DailyWeather]
    let sunrise: Date
    let sunset: Date
    let lastUpdated: Date
    
    /// 현재 시간이 낮인지 밤인지 판단
    var isDaytime: Bool {
        let now = Date()
        return now >= sunrise && now <= sunset
    }
    
    /// 일출/일몰까지 남은 시간 (분 단위)
    var minutesToSunEvent: Int {
        let now = Date()
        let targetDate = isDaytime ? sunset : sunrise
        return Int(targetDate.timeIntervalSince(now) / 60)
    }
    
    /// 포맷된 일출 시간
    var formattedSunrise: String {
        sunrise.formatted(date: .omitted, time: .shortened)
    }
    
    /// 포맷된 일몰 시간
    var formattedSunset: String {
        sunset.formatted(date: .omitted, time: .shortened)
    }
}

// MARK: - 날씨 상태 열거형

enum WeatherCondition: String, CaseIterable, Codable, Sendable {
    case sunny = "맑음"
    case partlyCloudy = "구름 조금"
    case cloudy = "흐림"
    case foggy = "안개"
    case rainy = "비"
    case heavyRain = "폭우"
    case snowy = "눈"
    case sleet = "진눈깨비"
    case stormy = "뇌우"
    case windy = "바람"
    case haze = "연무"
    
    /// SF Symbol 이름 (낮/밤 구분)
    func symbol(isDaytime: Bool = true) -> String {
        switch self {
        case .sunny:
            return isDaytime ? "sun.max.fill" : "moon.stars.fill"
        case .partlyCloudy:
            return isDaytime ? "cloud.sun.fill" : "cloud.moon.fill"
        case .cloudy:
            return "cloud.fill"
        case .foggy:
            return "cloud.fog.fill"
        case .rainy:
            return "cloud.rain.fill"
        case .heavyRain:
            return "cloud.heavyrain.fill"
        case .snowy:
            return "cloud.snow.fill"
        case .sleet:
            return "cloud.sleet.fill"
        case .stormy:
            return "cloud.bolt.rain.fill"
        case .windy:
            return "wind"
        case .haze:
            return "sun.haze.fill"
        }
    }
    
    /// 간단한 설명
    var shortDescription: String {
        rawValue
    }
    
    /// 상세 설명
    var detailedDescription: String {
        switch self {
        case .sunny: return "맑은 하늘이에요"
        case .partlyCloudy: return "구름이 조금 있어요"
        case .cloudy: return "흐린 날씨예요"
        case .foggy: return "안개가 끼어요"
        case .rainy: return "비가 내려요"
        case .heavyRain: return "폭우가 예상돼요"
        case .snowy: return "눈이 내려요"
        case .sleet: return "진눈깨비가 내려요"
        case .stormy: return "뇌우가 예상돼요"
        case .windy: return "바람이 강해요"
        case .haze: return "연무가 있어요"
        }
    }
    
    /// 우산 필요 여부
    var needsUmbrella: Bool {
        switch self {
        case .rainy, .heavyRain, .stormy, .sleet:
            return true
        default:
            return false
        }
    }
}

// MARK: - 바람 방향

enum WindDirection: String, Codable, Sendable {
    case north = "북"
    case northEast = "북동"
    case east = "동"
    case southEast = "남동"
    case south = "남"
    case southWest = "남서"
    case west = "서"
    case northWest = "북서"
    
    /// 풍향 화살표 회전 각도
    var rotationAngle: Angle {
        switch self {
        case .north: return .degrees(0)
        case .northEast: return .degrees(45)
        case .east: return .degrees(90)
        case .southEast: return .degrees(135)
        case .south: return .degrees(180)
        case .southWest: return .degrees(225)
        case .west: return .degrees(270)
        case .northWest: return .degrees(315)
        }
    }
}

// MARK: - 시간별 예보

struct HourlyWeather: Identifiable, Codable, Sendable {
    let id: UUID
    let date: Date
    let temperature: Int
    let condition: WeatherCondition
    let precipitationChance: Int
    let humidity: Int
    let windSpeed: Double
    let uvIndex: Int
    
    /// 포맷된 시간 표시
    var formattedHour: String {
        let calendar = Calendar.current
        if calendar.isDate(date, equalTo: Date(), toGranularity: .hour) {
            return "지금"
        }
        return date.formatted(.dateTime.hour())
    }
    
    /// 해당 시간이 낮인지 판단 (간단 로직)
    var isDaytime: Bool {
        let hour = Calendar.current.component(.hour, from: date)
        return hour >= 6 && hour < 18
    }
    
    init(id: UUID = UUID(), date: Date, temperature: Int, condition: WeatherCondition,
         precipitationChance: Int = 0, humidity: Int = 50, windSpeed: Double = 0, uvIndex: Int = 0) {
        self.id = id
        self.date = date
        self.temperature = temperature
        self.condition = condition
        self.precipitationChance = precipitationChance
        self.humidity = humidity
        self.windSpeed = windSpeed
        self.uvIndex = uvIndex
    }
}

// MARK: - 일별 예보

struct DailyWeather: Identifiable, Codable, Sendable {
    let id: UUID
    let date: Date
    let high: Int
    let low: Int
    let condition: WeatherCondition
    let precipitationChance: Int
    let sunrise: Date
    let sunset: Date
    let uvIndex: Int
    let moonPhase: MoonPhase
    
    /// 요일 표시
    var dayOfWeek: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "오늘"
        } else if calendar.isDateInTomorrow(date) {
            return "내일"
        }
        return date.formatted(.dateTime.weekday(.abbreviated))
    }
    
    /// 날짜 표시 (월/일)
    var shortDate: String {
        date.formatted(.dateTime.month(.defaultDigits).day())
    }
    
    init(id: UUID = UUID(), date: Date, high: Int, low: Int, condition: WeatherCondition,
         precipitationChance: Int = 0, sunrise: Date = Date(), sunset: Date = Date(),
         uvIndex: Int = 0, moonPhase: MoonPhase = .fullMoon) {
        self.id = id
        self.date = date
        self.high = high
        self.low = low
        self.condition = condition
        self.precipitationChance = precipitationChance
        self.sunrise = sunrise
        self.sunset = sunset
        self.uvIndex = uvIndex
        self.moonPhase = moonPhase
    }
}

// MARK: - 달 위상

enum MoonPhase: String, Codable, Sendable {
    case newMoon = "신월"
    case waxingCrescent = "초승달"
    case firstQuarter = "상현달"
    case waxingGibbous = "상현망간"
    case fullMoon = "보름달"
    case waningGibbous = "하현망간"
    case lastQuarter = "하현달"
    case waningCrescent = "그믐달"
    
    var symbol: String {
        switch self {
        case .newMoon: return "moonphase.new.moon"
        case .waxingCrescent: return "moonphase.waxing.crescent"
        case .firstQuarter: return "moonphase.first.quarter"
        case .waxingGibbous: return "moonphase.waxing.gibbous"
        case .fullMoon: return "moonphase.full.moon"
        case .waningGibbous: return "moonphase.waning.gibbous"
        case .lastQuarter: return "moonphase.last.quarter"
        case .waningCrescent: return "moonphase.waning.crescent"
        }
    }
}

// MARK: - 대기질 데이터

struct AirQualityData: Codable, Sendable {
    let aqi: Int                    // 통합 대기질 지수 (0-500)
    let category: AirQualityLevel
    let pm25: Double               // PM2.5 농도 (μg/m³)
    let pm10: Double               // PM10 농도 (μg/m³)
    let o3: Double                 // 오존 농도 (ppb)
    let no2: Double                // 이산화질소 농도 (ppb)
    let co: Double                 // 일산화탄소 농도 (ppm)
    let so2: Double                // 이산화황 농도 (ppb)
    let dominantPollutant: Pollutant
    let lastUpdated: Date
    
    /// 건강 권고 메시지
    var healthAdvice: String {
        category.healthAdvice
    }
    
    /// 마스크 권고 여부
    var shouldWearMask: Bool {
        aqi >= 101
    }
}

/// 대기질 등급
enum AirQualityLevel: String, Codable, Sendable {
    case good = "좋음"
    case moderate = "보통"
    case unhealthyForSensitive = "민감군 주의"
    case unhealthy = "나쁨"
    case veryUnhealthy = "매우 나쁨"
    case hazardous = "위험"
    
    /// AQI 값에서 레벨 결정
    init(aqi: Int) {
        switch aqi {
        case 0...50: self = .good
        case 51...100: self = .moderate
        case 101...150: self = .unhealthyForSensitive
        case 151...200: self = .unhealthy
        case 201...300: self = .veryUnhealthy
        default: self = .hazardous
        }
    }
    
    /// 대기질 색상
    var color: Color {
        switch self {
        case .good: return .green
        case .moderate: return .yellow
        case .unhealthyForSensitive: return .orange
        case .unhealthy: return .red
        case .veryUnhealthy: return .purple
        case .hazardous: return Color(red: 0.5, green: 0, blue: 0)
        }
    }
    
    /// SF Symbol
    var symbol: String {
        switch self {
        case .good: return "aqi.low"
        case .moderate: return "aqi.medium"
        case .unhealthyForSensitive, .unhealthy: return "aqi.high"
        case .veryUnhealthy, .hazardous: return "exclamationmark.triangle.fill"
        }
    }
    
    /// 건강 권고 메시지
    var healthAdvice: String {
        switch self {
        case .good:
            return "야외 활동하기 좋은 날이에요"
        case .moderate:
            return "민감한 분은 장시간 야외 활동 자제"
        case .unhealthyForSensitive:
            return "어린이, 노약자, 호흡기 환자는 주의"
        case .unhealthy:
            return "야외 활동을 줄이세요"
        case .veryUnhealthy:
            return "실내에 머무르세요"
        case .hazardous:
            return "외출 자제, 창문 닫아주세요"
        }
    }
    
    /// 이모지
    var emoji: String {
        switch self {
        case .good: return "😊"
        case .moderate: return "🙂"
        case .unhealthyForSensitive: return "😐"
        case .unhealthy: return "😷"
        case .veryUnhealthy: return "🤢"
        case .hazardous: return "☠️"
        }
    }
}

/// 대기 오염 물질
enum Pollutant: String, Codable, Sendable {
    case pm25 = "PM2.5"
    case pm10 = "PM10"
    case ozone = "오존"
    case nitrogenDioxide = "이산화질소"
    case carbonMonoxide = "일산화탄소"
    case sulfurDioxide = "이산화황"
    
    var description: String {
        switch self {
        case .pm25: return "초미세먼지"
        case .pm10: return "미세먼지"
        case .ozone: return "오존"
        case .nitrogenDioxide: return "이산화질소"
        case .carbonMonoxide: return "일산화탄소"
        case .sulfurDioxide: return "이산화황"
        }
    }
}

// MARK: - 자외선 지수 데이터

struct UVIndexData: Codable, Sendable {
    let currentIndex: Int          // 현재 자외선 지수 (0-11+)
    let maxIndex: Int              // 오늘 최대 예상 지수
    let maxTime: Date              // 최대 지수 예상 시간
    let level: UVLevel
    let hourlyForecast: [HourlyUVIndex]
    let lastUpdated: Date
    
    /// 안전 야외 활동 시간 (분)
    var safeExposureTime: Int {
        level.safeExposureMinutes
    }
}

/// 시간별 자외선 지수
struct HourlyUVIndex: Identifiable, Codable, Sendable {
    let id: UUID
    let date: Date
    let uvIndex: Int
    let level: UVLevel
    
    var formattedHour: String {
        date.formatted(.dateTime.hour())
    }
    
    init(id: UUID = UUID(), date: Date, uvIndex: Int) {
        self.id = id
        self.date = date
        self.uvIndex = uvIndex
        self.level = UVLevel(index: uvIndex)
    }
}

/// 자외선 위험 등급
enum UVLevel: String, Codable, Sendable {
    case low = "낮음"
    case moderate = "보통"
    case high = "높음"
    case veryHigh = "매우 높음"
    case extreme = "위험"
    
    /// UV 지수에서 레벨 결정
    init(index: Int) {
        switch index {
        case 0...2: self = .low
        case 3...5: self = .moderate
        case 6...7: self = .high
        case 8...10: self = .veryHigh
        default: self = .extreme
        }
    }
    
    /// 자외선 색상
    var color: Color {
        switch self {
        case .low: return .green
        case .moderate: return .yellow
        case .high: return .orange
        case .veryHigh: return .red
        case .extreme: return .purple
        }
    }
    
    /// SF Symbol
    var symbol: String {
        switch self {
        case .low: return "sun.min.fill"
        case .moderate: return "sun.max.fill"
        case .high: return "sun.max.trianglebadge.exclamationmark.fill"
        case .veryHigh, .extreme: return "exclamationmark.triangle.fill"
        }
    }
    
    /// 안전 노출 시간 (분)
    var safeExposureMinutes: Int {
        switch self {
        case .low: return 60
        case .moderate: return 45
        case .high: return 30
        case .veryHigh: return 15
        case .extreme: return 10
        }
    }
    
    /// 보호 권고
    var protectionAdvice: String {
        switch self {
        case .low:
            return "특별한 보호 불필요"
        case .moderate:
            return "모자, 선글라스 착용 권장"
        case .high:
            return "자외선 차단제 필수, 그늘에서 휴식"
        case .veryHigh:
            return "외출 자제, SPF 50+ 자외선 차단제"
        case .extreme:
            return "정오~오후 3시 외출 삼가"
        }
    }
    
    /// 선크림 SPF 권장
    var recommendedSPF: Int {
        switch self {
        case .low: return 15
        case .moderate: return 30
        case .high: return 30
        case .veryHigh: return 50
        case .extreme: return 50
        }
    }
}

// MARK: - 온도 단위

enum TemperatureUnit: String, Codable, Sendable {
    case celsius = "섭씨"
    case fahrenheit = "화씨"
    
    var symbol: String {
        switch self {
        case .celsius: return "°C"
        case .fahrenheit: return "°F"
        }
    }
    
    /// 섭씨를 해당 단위로 변환
    func convert(fromCelsius celsius: Int) -> Int {
        switch self {
        case .celsius:
            return celsius
        case .fahrenheit:
            return Int(Double(celsius) * 9.0 / 5.0 + 32)
        }
    }
}

// MARK: - 위젯 설정

struct WidgetSettings: Codable, Sendable {
    var temperatureUnit: TemperatureUnit = .celsius
    var showFeelsLike: Bool = true
    var showHumidity: Bool = true
    var showWind: Bool = true
    var showPrecipitation: Bool = true
    var use24HourFormat: Bool = true
    
    /// UserDefaults에서 로드
    static func load() -> WidgetSettings {
        guard let data = UserDefaults.shared?.data(forKey: "widgetSettings"),
              let settings = try? JSONDecoder().decode(WidgetSettings.self, from: data) else {
            return WidgetSettings()
        }
        return settings
    }
    
    /// UserDefaults에 저장
    func save() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        UserDefaults.shared?.set(data, forKey: "widgetSettings")
    }
}

// MARK: - UserDefaults Extension

extension UserDefaults {
    /// App Group 공유 UserDefaults
    static var shared: UserDefaults? {
        UserDefaults(suiteName: "group.com.higlab.weatherwidget")
    }
}
