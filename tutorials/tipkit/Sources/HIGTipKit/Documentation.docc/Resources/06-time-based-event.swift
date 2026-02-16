import SwiftUI
import TipKit

// MARK: - 시간 기반 이벤트 조건
// 특정 기간 내 이벤트 횟수를 조건으로 사용합니다.

struct RecentActivityTip: Tip {
    static let appOpened = Event(id: "appOpened")
    
    var title: Text {
        Text("연속 사용 보너스")
    }
    
    var message: Text? {
        Text("꾸준히 사용해주셔서 감사해요! 특별 기능을 확인해보세요.")
    }
    
    var image: Image? {
        Image(systemName: "gift.fill")
    }
    
    var rules: [Rule] {
        // 최근 7일 내에 3번 이상 앱 실행 시 팁 표시
        #Rule(Self.appOpened.donations
            .filter { $0.date > Date.now.addingTimeInterval(-7 * 24 * 60 * 60) }
            .count >= 3) { $0 }
    }
}

// 앱 시작 시 이벤트 기록
@main
struct MyApp: App {
    init() {
        Task {
            try? await Tips.configure()
            // 앱 실행 이벤트 기록
            RecentActivityTip.appOpened.donate()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
