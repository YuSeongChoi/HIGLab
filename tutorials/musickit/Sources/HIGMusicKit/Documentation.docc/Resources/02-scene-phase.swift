import SwiftUI
import MusicKit

// 앱 활성화 시 권한 상태 재확인
// 사용자가 설정에서 권한을 변경할 수 있으므로 필요합니다

struct ContentViewWithScenePhase: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var authStatus = MusicAuthorization.currentStatus
    
    var body: some View {
        Group {
            switch authStatus {
            case .authorized:
                MusicContentView()
            default:
                AuthorizationPromptView()
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                // 앱이 활성화될 때마다 권한 상태 확인
                refreshAuthorizationStatus()
            }
        }
    }
    
    private func refreshAuthorizationStatus() {
        let newStatus = MusicAuthorization.currentStatus
        
        // 상태가 변경되었을 때만 업데이트
        if newStatus != authStatus {
            authStatus = newStatus
            
            // 상태 변경에 따른 추가 처리
            if newStatus == .authorized {
                // 권한이 허용되면 데이터 로드
                loadMusicData()
            }
        }
    }
    
    private func loadMusicData() {
        // 음악 데이터 로딩
    }
}

struct MusicContentView: View {
    var body: some View {
        Text("음악 콘텐츠")
    }
}

struct AuthorizationPromptView: View {
    var body: some View {
        Text("권한 필요")
    }
}
