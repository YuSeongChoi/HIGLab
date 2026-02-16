import AVFoundation
import UIKit
import Combine

@MainActor
class CameraManager: ObservableObject {
    let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Orientation Observer
    
    func setupOrientationObserver() {
        // 기기 방향 변경 감지 활성화
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        
        // 방향 변경 노티피케이션 구독
        NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .sink { [weak self] _ in
                self?.handleOrientationChange()
            }
            .store(in: &cancellables)
    }
    
    private func handleOrientationChange() {
        let orientation = UIDevice.current.orientation
        
        // 유효한 방향인지 확인 (faceUp, faceDown 제외)
        guard orientation.isPortrait || orientation.isLandscape else { return }
        
        // 프리뷰 레이어 회전 적용
        updatePreviewLayerRotation(for: orientation)
    }
    
    deinit {
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }
}
