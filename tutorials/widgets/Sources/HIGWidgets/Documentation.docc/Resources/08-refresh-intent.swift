import AppIntents
import WidgetKit

// MARK: - Refresh Weather Intent
// iOS 17+ 인터랙티브 위젯을 위한 App Intent입니다.
// 버튼을 탭하면 타임라인을 강제 갱신합니다.

struct RefreshWeatherIntent: AppIntent {
    static var title: LocalizedStringResource = "날씨 새로고침"
    static var description = IntentDescription("위젯의 날씨 데이터를 새로고침합니다.")
    
    func perform() async throws -> some IntentResult {
        // 모든 위젯 타임라인 갱신 요청
        WidgetCenter.shared.reloadAllTimelines()
        
        // 또는 특정 위젯만 갱신:
        // WidgetCenter.shared.reloadTimelines(ofKind: "WeatherWidget")
        
        return .result()
    }
}

// MARK: - Open App Intent
// 위젯에서 앱을 열면서 특정 화면으로 이동하는 Intent

struct OpenWeatherDetailIntent: AppIntent {
    static var title: LocalizedStringResource = "날씨 상세 보기"
    static var description = IntentDescription("앱을 열어 상세 날씨 정보를 확인합니다.")
    
    /// 어떤 도시 상세 화면을 열지
    @Parameter(title: "도시")
    var city: CityOption
    
    /// 앱을 포그라운드로 전환
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult {
        // 앱에서 UserDefaults로 받아 처리
        UserDefaults(suiteName: "group.com.example.weatherwidget")?
            .set(city.rawValue, forKey: "selectedCity")
        
        return .result()
    }
}

// MARK: - Toggle Favorite Intent
// Toggle을 위한 Intent 예시

struct ToggleFavoriteIntent: AppIntent {
    static var title: LocalizedStringResource = "즐겨찾기 토글"
    
    @Parameter(title: "도시")
    var city: CityOption
    
    func perform() async throws -> some IntentResult {
        // 즐겨찾기 상태 토글
        let defaults = UserDefaults(suiteName: "group.com.example.weatherwidget")
        let key = "favorite_\(city.rawValue)"
        let current = defaults?.bool(forKey: key) ?? false
        defaults?.set(!current, forKey: key)
        
        // 위젯 갱신
        WidgetCenter.shared.reloadAllTimelines()
        
        return .result()
    }
}
