import AVFoundation
import SwiftUI

@MainActor
class CameraManager: NSObject, ObservableObject {
    let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    let movieOutput = AVCaptureMovieFileOutput()
    
    @Published var isRecording = false
    
    // MARK: - Recording Controls
    
    func startRecording() {
        guard !isRecording else { return }
        
        sessionQueue.async { [self] in
            let outputURL = createTemporaryFileURL()
            movieOutput.startRecording(to: outputURL, recordingDelegate: self)
        }
    }
    
    func stopRecording() {
        guard isRecording else { return }
        
        sessionQueue.async { [self] in
            // stopRecording 호출 시 델리게이트의 didFinishRecording이 호출됨
            movieOutput.stopRecording()
        }
    }
    
    /// 녹화 토글 (시작/중지)
    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func createTemporaryFileURL() -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "video_\(Date().timeIntervalSince1970).mov"
        return tempDir.appendingPathComponent(fileName)
    }
}

extension CameraManager: AVCaptureFileOutputRecordingDelegate {
    nonisolated func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {}
    nonisolated func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {}
}
