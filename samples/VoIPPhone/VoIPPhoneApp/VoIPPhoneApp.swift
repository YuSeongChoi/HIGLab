import SwiftUI
import CallKit

// MARK: - VoIP Phone 앱
// CallKit을 활용한 VoIP 전화 앱의 진입점

/// 앱 진입점
@main
struct VoIPPhoneApp: App {
    // 앱 델리게이트 연결
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // 통화 관리자 (환경 객체로 주입)
    @StateObject private var callManager = CallManager.shared
    @StateObject private var contactStore = ContactStore.shared
    @StateObject private var historyStore = CallHistoryStore.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(callManager)
                .environmentObject(contactStore)
                .environmentObject(historyStore)
        }
    }
}

// MARK: - 앱 델리게이트
// 앱 생명주기 및 푸시 알림 처리

/// 앱 델리게이트 클래스
class AppDelegate: NSObject, UIApplicationDelegate {
    
    /// 앱 시작 시 호출
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // CallKit 프로바이더 설정
        CallManager.shared.setupProvider()
        
        // 푸시 알림 권한 요청
        requestNotificationPermission()
        
        // VoIP 푸시 등록
        registerForVoIPPush()
        
        return true
    }
    
    /// 알림 권한 요청
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if let error = error {
                print("알림 권한 요청 실패: \(error.localizedDescription)")
            } else {
                print("알림 권한 \(granted ? "허용됨" : "거부됨")")
            }
        }
    }
    
    /// VoIP 푸시 등록
    private func registerForVoIPPush() {
        // 실제 앱에서는 PushKit을 사용하여 VoIP 푸시를 등록
        // 이 샘플에서는 시뮬레이션만 수행
        print("VoIP 푸시 등록 시뮬레이션")
    }
}

// MARK: - 메인 탭 뷰
// 앱의 주요 탭 네비게이션

/// 탭 열거형
enum AppTab: Int, CaseIterable {
    case keypad     // 키패드
    case recent     // 최근 기록
    case contacts   // 연락처
    
    var title: String {
        switch self {
        case .keypad: return "키패드"
        case .recent: return "최근 기록"
        case .contacts: return "연락처"
        }
    }
    
    var iconName: String {
        switch self {
        case .keypad: return "circle.grid.3x3"
        case .recent: return "clock"
        case .contacts: return "person.crop.circle"
        }
    }
}

/// 메인 콘텐츠 뷰
struct ContentView: View {
    @EnvironmentObject var callManager: CallManager
    @State private var selectedTab: AppTab = .keypad
    
    var body: some View {
        ZStack {
            // 메인 탭 뷰
            TabView(selection: $selectedTab) {
                ForEach(AppTab.allCases, id: \.rawValue) { tab in
                    tabContent(for: tab)
                        .tabItem {
                            Image(systemName: tab.iconName)
                            Text(tab.title)
                        }
                        .tag(tab)
                }
            }
            .accentColor(.green)
            
            // 통화 중이면 통화 화면 오버레이
            if callManager.currentCall != nil {
                ActiveCallView()
                    .transition(.move(edge: .bottom))
            }
            
            // 수신 전화가 오면 수신 화면 오버레이
            if callManager.hasIncomingCall {
                IncomingCallView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: callManager.currentCall != nil)
        .animation(.easeInOut, value: callManager.hasIncomingCall)
    }
    
    /// 탭별 콘텐츠
    @ViewBuilder
    private func tabContent(for tab: AppTab) -> some View {
        switch tab {
        case .keypad:
            DialerView()
        case .recent:
            CallHistoryView()
        case .contacts:
            ContactsView()
        }
    }
}

// MARK: - 프리뷰

#Preview {
    ContentView()
        .environmentObject(CallManager.shared)
        .environmentObject(ContactStore.shared)
        .environmentObject(CallHistoryStore.shared)
}
