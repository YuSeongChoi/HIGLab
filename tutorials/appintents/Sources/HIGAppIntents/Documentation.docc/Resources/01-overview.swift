import AppIntents

/*
 App Intents (iOS 16+)
 
 앱의 기능을 시스템에 노출하는 프레임워크입니다.
 
 주요 기능:
 - Siri 음성 명령으로 앱 제어
 - 단축어 앱에서 자동화
 - Spotlight 검색 결과에 표시
 - 위젯 버튼/토글 동작
 - Focus 필터
 
 핵심 프로토콜:
 - AppIntent: 단일 작업 정의
 - AppEntity: 검색/선택 가능한 객체
 - AppShortcutsProvider: 단축어 노출
*/

// 가장 간단한 Intent
struct OpenAppIntent: AppIntent {
    static var title: LocalizedStringResource = "앱 열기"
    
    func perform() async throws -> some IntentResult {
        // 앱을 열고 특정 화면으로 이동
        return .result()
    }
}
