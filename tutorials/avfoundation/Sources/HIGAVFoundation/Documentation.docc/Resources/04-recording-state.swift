import AVFoundation
import SwiftUI
import Combine

@MainActor
class CameraManager: NSObject, ObservableObject {
    let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    let movieOutput = AVCaptureMovieFileOutput()
    
    // MARK: - Recording State
    
    @Published var isRecording = false
    @Published var recordingDuration: TimeInterval = 0
    @Published var currentVideoURL: URL?
    
    // 녹화 상태 변경 시 햅틱 피드백
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    func toggleRecording() {
        feedbackGenerator.prepare()
        
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
        
        feedbackGenerator.impactOccurred()
    }
    
    func startRecording() {
        guard !isRecording else { return }
        recordingDuration = 0
        
        sessionQueue.async { [self] in
            let outputURL = createTemporaryFileURL()
            movieOutput.startRecording(to: outputURL, recordingDelegate: self)
        }
    }
    
    func stopRecording() {
        guard isRecording else { return }
        
        sessionQueue.async { [self] in
            movieOutput.stopRecording()
        }
    }
    
    private func createTemporaryFileURL() -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "video_\(UUID().uuidString).mov"
        return tempDir.appendingPathComponent(fileName)
    }
}

extension CameraManager: AVCaptureFileOutputRecordingDelegate {
    nonisolated func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {}
    nonisolated func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {}
}
