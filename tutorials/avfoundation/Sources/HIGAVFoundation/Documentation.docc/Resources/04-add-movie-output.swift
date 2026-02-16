import AVFoundation
import SwiftUI

@MainActor
class CameraManager: ObservableObject {
    let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    let photoOutput = AVCapturePhotoOutput()
    let movieOutput = AVCaptureMovieFileOutput()
    
    @Published var isRecording = false
    
    func configureSession() {
        sessionQueue.async { [self] in
            captureSession.beginConfiguration()
            defer { captureSession.commitConfiguration() }
            
            // 비디오 녹화를 위해 high 프리셋 사용
            captureSession.sessionPreset = .high
            
            // 비디오 입력 추가 (이전 단계에서 구현)
            // ...
            
            // Movie Output 추가
            if captureSession.canAddOutput(movieOutput) {
                captureSession.addOutput(movieOutput)
                
                // 비디오 연결 설정
                if let connection = movieOutput.connection(with: .video) {
                    // 비디오 안정화 활성화
                    if connection.isVideoStabilizationSupported {
                        connection.preferredVideoStabilizationMode = .auto
                    }
                }
            } else {
                print("Movie Output을 추가할 수 없습니다.")
            }
        }
    }
}
