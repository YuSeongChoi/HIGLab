import PermissionKit
import AVFoundation
import SwiftUI

// 마이크 권한 요청 뷰
struct MicrophonePermissionView: View {
    @State private var permissionStatus: AVAudioSession.RecordPermission = .undetermined
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "mic.fill")
                .font(.system(size: 60))
                .foregroundStyle(statusColor)
            
            Text(statusTitle)
                .font(.title2.bold())
            
            Text(statusDescription)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            
            if permissionStatus == .undetermined {
                Button("마이크 권한 허용") {
                    requestMicrophonePermission()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .onAppear {
            checkPermissionStatus()
        }
    }
    
    private var statusColor: Color {
        switch permissionStatus {
        case .granted: return .green
        case .denied: return .red
        case .undetermined: return .blue
        @unknown default: return .gray
        }
    }
    
    private var statusTitle: String {
        switch permissionStatus {
        case .granted: return "마이크 사용 가능"
        case .denied: return "마이크 권한 거부됨"
        case .undetermined: return "마이크 접근 필요"
        @unknown default: return "알 수 없음"
        }
    }
    
    private var statusDescription: String {
        switch permissionStatus {
        case .granted: return "음성 녹음을 시작할 수 있습니다."
        case .denied: return "설정에서 마이크 권한을 허용해주세요."
        case .undetermined: return "음성 메모 녹음을 위해\n마이크 권한이 필요합니다."
        @unknown default: return ""
        }
    }
    
    private func checkPermissionStatus() {
        permissionStatus = AVAudioSession.sharedInstance().recordPermission
    }
    
    private func requestMicrophonePermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                permissionStatus = granted ? .granted : .denied
            }
        }
    }
}

// iOS 26 PermissionKit - HIG Lab
