#if canImport(PermissionKit)
import PermissionKit
import AVFoundation
import SwiftUI

// 카메라 + 마이크 동시 권한 관리
@Observable
final class MediaPermissionManager {
    var cameraStatus: AVAuthorizationStatus = .notDetermined
    var microphoneStatus: AVAudioSession.RecordPermission = .undetermined
    
    var allPermissionsGranted: Bool {
        cameraStatus == .authorized && microphoneStatus == .granted
    }
    
    init() {
        refreshStatus()
    }
    
    func refreshStatus() {
        cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        microphoneStatus = AVAudioSession.sharedInstance().recordPermission
    }
    
    /// 모든 미디어 권한을 순차적으로 요청
    func requestAllPermissions() async {
        // 1. 카메라 권한 요청
        if cameraStatus == .notDetermined {
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            await MainActor.run {
                cameraStatus = granted ? .authorized : .denied
            }
        }
        
        // 2. 마이크 권한 요청
        if microphoneStatus == .undetermined {
            await withCheckedContinuation { continuation in
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    Task { @MainActor in
                        self.microphoneStatus = granted ? .granted : .denied
                        continuation.resume()
                    }
                }
            }
        }
    }
}

// 동영상 녹화 권한 요청 뷰
struct VideoRecordingPermissionView: View {
    @State private var manager = MediaPermissionManager()
    
    var body: some View {
        VStack(spacing: 24) {
            // 카메라 상태
            PermissionRow(
                icon: "camera.fill",
                title: "카메라",
                isGranted: manager.cameraStatus == .authorized
            )
            
            // 마이크 상태
            PermissionRow(
                icon: "mic.fill",
                title: "마이크",
                isGranted: manager.microphoneStatus == .granted
            )
            
            Divider()
            
            if manager.allPermissionsGranted {
                Label("동영상 녹화 가능", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            } else {
                Button("권한 허용하기") {
                    Task {
                        await manager.requestAllPermissions()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}

struct PermissionRow: View {
    let icon: String
    let title: String
    let isGranted: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .frame(width: 40)
            
            Text(title)
                .font(.headline)
            
            Spacer()
            
            Image(systemName: isGranted ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(isGranted ? .green : .red)
        }
    }
}

// iOS 26 PermissionKit - HIG Lab
#endif
