import AVFoundation
import ShazamKit

@available(iOS 17.0, *)
extension MusicRecognizer {
    /// 마이크 권한 상태를 확인하고 필요시 요청합니다
    func checkMicrophonePermission() async -> Bool {
        // iOS 17+에서는 AVAudioApplication 사용
        let status = AVAudioApplication.shared.recordPermission
        
        switch status {
        case .granted:
            return true
            
        case .denied:
            // 설정 앱으로 안내 필요
            return false
            
        case .undetermined:
            // 권한 요청
            return await AVAudioApplication.requestRecordPermission()
            
        @unknown default:
            return false
        }
    }
}
