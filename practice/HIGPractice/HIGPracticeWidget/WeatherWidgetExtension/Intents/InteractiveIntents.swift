import AppIntents
import WidgetKit
import SwiftUI

// MARK: - 인터랙티브 위젯 Intent (iOS 17+)
// HIG: 인터랙티브 요소는 명확한 목적이 있을 때만 추가
// Button과 Toggle을 사용한 위젯 내 직접 상호작용

// MARK: - 날씨 새로고침 Intent

/// 위젯에서 날씨 데이터를 즉시 새로고침하는 AppIntent
/// HIG: 사용자가 최신 정보를 원할 때 즉각적인 피드백 제공
struct RefreshWeatherIntent: AppIntent {
    static var title: LocalizedStringResource = "날씨 새로고침"
    static var description: IntentDescription = IntentDescription(
        "위젯의 날씨 정보를 즉시 업데이트합니다."
    )
    
    /// 새로고침할 도시 (선택적)
    @Parameter(title: "도시")
    var city: CityOption?
    
    init() {}
    
    init(city: CityOption? = nil) {
        self.city = city
    }
    
    /// Intent 실행
    func perform() async throws -> some IntentResult {
        // 캐시 초기화
        if let city = city {
            await WeatherService.shared.clearCache(for: city)
        } else {
            await WeatherService.shared.clearCache()
        }
        
        // 모든 날씨 위젯 타임라인 강제 갱신
        WidgetCenter.shared.reloadAllTimelines()
        
        // 햅틱 피드백 (메인 앱에서 실행 시)
        #if os(iOS)
        await MainActor.run {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
        #endif
        
        return .result()
    }
}

// MARK: - 온도 단위 토글 Intent

/// 섭씨/화씨 단위를 토글하는 AppIntent
/// HIG: Toggle은 즉각적인 상태 변경에 사용
struct ToggleTemperatureUnitIntent: AppIntent {
    static var title: LocalizedStringResource = "온도 단위 변경"
    static var description: IntentDescription = IntentDescription(
        "섭씨와 화씨 사이를 전환합니다."
    )
    
    /// 현재 단위 (토글할 기준)
    @Parameter(title: "현재 단위")
    var currentUnit: TemperatureUnitOption?
    
    init() {}
    
    init(currentUnit: TemperatureUnitOption) {
        self.currentUnit = currentUnit
    }
    
    func perform() async throws -> some IntentResult {
        // 현재 설정 로드
        var settings = WidgetSettings.load()
        
        // 단위 토글
        if let current = currentUnit {
            settings.temperatureUnit = current == .celsius ? .fahrenheit : .celsius
        } else {
            settings.temperatureUnit = settings.temperatureUnit == .celsius ? .fahrenheit : .celsius
        }
        
        // 설정 저장
        settings.save()
        
        // 위젯 갱신
        WidgetCenter.shared.reloadAllTimelines()
        
        return .result()
    }
}

// MARK: - 도시 빠른 변경 Intent

/// 도시를 빠르게 변경하는 AppIntent
/// HIG: 자주 사용하는 액션은 쉽게 접근 가능해야 함
struct QuickChangeCityIntent: AppIntent {
    static var title: LocalizedStringResource = "도시 변경"
    static var description: IntentDescription = IntentDescription(
        "날씨를 확인할 도시를 빠르게 변경합니다."
    )
    
    @Parameter(title: "도시")
    var city: CityOption
    
    init() {
        self.city = .seoul
    }
    
    init(city: CityOption) {
        self.city = city
    }
    
    func perform() async throws -> some IntentResult {
        // 선택된 도시를 UserDefaults에 저장
        UserDefaults.shared?.set(city.rawValue, forKey: "lastSelectedCity")
        
        // 해당 도시의 캐시 초기화 후 새로 로드
        await WeatherService.shared.clearCache(for: city)
        
        // 위젯 갱신
        WidgetCenter.shared.reloadAllTimelines()
        
        return .result()
    }
}

// MARK: - 알림 설정 토글 Intent

/// 날씨 알림을 토글하는 AppIntent
struct ToggleWeatherAlertIntent: AppIntent {
    static var title: LocalizedStringResource = "날씨 알림 토글"
    static var description: IntentDescription = IntentDescription(
        "날씨 알림을 켜거나 끕니다."
    )
    
    @Parameter(title: "알림 활성화")
    var isEnabled: Bool
    
    init() {
        self.isEnabled = true
    }
    
    init(isEnabled: Bool) {
        self.isEnabled = isEnabled
    }
    
    func perform() async throws -> some IntentResult {
        // 알림 설정 저장
        UserDefaults.shared?.set(isEnabled, forKey: "weatherAlertEnabled")
        
        // 위젯 갱신
        WidgetCenter.shared.reloadAllTimelines()
        
        return .result()
    }
}

// MARK: - 위치 기반 날씨 Intent

/// 현재 위치의 날씨를 가져오는 AppIntent
struct GetCurrentLocationWeatherIntent: AppIntent {
    static var title: LocalizedStringResource = "현재 위치 날씨"
    static var description: IntentDescription = IntentDescription(
        "현재 위치의 날씨 정보를 가져옵니다."
    )
    
