import AVFoundation
import SwiftUI

@MainActor
class CameraManager: ObservableObject {
    let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    /// 프리뷰 레이어 (읽기 전용)
    private(set) var previewLayer: AVCaptureVideoPreviewLayer?
    
    @Published var isSessionRunning = false
    
    // MARK: - Setup Preview Layer
    
    func setupPreviewLayer() -> AVCaptureVideoPreviewLayer {
        let layer = AVCaptureVideoPreviewLayer(session: captureSession)
        layer.videoGravity = .resizeAspectFill
        
        // 비디오 연결 설정
        if let connection = layer.connection {
            // 초기 방향 설정 (iOS 17+)
            if connection.isVideoRotationAngleSupported(0) {
                connection.videoRotationAngle = 90 // 세로 모드
            }
        }
        
        self.previewLayer = layer
        return layer
    }
}
