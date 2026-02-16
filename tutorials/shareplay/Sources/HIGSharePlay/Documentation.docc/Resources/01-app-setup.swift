import SwiftUI
import GroupActivities
import AVFoundation
import Combine

// ============================================
// SharePlay 지원 앱 기본 설정
// ============================================

@main
struct WatchTogetherApp: App {
    @StateObject private var sharePlayManager = SharePlayManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sharePlayManager)
                .task {
                    // 앱 시작 시 SharePlay 세션 관찰 시작
                    await sharePlayManager.startObservingSessions()
                }
        }
    }
}

// 중앙 SharePlay 관리자
@MainActor
class SharePlayManager: ObservableObject {
    @Published var isSharePlayActive = false
    @Published var currentMovie: Movie?
    @Published var participants: [Participant] = []
    
    private var groupSession: GroupSession<WatchTogetherActivity>?
    private var subscriptions = Set<AnyCancellable>()
    
    func startObservingSessions() async {
        // WatchTogetherActivity 세션을 비동기로 관찰
        for await session in WatchTogetherActivity.sessions() {
            // 새 세션 수신
            configureSession(session)
        }
    }
    
    private func configureSession(_ session: GroupSession<WatchTogetherActivity>) {
        self.groupSession = session
        self.currentMovie = session.activity.movie
        
        // 세션 상태 관찰
        session.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.isSharePlayActive = (state == .joined)
            }
            .store(in: &subscriptions)
        
        // 참가자 관찰
        session.$activeParticipants
            .receive(on: DispatchQueue.main)
            .sink { [weak self] participants in
                self?.participants = Array(participants)
            }
            .store(in: &subscriptions)
        
        session.join()
    }
}
