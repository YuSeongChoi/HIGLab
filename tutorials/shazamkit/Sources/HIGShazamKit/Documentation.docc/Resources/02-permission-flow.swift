import SwiftUI
import AVFoundation

struct PermissionView: View {
    @Binding var permissionGranted: Bool
    @State private var showSettings = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "mic.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
            
            Text("마이크 접근 필요")
                .font(.title2.bold())
            
            Text("주변에서 재생되는 음악을 인식하려면\n마이크 접근 권한이 필요합니다.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            
            Button("권한 허용") {
                Task {
                    permissionGranted = await AVAudioApplication.requestRecordPermission()
                    if !permissionGranted {
                        showSettings = true
                    }
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .alert("설정에서 권한 허용", isPresented: $showSettings) {
            Button("설정 열기") { openSettings() }
            Button("취소", role: .cancel) { }
        }
    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
