import SwiftUI
import MusicKit

struct ContentView: View {
    @State private var authorizationStatus = MusicAuthorization.currentStatus
    
    var body: some View {
        Group {
            switch authorizationStatus {
            case .notDetermined:
                // 권한 요청 화면
                AuthorizationRequestView {
                    await requestAuthorization()
                }
                
            case .authorized:
                // 메인 음악 플레이어 화면
                MusicPlayerMainView()
                
            case .denied:
                // 권한 거부 안내 화면
                PermissionDeniedView()
                
            case .restricted:
                // 제한됨 안내 화면
                PermissionRestrictedView()
                
            @unknown default:
                Text("알 수 없는 상태")
            }
        }
    }
    
    private func requestAuthorization() async {
        let status = await MusicAuthorization.request()
        authorizationStatus = status
    }
}

// 플레이스홀더 뷰들
struct AuthorizationRequestView: View {
    let onRequest: () async -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "music.note")
                .font(.system(size: 80))
                .foregroundStyle(.pink)
            
            Text("Apple Music 접근")
                .font(.title)
                .bold()
            
            Text("음악을 검색하고 재생하려면\nApple Music 접근 권한이 필요합니다.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            
            Button("권한 허용하기") {
                Task { await onRequest() }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct MusicPlayerMainView: View {
    var body: some View {
        Text("🎵 음악 플레이어")
    }
}

struct PermissionDeniedView: View {
    var body: some View {
        Text("권한이 거부되었습니다. 설정에서 변경해주세요.")
    }
}

struct PermissionRestrictedView: View {
    var body: some View {
        Text("시스템에서 접근이 제한되어 있습니다.")
    }
}
