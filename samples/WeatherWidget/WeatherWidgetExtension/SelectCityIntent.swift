import AppIntents
import WidgetKit
import CoreLocation

// MARK: - 도시 선택 (HIG: Personalized 원칙)

enum CityOption: String, AppEnum {
    case seoul = "서울"
    case busan = "부산"
    case jeju = "제주"
    case daejeon = "대전"
    case gwangju = "광주"
    case incheon = "인천"
    case daegu = "대구"
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "도시")
    
    static var caseDisplayRepresentations: [CityOption: DisplayRepresentation] = [
        .seoul: DisplayRepresentation(title: "서울", subtitle: "대한민국 수도"),
        .busan: DisplayRepresentation(title: "부산", subtitle: "해운대, 광안리"),
        .jeju: DisplayRepresentation(title: "제주", subtitle: "제주도"),
        .daejeon: DisplayRepresentation(title: "대전", subtitle: "충청남도"),
        .gwangju: DisplayRepresentation(title: "광주", subtitle: "전라남도"),
        .incheon: DisplayRepresentation(title: "인천", subtitle: "인천광역시"),
        .daegu: DisplayRepresentation(title: "대구", subtitle: "경상북도"),
    ]
    
    var coordinate: CLLocation {
        switch self {
        case .seoul: CLLocation(latitude: 37.5665, longitude: 126.9780)
        case .busan: CLLocation(latitude: 35.1796, longitude: 129.0756)
        case .jeju: CLLocation(latitude: 33.4996, longitude: 126.5312)
        case .daejeon: CLLocation(latitude: 36.3504, longitude: 127.3845)
        case .gwangju: CLLocation(latitude: 35.1595, longitude: 126.8526)
        case .incheon: CLLocation(latitude: 37.4563, longitude: 126.7052)
        case .daegu: CLLocation(latitude: 35.8714, longitude: 128.6014)
        }
    }
}

struct SelectCityIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "도시 선택"
    static var description: IntentDescription = "날씨를 확인할 도시를 선택하세요."
    
    @Parameter(title: "도시", default: .seoul)
    var city: CityOption
}
