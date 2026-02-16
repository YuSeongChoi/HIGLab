import SwiftUI
import MusicKit

// MARK: - Music Player App
// MusicKit 기반 Apple Music 연동 플레이어

@main
struct MusicPlayerApp: App {
    @StateObject private var musicService = MusicService.shared
    @StateObject private var playerManager = PlayerManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(musicService)
                .environmentObject(playerManager)
                .task {
                    // 앱 시작 시 권한 요청
                    await requestMusicAuthorization()
                }
        }
    }
    
    // MARK: - Authorization
    
    private func requestMusicAuthorization() async {
        let status = await musicService.requestAuthorization()
        
        switch status {
        case .authorized:
            print("✅ Apple Music 권한 승인됨")
        case .denied:
            print("❌ Apple Music 권한 거부됨")
        case .restricted:
            print("⚠️ Apple Music 권한 제한됨")
        case .notDetermined:
            print("❓ Apple Music 권한 미결정")
        @unknown default:
            break
        }
    }
}
