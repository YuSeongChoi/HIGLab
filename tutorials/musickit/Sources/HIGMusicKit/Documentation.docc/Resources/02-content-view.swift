import SwiftUI
import MusicKit

struct ContentView: View {
    @State private var status = MusicAuthorization.currentStatus
    
    var body: some View {
        Group {
            switch status {
            case .notDetermined:
                AuthorizationView {
                    status = await MusicAuthorization.request()
                }
                
            case .authorized:
                MainMusicView()
                
            case .denied:
                DeniedView()
                
            case .restricted:
                RestrictedView()
                
            @unknown default:
                Text("알 수 없는 상태")
            }
        }
        .onReceive(NotificationCenter.default.publisher(
            for: UIApplication.didBecomeActiveNotification
        )) { _ in
            // 앱이 활성화될 때 상태 재확인
            status = MusicAuthorization.currentStatus
        }
    }
}

struct MainMusicView: View {
    var body: some View {
        NavigationStack {
            Text("🎵 음악 플레이어")
                .navigationTitle("Music")
        }
    }
}
