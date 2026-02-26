import AppIntents
import WidgetKit
import CoreLocation

// MARK: - 도시 선택 Intent (iOS 17+)
// HIG: Personalized 원칙 - 사용자가 원하는 도시 선택 가능

/// 도시 옵션 열거형 - AppEnum 프로토콜 준수
enum CityOption: String, AppEnum, Codable, CaseIterable, Sendable {
    case seoul = "서울"
    case busan = "부산"
    case jeju = "제주"
    case daejeon = "대전"
    case gwangju = "광주"
    case incheon = "인천"
    case daegu = "대구"
    
    // MARK: - AppEnum 필수 구현
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "도시")
    
    static var caseDisplayRepresentations: [CityOption: DisplayRepresentation] = [
        .seoul: DisplayRepresentation(
            title: "서울",
            subtitle: "대한민국 수도",
            image: .init(systemName: "building.2.fill")
        ),
        .busan: DisplayRepresentation(
            title: "부산",
            subtitle: "해운대, 광안리",
            image: .init(systemName: "water.waves")
        ),
        .jeju: DisplayRepresentation(
            title: "제주",
            subtitle: "아름다운 섬",
            image: .init(systemName: "mountain.2.fill")
        ),
        .daejeon: DisplayRepresentation(
            title: "대전",
            subtitle: "과학의 도시",
            image: .init(systemName: "atom")
        ),
        .gwangju: DisplayRepresentation(
            title: "광주",
            subtitle: "예술의 도시",
            image: .init(systemName: "paintbrush.fill")
        ),
        .incheon: DisplayRepresentation(
            title: "인천",  
            subtitle: "인천국제공항",
            image: .init(systemName: "airplane")
        ),
        .daegu: DisplayRepresentation(
            title: "대구",
            subtitle: "사과의 도시",
            image: .init(systemName: "leaf.fill")
        ),
    ]
    
    // MARK: - 도시 정보
    
    /// 표시용 이름
    var displayName: String {
        rawValue
    }
    
    /// 위치 좌표
    var coordinate: CLLocation {
        switch self {
        case .seoul: return CLLocation(latitude: 37.5665, longitude: 126.9780)
        case .busan: return CLLocation(latitude: 35.1796, longitude: 129.0756)
        case .jeju: return CLLocation(latitude: 33.4996, longitude: 126.5312)
        case .daejeon: return CLLocation(latitude: 36.3504, longitude: 127.3845)
        case .gwangju: return CLLocation(latitude: 35.1595, longitude: 126.8526)
        case .incheon: return CLLocation(latitude: 37.4563, longitude: 126.7052)
        case .daegu: return CLLocation(latitude: 35.8714, longitude: 128.6014)
        }
    }
    
    /// 시간대
    var timeZone: TimeZone {
        // 한국은 모두 동일한 시간대
        TimeZone(identifier: "Asia/Seoul") ?? .current
    }
    
    /// 딥링크 URL
    var deepLinkURL: URL {
        URL(string: "weatherwidget://city/\(rawValue)")!
    }
}

// MARK: - 도시 선택 Widget Configuration Intent

/// 위젯 설정용 도시 선택 Intent
struct SelectCityIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "도시 선택"
    static var description: IntentDescription = IntentDescription(
        "날씨를 확인할 도시를 선택하세요.",
        categoryName: "날씨 설정"
    )
    
    /// 선택된 도시 (기본값: 서울)
    @Parameter(title: "도시", default: .seoul)
    var city: CityOption
    
    /// 온도 단위 선택
    @Parameter(title: "온도 단위", default: .celsius)
    var temperatureUnit: TemperatureUnitOption
    
    /// 강수 확률 표시 여부
    @Parameter(title: "강수 확률 표시", default: true)
    var showPrecipitation: Bool
    
    init() {}
    
    init(city: CityOption, temperatureUnit: TemperatureUnitOption = .celsius, showPrecipitation: Bool = true) {
        self.city = city
        self.temperatureUnit = temperatureUnit
        self.showPrecipitation = showPrecipitation
    }
}

// MARK: - 온도 단위 옵션

enum TemperatureUnitOption: String, AppEnum, Codable {
    case celsius = "섭씨"
    case fahrenheit = "화씨"
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "온도 단위")
    
    static var caseDisplayRepresentations: [TemperatureUnitOption: DisplayRepresentation] = [
        .celsius: DisplayRepresentation(
            title: "섭씨 (°C)",
            subtitle: "한국, 유럽 등",
            image: .init(systemName: "thermometer.medium")
        ),
        .fahrenheit: DisplayRepresentation(
            title: "화씨 (°F)",
            subtitle: "미국 등",
            image: .init(systemName: "thermometer.medium")
        ),
    ]
    
    /// 온도 변환
    func convert(celsius: Int) -> Int {
        switch self {
        case .celsius:
            return celsius
        case .fahrenheit:
            return Int(Double(celsius) * 9.0 / 5.0 + 32)
        }
    }
    
    /// 단위 기호
    var symbol: String {
        switch self {
        case .celsius: return "°"
        case .fahrenheit: return "°F"
        }
    }
}

