import SwiftUI
import CoreLocation

/// 앱의 메인 뷰
struct ContentView: View {
    @State private var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    var body: some View {
        VStack(spacing: 24) {
            // 앱 타이틀
            Text("🏃 러닝 트래커")
                .font(.largeTitle)
                .bold()
            
            // 권한 상태 표시
            statusView
            
            // 권한 요청 버튼
            if authorizationStatus == .notDetermined {
                Button("위치 권한 허용하기") {
                    requestLocationPermission()
                }
                .buttonStyle(.borderedProminent)
            }
            
            // 설정 이동 버튼 (권한 거부 시)
            if authorizationStatus == .denied {
                Button("설정에서 권한 변경하기") {
                    openSettings()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .onAppear {
            checkAuthorizationStatus()
        }
    }
    
    @ViewBuilder
    private var statusView: some View {
        switch authorizationStatus {
        case .notDetermined:
            Label("권한 미요청", systemImage: "questionmark.circle")
                .foregroundStyle(.secondary)
        case .denied, .restricted:
            Label("권한 거부됨", systemImage: "xmark.circle")
                .foregroundStyle(.red)
        case .authorizedWhenInUse:
            Label("앱 사용 중 허용", systemImage: "checkmark.circle")
                .foregroundStyle(.orange)
        case .authorizedAlways:
            Label("항상 허용", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
        @unknown default:
            Label("알 수 없음", systemImage: "exclamationmark.circle")
        }
    }
    
    private func checkAuthorizationStatus() {
        authorizationStatus = CLLocationManager().authorizationStatus
    }
    
    private func requestLocationPermission() {
        // 다음 챕터에서 구현
    }
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    ContentView()
}
