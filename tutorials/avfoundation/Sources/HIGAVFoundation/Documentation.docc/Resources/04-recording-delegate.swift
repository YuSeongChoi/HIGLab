import AVFoundation
import SwiftUI

@MainActor
class CameraManager: NSObject, ObservableObject {
    let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    let movieOutput = AVCaptureMovieFileOutput()
    
    @Published var isRecording = false
}

// MARK: - AVCaptureFileOutputRecordingDelegate

extension CameraManager: AVCaptureFileOutputRecordingDelegate {
    
    /// 녹화 시작됨
    nonisolated func fileOutput(_ output: AVCaptureFileOutput, 
                     didStartRecordingTo fileURL: URL, 
                     from connections: [AVCaptureConnection]) {
        print("🎬 녹화 시작: \(fileURL.lastPathComponent)")
        
        Task { @MainActor in
            isRecording = true
        }
    }
    
    /// 녹화 완료됨
    nonisolated func fileOutput(_ output: AVCaptureFileOutput, 
                     didFinishRecordingTo outputFileURL: URL, 
                     from connections: [AVCaptureConnection], 
                     error: Error?) {
        if let error = error {
            print("❌ 녹화 실패: \(error.localizedDescription)")
        } else {
            print("✅ 녹화 완료: \(outputFileURL.lastPathComponent)")
            // 사진 라이브러리에 저장 (다음 단계에서 구현)
        }
        
        Task { @MainActor in
            isRecording = false
        }
    }
}
