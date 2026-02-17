import SwiftUI
import MusicKit

// MARK: - Content View
// 메인 탭 뷰 (검색, 라이브러리, Now Playing)

struct ContentView: View {
    @EnvironmentObject var musicService: MusicService
    @EnvironmentObject var playerManager: PlayerManager
    
    @State private var selectedTab: Tab = .search
    
    enum Tab {
        case search
        case library
        case nowPlaying
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                // 검색 탭
                SearchView()
                    .tabItem {
                        Label("검색", systemImage: "magnifyingglass")
                    }
                    .tag(Tab.search)
                
                // 라이브러리 탭
                LibraryView()
                    .tabItem {
                        Label("보관함", systemImage: "music.note.list")
                    }
                    .tag(Tab.library)
                
                // Now Playing 탭
                NowPlayingView()
                    .tabItem {
                        Label("지금 재생 중", systemImage: "play.circle.fill")
                    }
                    .tag(Tab.nowPlaying)
            }
            
            // 미니 플레이어 (재생 중인 곡이 있고, Now Playing 탭이 아닐 때)
            if playerManager.currentSong != nil && selectedTab != .nowPlaying {
                MiniPlayerView {
                    selectedTab = .nowPlaying
                }
                .padding(.bottom, 49) // 탭바 높이만큼 오프셋
            }
        }
        // 권한 없을 때 안내
        .overlay {
            if musicService.authorizationStatus == .denied {
                AuthorizationDeniedView()
            }
        }
    }
}

// MARK: - Authorization Denied View
// 권한 거부 시 안내 뷰

struct AuthorizationDeniedView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.shield")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("Apple Music 권한 필요")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("설정에서 Apple Music 접근을\n허용해주세요.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button("설정 열기") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
    }
}

#Preview {
    ContentView()
        .environmentObject(MusicService.shared)
        .environmentObject(PlayerManager.shared)
}
