import AVFoundation

extension CameraManager {
    
    // MARK: - Focus & Exposure
    
    /// 특정 지점에 초점과 노출 맞추기
    /// - Parameter point: 정규화된 좌표 (0~1)
    func focusAndExpose(at point: CGPoint) {
        guard let device = currentVideoDevice else { return }
        
        do {
            // 장치 잠금
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }
            
            // 초점 설정
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = point
                device.focusMode = .autoFocus
            }
            
            // 노출 설정
            if device.isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = point
                device.exposureMode = .autoExpose
            }
            
            // 설정 완료 후 다시 연속 모드로 전환
            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
            }
            if device.isExposureModeSupported(.continuousAutoExposure) {
                device.exposureMode = .continuousAutoExposure
            }
            
        } catch {
            print("초점/노출 설정 실패: \(error)")
        }
    }
    
    /// 탭 위치에 초점 표시 애니메이션을 위한 좌표 반환
    func handleTapToFocus(at devicePoint: CGPoint) {
        focusAndExpose(at: devicePoint)
        
        // 햅틱 피드백
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}