    func perform() async throws -> some IntentResult {
        // 실제 구현에서는 CoreLocation을 사용하여 위치 가져오기
        // 여기서는 기본값으로 서울 사용
        
        UserDefaults.shared?.set(true, forKey: "useCurrentLocation")
        
        // 위젯 갱신
        WidgetCenter.shared.reloadAllTimelines()
        
        return .result()
    }
}

// MARK: - 앱 열기 Intent

/// 메인 앱을 여는 AppIntent
struct OpenWeatherAppIntent: AppIntent {
    static var title: LocalizedStringResource = "날씨 앱 열기"
    static var description: IntentDescription = IntentDescription(
        "메인 날씨 앱을 엽니다."
    )
    
    /// 열 때 표시할 도시
    @Parameter(title: "도시")
    var city: CityOption?
    
    /// 열 때 표시할 화면
    @Parameter(title: "화면")
    var screen: WeatherScreenOption?
    
    init() {}
    
    init(city: CityOption? = nil, screen: WeatherScreenOption? = nil) {
        self.city = city
        self.screen = screen
    }
    
    static var openAppWhenRun: Bool { true }
    
    func perform() async throws -> some IntentResult {
        // 딥링크 URL 생성
        var urlComponents = URLComponents()
        urlComponents.scheme = "weatherwidget"
        urlComponents.host = "open"
        
        var queryItems: [URLQueryItem] = []
        if let city = city {
            queryItems.append(URLQueryItem(name: "city", value: city.rawValue))
        }
        if let screen = screen {
            queryItems.append(URLQueryItem(name: "screen", value: screen.rawValue))
        }
        urlComponents.queryItems = queryItems.isEmpty ? nil : queryItems
        
        return .result()
    }
}

/// 앱 화면 옵션
enum WeatherScreenOption: String, AppEnum {
    case current = "현재 날씨"
    case hourly = "시간별 예보"
    case daily = "주간 예보"
    case airQuality = "대기질"
    case uvIndex = "자외선 지수"
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "화면")
    
    static var caseDisplayRepresentations: [WeatherScreenOption: DisplayRepresentation] = [
        .current: DisplayRepresentation(title: "현재 날씨"),
        .hourly: DisplayRepresentation(title: "시간별 예보"),
        .daily: DisplayRepresentation(title: "주간 예보"),
        .airQuality: DisplayRepresentation(title: "대기질"),
        .uvIndex: DisplayRepresentation(title: "자외선 지수"),
    ]
}

// MARK: - 즐겨찾기 도시 추가/제거 Intent

/// 즐겨찾기 도시를 관리하는 AppIntent
struct ToggleFavoriteCityIntent: AppIntent {
    static var title: LocalizedStringResource = "즐겨찾기 토글"
    static var description: IntentDescription = IntentDescription(
        "도시를 즐겨찾기에 추가하거나 제거합니다."
    )
    
    @Parameter(title: "도시")
    var city: CityOption
    
    init() {
        self.city = .seoul
    }
    
    init(city: CityOption) {
        self.city = city
    }
    
    func perform() async throws -> some IntentResult {
        // 현재 즐겨찾기 목록 로드
        var favorites = UserDefaults.shared?.stringArray(forKey: "favoriteCities") ?? []
        
        // 토글
        if let index = favorites.firstIndex(of: city.rawValue) {
            favorites.remove(at: index)
        } else {
            favorites.append(city.rawValue)
        }
        
        // 저장
        UserDefaults.shared?.set(favorites, forKey: "favoriteCities")
        
        // 위젯 갱신
        WidgetCenter.shared.reloadAllTimelines()
        
        return .result()
    }
}

// MARK: - App Shortcuts Provider

/// Siri 및 Shortcuts 앱에서 사용할 수 있는 단축어 정의
struct WeatherShortcutsProvider: AppShortcutsProvider {
    
    /// 제공하는 단축어 목록
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: RefreshWeatherIntent(),
            phrases: [
                "날씨 새로고침",
                "\(.applicationName) 업데이트",
                "날씨 정보 갱신"
            ],
            shortTitle: "날씨 새로고침",
            systemImageName: "arrow.clockwise"
        )
        
        AppShortcut(
            intent: GetCurrentLocationWeatherIntent(),
            phrases: [
                "현재 위치 날씨",
                "지금 여기 날씨",
                "\(.applicationName)에서 내 위치 날씨"
            ],
            shortTitle: "현재 위치 날씨",
            systemImageName: "location.fill"
        )
        
        AppShortcut(
            intent: OpenWeatherAppIntent(),
            phrases: [
                "\(.applicationName) 열기",
                "날씨 앱 열기"
            ],
            shortTitle: "날씨 앱 열기",
            systemImageName: "sun.max.fill"
        )
    }
}
