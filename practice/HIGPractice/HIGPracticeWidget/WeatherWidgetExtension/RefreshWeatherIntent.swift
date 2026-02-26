import AppIntents
import WidgetKit

// MARK: - 인터랙티브 위젯: 새로고침 버튼 (iOS 17+)
// HIG: 인터랙티브 요소는 명확한 목적이 있을 때만 추가

struct RefreshWeatherIntent: AppIntent {
    static var title: LocalizedStringResource = "날씨 새로고침"
    static var description: IntentDescription = "위젯의 날씨 정보를 즉시 업데이트합니다."
    
    func perform() async throws -> some IntentResult {
        // 모든 날씨 위젯 타임라인 강제 갱신
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
