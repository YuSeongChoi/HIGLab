import AppIntents
import WidgetKit

// MARK: - Select City Intent
// WidgetConfigurationIntent를 채택하면 위젯 설정 UI가 자동 생성됩니다.
// 사용자가 위젯을 길게 눌러 "위젯 편집"을 탭하면 이 설정이 나타납니다.

struct SelectCityIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "도시 선택"
    static var description = IntentDescription("날씨를 확인할 도시를 선택하세요.")
    
    // MARK: - Parameters
    // @Parameter로 설정 항목을 정의합니다.
    // default 값을 지정하면 처음 추가할 때 기본값이 됩니다.
    
    @Parameter(title: "도시", default: .seoul)
    var city: CityOption
    
    @Parameter(title: "단위", default: .celsius)
    var temperatureUnit: TemperatureUnit
    
    @Parameter(title: "시간별 예보 표시", default: true)
    var showHourlyForecast: Bool
    
    init() {}
    
    init(city: CityOption, temperatureUnit: TemperatureUnit = .celsius, showHourlyForecast: Bool = true) {
        self.city = city
        self.temperatureUnit = temperatureUnit
        self.showHourlyForecast = showHourlyForecast
    }
}

// MARK: - Temperature Unit Enum
enum TemperatureUnit: String, AppEnum {
    case celsius = "섭씨"
    case fahrenheit = "화씨"
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "온도 단위")
    
    static var caseDisplayRepresentations: [TemperatureUnit: DisplayRepresentation] = [
        .celsius: "°C (섭씨)",
        .fahrenheit: "°F (화씨)"
    ]
    
    /// 온도 변환
    func convert(_ celsius: Int) -> Int {
        switch self {
        case .celsius:
            return celsius
        case .fahrenheit:
            return Int(Double(celsius) * 9/5 + 32)
        }
    }
    
    /// 표시용 문자열
    func format(_ celsius: Int) -> String {
        let value = convert(celsius)
        switch self {
        case .celsius:
            return "\(value)°C"
        case .fahrenheit:
            return "\(value)°F"
        }
    }
}
