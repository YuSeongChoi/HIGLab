import SwiftUI
import UserNotifications

// MARK: - 메인 콘텐츠 뷰
// 탭 기반 네비게이션으로 알림 목록, 히스토리, 설정을 관리합니다.
// 권한이 없으면 권한 요청 화면을 먼저 표시합니다.

struct ContentView: View {
    @EnvironmentObject var notificationStore: NotificationStore
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var historyStore: NotificationHistoryStore
    
    @State private var selectedTab: Tab = .notifications
    @State private var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @State private var showingAddSheet = false
    
    enum Tab: String {
        case notifications = "알림"
        case history = "히스토리"
        case settings = "설정"
        
        var symbol: String {
            switch self {
            case .notifications: "bell.fill"
            case .history: "clock.fill"
            case .settings: "gearshape.fill"
            }
        }
    }
    
    var body: some View {
        Group {
            // 권한 상태에 따른 화면 분기
            switch authorizationStatus {
            case .notDetermined:
                PermissionView(status: $authorizationStatus)
                
            case .denied:
                PermissionDeniedView()
                
            case .authorized, .provisional, .ephemeral:
                mainTabView
                
            @unknown default:
                PermissionView(status: $authorizationStatus)
            }
        }
        .task {
            await checkAuthorizationStatus()
        }
    }
    
    // MARK: - 메인 탭 뷰
    
    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            // 알림 목록 탭
            NavigationStack {
                NotificationListView(showingAddSheet: $showingAddSheet)
            }
            .tabItem {
                Label(Tab.notifications.rawValue, systemImage: Tab.notifications.symbol)
            }
            .tag(Tab.notifications)
            
            // 히스토리 탭
            NavigationStack {
                HistoryView()
            }
            .tabItem {
                Label(Tab.history.rawValue, systemImage: Tab.history.symbol)
            }
            .tag(Tab.history)
            .badge(historyStore.history.filter { !$0.wasOpened }.count)
            
            // 설정 탭
            NavigationStack {
                NotificationSettingsView()
            }
            .tabItem {
                Label(Tab.settings.rawValue, systemImage: Tab.settings.symbol)
            }
            .tag(Tab.settings)
        }
        .sheet(isPresented: $showingAddSheet) {
            NotificationDetailView(mode: .add) { newItem in
                notificationStore.addNotification(newItem)
            }
        }
    }
    
    // MARK: - 권한 확인
    
    private func checkAuthorizationStatus() async {
        authorizationStatus = await NotificationService.shared.checkAuthorizationStatus()
    }
}

// MARK: - 권한 거부 안내 뷰

struct PermissionDeniedView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "bell.slash.fill")
                .font(.system(size: 80))
                .foregroundStyle(.secondary)
            
            Text("알림이 비활성화되어 있습니다")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("알림을 받으려면 설정에서\n NotifyMe의 알림을 허용해주세요.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            
            Button {
                openSettings()
            } label: {
                Label("설정 열기", systemImage: "gear")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 40)
            .padding(.top, 16)
        }
        .padding()
    }
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(NotificationStore())
        .environmentObject(SettingsManager.shared)
        .environmentObject(NotificationHistoryStore.shared)
}
