import GroupActivities
import SwiftUI

// ============================================
// 세션 수신: 다른 참가자가 시작한 SharePlay 참여
// ============================================

@main
struct WatchTogetherApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .task {
                    // 앱 시작 시 세션 관찰 시작
                    await observeSessions()
                }
        }
    }
    
    // sessions() AsyncSequence로 새 세션 수신
    private func observeSessions() async {
        // WatchTogetherActivity 타입의 세션만 수신
        for await session in WatchTogetherActivity.sessions() {
            
            // 세션에서 Activity 정보 추출
            let activity = session.activity
            let movie = activity.movie
            
            print("🎬 SharePlay 세션 수신: \(movie.title)")
            
            // 앱 상태 업데이트 (메인 액터에서)
            await MainActor.run {
                appState.handleNewSession(session, movie: movie)
            }
        }
    }
}

// 앱 상태 관리
@MainActor
class AppState: ObservableObject {
    @Published var currentSession: GroupSession<WatchTogetherActivity>?
    @Published var currentMovie: Movie?
    @Published var shouldNavigateToPlayer = false
    
    func handleNewSession(_ session: GroupSession<WatchTogetherActivity>, movie: Movie) {
        self.currentSession = session
        self.currentMovie = movie
        
        // 플레이어 화면으로 네비게이션
        self.shouldNavigateToPlayer = true
    }
}
