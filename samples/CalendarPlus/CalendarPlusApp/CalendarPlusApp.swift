import SwiftUI
import EventKit

// MARK: - 앱 진입점
@main
struct CalendarPlusApp: App {
    // EventKit 관리자를 환경 객체로 주입
    @StateObject private var eventKitManager = EventKitManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(eventKitManager)
        }
    }
}

// MARK: - 앱 탭 타입
enum AppTab: String, CaseIterable {
    case calendar = "캘린더"
    case reminders = "미리알림"
    
    var symbolName: String {
        switch self {
        case .calendar: return "calendar"
        case .reminders: return "checklist"
        }
    }
}