// MARK: - 대기질 위젯용 Intent

/// 대기질 위젯 설정 Intent
struct AirQualityConfigIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "대기질 설정"
    static var description: IntentDescription = IntentDescription(
        "대기질을 확인할 도시를 선택하세요.",
        categoryName: "대기질 설정"
    )
    
    @Parameter(title: "도시", default: .seoul)
    var city: CityOption
    
    /// 상세 정보 표시 여부
    @Parameter(title: "상세 정보 표시", default: true)
    var showDetails: Bool
    
    init() {}
    
    init(city: CityOption, showDetails: Bool = true) {
        self.city = city
        self.showDetails = showDetails
    }
}

// MARK: - 자외선 지수 위젯용 Intent

/// 자외선 지수 위젯 설정 Intent
struct UVIndexConfigIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "자외선 지수 설정"
    static var description: IntentDescription = IntentDescription(
        "자외선 지수를 확인할 도시를 선택하세요.",
        categoryName: "자외선 설정"
    )
    
    @Parameter(title: "도시", default: .seoul)
    var city: CityOption
    
    /// 시간별 예보 표시 여부
    @Parameter(title: "시간별 예보 표시", default: true)
    var showHourlyForecast: Bool
    
    init() {}
    
    init(city: CityOption, showHourlyForecast: Bool = true) {
        self.city = city
        self.showHourlyForecast = showHourlyForecast
    }
}

// MARK: - 주간 예보 위젯용 Intent

/// 주간 예보 위젯 설정 Intent
struct WeeklyForecastConfigIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "주간 예보 설정"
    static var description: IntentDescription = IntentDescription(
        "주간 예보를 확인할 도시를 선택하세요.",
        categoryName: "예보 설정"
    )
    
    @Parameter(title: "도시", default: .seoul)
    var city: CityOption
    
    @Parameter(title: "온도 단위", default: .celsius)
    var temperatureUnit: TemperatureUnitOption
    
    /// 표시할 일수
    @Parameter(title: "예보 일수", default: .sevenDays)
    var forecastDays: ForecastDaysOption
    
    init() {}
    
    init(city: CityOption, temperatureUnit: TemperatureUnitOption = .celsius, forecastDays: ForecastDaysOption = .sevenDays) {
        self.city = city
        self.temperatureUnit = temperatureUnit
        self.forecastDays = forecastDays
    }
}

/// 예보 일수 옵션
enum ForecastDaysOption: Int, AppEnum {
    case threeDays = 3
    case fiveDays = 5
    case sevenDays = 7
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "예보 일수")
    
    static var caseDisplayRepresentations: [ForecastDaysOption: DisplayRepresentation] = [
        .threeDays: DisplayRepresentation(title: "3일"),
        .fiveDays: DisplayRepresentation(title: "5일"),
        .sevenDays: DisplayRepresentation(title: "7일"),
    ]
}

// MARK: - 시간별 예보 위젯용 Intent

/// 시간별 예보 위젯 설정 Intent
struct HourlyForecastConfigIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "시간별 예보 설정"
    static var description: IntentDescription = IntentDescription(
        "시간별 예보를 확인할 도시를 선택하세요.",
        categoryName: "예보 설정"
    )
    
    @Parameter(title: "도시", default: .seoul)
    var city: CityOption
    
    @Parameter(title: "온도 단위", default: .celsius)
    var temperatureUnit: TemperatureUnitOption
    
    /// 표시할 시간
    @Parameter(title: "예보 시간", default: .twelveHours)
    var forecastHours: ForecastHoursOption
    
    init() {}
    
    init(city: CityOption, temperatureUnit: TemperatureUnitOption = .celsius, forecastHours: ForecastHoursOption = .twelveHours) {
        self.city = city
        self.temperatureUnit = temperatureUnit
        self.forecastHours = forecastHours
    }
}

/// 예보 시간 옵션
enum ForecastHoursOption: Int, AppEnum {
    case sixHours = 6
    case twelveHours = 12
    case twentyFourHours = 24
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "예보 시간")
    
    static var caseDisplayRepresentations: [ForecastHoursOption: DisplayRepresentation] = [
        .sixHours: DisplayRepresentation(title: "6시간"),
        .twelveHours: DisplayRepresentation(title: "12시간"),
        .twentyFourHours: DisplayRepresentation(title: "24시간"),
    ]
}
