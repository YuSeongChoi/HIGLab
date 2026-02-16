import AVFoundation
import SwiftUI
import Combine

@MainActor
class CameraManager: NSObject, ObservableObject {
    let captureSession = AVCaptureSession()
    let movieOutput = AVCaptureMovieFileOutput()
    
    @Published var isRecording = false
    @Published var recordingDuration: TimeInterval = 0
    
    private var recordingTimer: Timer?
    private var recordingStartTime: Date?
    
    // MARK: - Recording Timer
    
    private func startRecordingTimer() {
        recordingStartTime = Date()
        recordingDuration = 0
        
        // 0.1초마다 업데이트
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self,
                      let startTime = self.recordingStartTime else { return }
                self.recordingDuration = Date().timeIntervalSince(startTime)
            }
        }
    }
    
    private func stopRecordingTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
        recordingStartTime = nil
    }
    
    /// 녹화 시간을 포맷팅 (MM:SS)
    var formattedDuration: String {
        let minutes = Int(recordingDuration) / 60
        let seconds = Int(recordingDuration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    /// 녹화 시간을 포맷팅 (MM:SS.ms)
    var formattedDurationWithMillis: String {
        let minutes = Int(recordingDuration) / 60
        let seconds = Int(recordingDuration) % 60
        let millis = Int((recordingDuration.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%02d:%02d.%01d", minutes, seconds, millis)
    }
}

extension CameraManager: AVCaptureFileOutputRecordingDelegate {
    nonisolated func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        Task { @MainActor in
            startRecordingTimer()
        }
    }
    
    nonisolated func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        Task { @MainActor in
            stopRecordingTimer()
        }
    }
}
