import AVFoundation
import SwiftUI

@MainActor
class CameraManager: NSObject, ObservableObject {
    let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    let movieOutput = AVCaptureMovieFileOutput()
    
    @Published var isRecording = false
    
    // MARK: - Start Recording
    
    func startRecording() {
        guard !isRecording else { return }
        
        sessionQueue.async { [self] in
            // 녹화 연결 확인
            guard let connection = movieOutput.connection(with: .video),
                  connection.isActive else {
                print("비디오 연결이 활성화되지 않았습니다.")
                return
            }
            
            // 임시 파일 URL 생성
            let outputURL = createTemporaryFileURL()
            
            // 녹화 시작
            movieOutput.startRecording(to: outputURL, recordingDelegate: self)
        }
    }
    
    /// 고유한 임시 파일 URL 생성
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
