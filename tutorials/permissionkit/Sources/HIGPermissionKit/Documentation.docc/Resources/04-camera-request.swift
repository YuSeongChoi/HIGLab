#if canImport(PermissionKit)
import PermissionKit
import AVFoundation
import SwiftUI

// 카메라 권한 요청 뷰
struct CameraPermissionView: View {
    @State private var cameraAuthorized = false
    @State private var showDeniedAlert = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
            
            Text("카메라 접근 필요")
                .font(.title2.bold())
            
            Text("프로필 사진 촬영을 위해\n카메라 권한이 필요합니다.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            
            Button("카메라 권한 허용") {
                Task {
                    await requestCameraPermission()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .alert("카메라 권한 필요", isPresented: $showDeniedAlert) {
            Button("설정으로 이동") {
                openSettings()
            }
            Button("취소", role: .cancel) { }
        } message: {
            Text("설정에서 카메라 권한을 허용해주세요.")
        }
    }
    
    /// async/await 패턴으로 카메라 권한 요청
    private func requestCameraPermission() async {
        let granted = await AVCaptureDevice.requestAccess(for: .video)
        
        await MainActor.run {
            if granted {
                cameraAuthorized = true
            } else {
                showDeniedAlert = true
            }
        }
    }
    
    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

// iOS 26 PermissionKit - HIG Lab
#endif
