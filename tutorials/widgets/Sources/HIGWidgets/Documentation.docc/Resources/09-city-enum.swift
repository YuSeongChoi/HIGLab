import AppIntents

// MARK: - City Option Enum
// AppEnum을 채택하면 App Intents 시스템에서 사용자가 선택할 수 있습니다.
// 위젯 설정 UI에 자동으로 선택 목록이 생성됩니다.

enum CityOption: String, AppEnum {
    case seoul = "서울"
    case busan = "부산"
    case jeju = "제주"
    case daejeon = "대전"
    case gwangju = "광주"
    case incheon = "인천"
    case daegu = "대구"
    case ulsan = "울산"
    
    // MARK: - Type Display
    // 시스템 UI에서 이 타입을 어떻게 표시할지
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "도시")
    
    // MARK: - Case Display
    // 각 케이스를 어떻게 표시할지 (아이콘 포함 가능)
    static var caseDisplayRepresentations: [CityOption: DisplayRepresentation] = [
        .seoul: DisplayRepresentation(
            title: "서울",
            subtitle: "대한민국 수도",
            image: .init(systemName: "building.2")
        ),
        .busan: DisplayRepresentation(
            title: "부산",
            subtitle: "해운대, 광안리",
            image: .init(systemName: "water.waves")
        ),
        .jeju: DisplayRepresentation(
            title: "제주",
            subtitle: "한라산, 올레길",
            image: .init(systemName: "mountain.2")
        ),
        .daejeon: DisplayRepresentation(
            title: "대전",
            subtitle: "과학도시",
            image: .init(systemName: "atom")
        ),
        .gwangju: DisplayRepresentation(
            title: "광주",
            subtitle: "문화예술의 도시",
            image: .init(systemName: "paintpalette")
        ),
        .incheon: DisplayRepresentation(
            title: "인천",
            subtitle: "국제공항",
            image: .init(systemName: "airplane")
        ),
        .daegu: DisplayRepresentation(
            title: "대구",
            subtitle: "동성로, 팔공산",
            image: .init(systemName: "leaf")
        ),
        .ulsan: DisplayRepresentation(
            title: "울산",
            subtitle: "산업수도",
            image: .init(systemName: "gearshape.2")
        )
    ]
}

// MARK: - City Coordinate Extension
// 각 도시의 GPS 좌표 (WeatherKit API 호출용)
extension CityOption {
    var latitude: Double {
        switch self {
        case .seoul: 37.5665
        case .busan: 35.1796
        case .jeju: 33.4996
        case .daejeon: 36.3504
        case .gwangju: 35.1595
        case .incheon: 37.4563
        case .daegu: 35.8714
        case .ulsan: 35.5384
        }
    }
    
    var longitude: Double {
        switch self {
        case .seoul: 126.9780
        case .busan: 129.0756
        case .jeju: 126.5312
        case .daejeon: 127.3845
        case .gwangju: 126.8526
        case .incheon: 126.7052
        case .daegu: 128.6014
        case .ulsan: 129.3114
        }
    }
}
