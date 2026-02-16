import GroupActivities
import SwiftUI

// ============================================
// 세션 수신 후 자동 네비게이션
// ============================================

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack {
            MovieListView()
                // SharePlay 세션 수신 시 자동 네비게이션
                .navigationDestination(isPresented: $appState.shouldNavigateToPlayer) {
                    if let movie = appState.currentMovie,
                       let session = appState.currentSession {
                        PlayerView(movie: movie, session: session)
                    }
                }
        }
    }
}

struct PlayerView: View {
    let movie: Movie
    let session: GroupSession<WatchTogetherActivity>
    
    @StateObject private var playerManager = PlayerManager()
    
    var body: some View {
        VideoPlayerView(player: playerManager.player)
            .onAppear {
                // 세션 설정 및 참여
                playerManager.configureSession(session, movie: movie)
            }
            .onDisappear {
                // 정리
                playerManager.cleanup()
            }
    }
}

class PlayerManager: ObservableObject {
    let player = AVPlayer()
    private var session: GroupSession<WatchTogetherActivity>?
    
    func configureSession(_ session: GroupSession<WatchTogetherActivity>, movie: Movie) {
        self.session = session
        
        // 영상 로드
        let item = AVPlayerItem(url: movie.videoURL)
        player.replaceCurrentItem(with: item)
        
        // AVPlayer와 세션 연결 (재생 동기화)
        player.playbackCoordinator.coordinateWithSession(session)
        
        // 세션 참여
        session.join()
    }
    
    func cleanup() {
        player.pause()
        session?.leave()
    }
}

import AVFoundation

struct VideoPlayerView: UIViewControllerRepresentable {
    let player: AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
    }
}

import AVKit
