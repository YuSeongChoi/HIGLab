import AVFoundation
import SwiftUI

@MainActor
class CameraManager: ObservableObject {
    let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    private var currentVideoDevice: AVCaptureDevice?
    private var videoDeviceInput: AVCaptureDeviceInput?
    
    @Published var isSessionRunning = false
    
    // MARK: - Device Discovery
    
    /// 사용 가능한 카메라 장치 검색
    func discoverCameraDevices() -> [AVCaptureDevice] {
        // DiscoverySession으로 원하는 조건의 장치 검색
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [
                .builtInDualCamera,      // 듀얼 카메라
                .builtInDualWideCamera,  // 듀얼 와이드 카메라
                .builtInWideAngleCamera, // 와이드 앵글 카메라
                .builtInUltraWideCamera  // 울트라 와이드 카메라
            ],
            mediaType: .video,
            position: .unspecified  // 전면/후면 모두 검색
        )
        
        return discoverySession.devices
    }
}
