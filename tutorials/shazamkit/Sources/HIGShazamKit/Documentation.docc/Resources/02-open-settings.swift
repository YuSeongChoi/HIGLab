import SwiftUI

struct SettingsLinkButton: View {
    var body: some View {
        Button {
            openAppSettings()
        } label: {
            Label("설정 앱에서 권한 허용", systemImage: "gear")
        }
    }
    
    private func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL)
        }
    }
}

// 권한 거부 상태에서 보여줄 뷰
struct PermissionDeniedView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "mic.slash")
                .font(.system(size: 50))
                .foregroundStyle(.red)
            
            Text("마이크 권한이 거부되었습니다")
                .font(.headline)
            
            Text("음악 인식을 위해 설정에서 마이크 권한을 허용해주세요.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            
            SettingsLinkButton()
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
