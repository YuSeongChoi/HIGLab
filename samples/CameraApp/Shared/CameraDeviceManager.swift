import AVFoundation
import UIKit
import Combine

// MARK: - 카메라 디바이스 매니저
// AVCaptureDevice의 세부 설정(포커스, 노출, 화이트밸런스, 줌 등)을 관리합니다.
// HIG: 사용자가 세부 설정을 조정할 때 즉각적인 피드백을 제공합니다.

/// 카메라 디바이스 제어 매니저
@MainActor
final class CameraDeviceManager: ObservableObject {
    
    // MARK: - Published Properties
    
    /// 현재 줌 배율
    @Published private(set) var currentZoom: CGFloat = 1.0
    
    /// 현재 포커스 모드
    @Published private(set) var focusMode: FocusModeOption = .continuous
    
    /// 현재 노출 모드
    @Published private(set) var exposureMode: ExposureModeOption = .continuous
    
    /// 현재 화이트밸런스 모드
    @Published private(set) var whiteBalanceMode: WhiteBalanceModeOption = .continuous
    
    /// 노출 보정값 (-2.0 ~ 2.0 EV)
    @Published var exposureBias: Float = 0.0 {
        didSet {
            applyExposureBias()
        }
    }
    
    /// 현재 포커스 포인트 (탭 투 포커스)
    @Published private(set) var focusPoint: FocusPoint?
    
    /// 현재 디바이스의 기능 지원 여부
    @Published private(set) var capabilities = CameraCapabilities.none
    
    /// ISO 값 (수동 노출 시)
    @Published var isoValue: Float = 100 {
        didSet {
            applyManualExposure()
        }
    }
    
    /// 셔터 스피드 (수동 노출 시)
    @Published var shutterSpeed: CMTime = CMTime(value: 1, timescale: 100) {
        didSet {
            applyManualExposure()
        }
    }
    
    // MARK: - Private Properties
    
    /// 현재 제어 중인 카메라 디바이스
    private weak var currentDevice: AVCaptureDevice?
    
    /// 줌 설정
    private var zoomSettings = ZoomSettings()
    
    /// 핀치 제스처 시작 시 줌 배율
    private var pinchStartZoom: CGFloat = 1.0
    
    // MARK: - Public Methods
    
    /// 카메라 디바이스 설정
    /// - Parameter device: 제어할 AVCaptureDevice
    func configureDevice(_ device: AVCaptureDevice?) {
        currentDevice = device
        updateCapabilities()
        resetToDefaults()
    }
    
    /// 디바이스 기능 업데이트
    func updateCapabilities() {
        guard let device = currentDevice else {
            capabilities = .none
            return
        }
        
        capabilities = CameraCapabilities(
            hasFlash: device.hasFlash,
            hasTorch: device.hasTorch,
            supportsFocus: device.isFocusModeSupported(.autoFocus) || device.isFocusModeSupported(.continuousAutoFocus),
            supportsExposure: device.isExposureModeSupported(.autoExpose) || device.isExposureModeSupported(.continuousAutoExposure),
            supportsWhiteBalance: device.isWhiteBalanceModeSupported(.autoWhiteBalance),
            supportsZoom: device.maxAvailableVideoZoomFactor > 1.0,
            supportsHDR: true, // 대부분의 최신 기기 지원
            supportsDepth: device.activeDepthDataFormat != nil,
            supportsPortrait: device.deviceType == .builtInDualCamera || device.deviceType == .builtInTripleCamera,
            maxZoomFactor: device.maxAvailableVideoZoomFactor,
            minZoomFactor: device.minAvailableVideoZoomFactor
        )
        
        // 줌 설정 업데이트
        zoomSettings.minZoom = capabilities.minZoomFactor
        zoomSettings.maxZoom = min(capabilities.maxZoomFactor, 10.0) // 최대 10배로 제한
        zoomSettings.availablePresets = calculateZoomPresets(for: device)
    }
    
    /// 기본값으로 리셋
    func resetToDefaults() {
        guard let device = currentDevice else { return }
        
        do {
            try device.lockForConfiguration()
            
            // 연속 자동 포커스로 설정
            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
                focusMode = .continuous
            }
            
            // 연속 자동 노출로 설정
            if device.isExposureModeSupported(.continuousAutoExposure) {
                device.exposureMode = .continuousAutoExposure
                exposureMode = .continuous
            }
            
            // 연속 자동 화이트밸런스로 설정
            if device.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
                device.whiteBalanceMode = .continuousAutoWhiteBalance
                whiteBalanceMode = .continuous
            }
            
            // 노출 보정 리셋
            device.setExposureTargetBias(0.0)
            exposureBias = 0.0
            
            // 줌 리셋
            device.videoZoomFactor = 1.0
            currentZoom = 1.0
            
            device.unlockForConfiguration()
        } catch {
            print("⚠️ 디바이스 설정 리셋 실패: \(error.localizedDescription)")
        }
        
        focusPoint = nil
    }
    
    // MARK: - 포커스 제어
    
    /// 탭 투 포커스 - 특정 지점에 포커스
    /// - Parameters:
    ///   - point: 화면 좌표 (0.0 ~ 1.0 정규화)
    ///   - adjustExposure: 노출도 함께 조정할지 여부
    func focusAt(point: CGPoint, adjustExposure: Bool = true) {
        guard let device = currentDevice else { return }
        
        // 디바이스 좌표로 변환 (x, y 뒤집기 - 가로/세로 모드 대응)
        let devicePoint = CGPoint(x: point.y, y: 1.0 - point.x)
        
        do {
            try device.lockForConfiguration()
            
            // 포커스 설정
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = devicePoint
                
                if device.isFocusModeSupported(.autoFocus) {
                    device.focusMode = .autoFocus
                    focusMode = .auto
                }
            }
            
            // 노출 설정
            if adjustExposure && device.isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = devicePoint
                
                if device.isExposureModeSupported(.autoExpose) {
                    device.exposureMode = .autoExpose
                    exposureMode = .auto
                }
            }
            
            device.unlockForConfiguration()
            
            // 포커스 포인트 업데이트 (UI용)
            focusPoint = FocusPoint(x: point.x, y: point.y)
            
            // 햅틱 피드백
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
            // 포커스 완료 후 연속 모드로 복귀
            Task {
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2초 후
                await switchToContinuousFocus()
            }
            
        } catch {
            print("⚠️ 포커스 설정 실패: \(error.localizedDescription)")
        }
    }
    
    /// 연속 자동 포커스로 전환
    func switchToContinuousFocus() {
        guard let device = currentDevice else { return }
        
        do {
            try device.lockForConfiguration()
            
            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
                focusMode = .continuous
            }
            
            device.unlockForConfiguration()
            focusPoint = nil
            
        } catch {
            print("⚠️ 연속 포커스 전환 실패: \(error.localizedDescription)")
        }
    }
    
    /// 포커스 잠금 토글
    func toggleFocusLock() {
        guard let device = currentDevice else { return }
        
        do {
            try device.lockForConfiguration()
            
            if device.focusMode == .locked {
                // 잠금 해제 -> 연속 포커스
                if device.isFocusModeSupported(.continuousAutoFocus) {
                    device.focusMode = .continuousAutoFocus
                    focusMode = .continuous
                }
            } else {
                // 현재 상태에서 잠금
                if device.isFocusModeSupported(.locked) {
                    device.focusMode = .locked
                    focusMode = .locked
                }
            }
            
            device.unlockForConfiguration()
            
        } catch {
            print("⚠️ 포커스 잠금 토글 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 노출 제어
    
    /// 노출 보정 적용
    private func applyExposureBias() {
        guard let device = currentDevice else { return }
        
        // 유효 범위로 제한
        let minBias = device.minExposureTargetBias
        let maxBias = device.maxExposureTargetBias
        let clampedBias = max(minBias, min(maxBias, exposureBias))
        
        do {
            try device.lockForConfiguration()
            device.setExposureTargetBias(clampedBias)
            device.unlockForConfiguration()
        } catch {
            print("⚠️ 노출 보정 적용 실패: \(error.localizedDescription)")
        }
    }
    
    /// 수동 노출 적용 (ISO, 셔터 스피드)
    private func applyManualExposure() {
        guard let device = currentDevice,
              device.isExposureModeSupported(.custom) else { return }
        
        // 유효 범위로 제한
        let minISO = device.activeFormat.minISO
        let maxISO = device.activeFormat.maxISO
        let clampedISO = max(minISO, min(maxISO, isoValue))
        
        let minDuration = device.activeFormat.minExposureDuration
        let maxDuration = device.activeFormat.maxExposureDuration
        let clampedDuration = CMTimeClampToRange(shutterSpeed, range: CMTimeRange(start: minDuration, end: maxDuration))
        
        do {
            try device.lockForConfiguration()
            device.setExposureModeCustom(duration: clampedDuration, iso: clampedISO)
            exposureMode = .custom
            device.unlockForConfiguration()
        } catch {
            print("⚠️ 수동 노출 적용 실패: \(error.localizedDescription)")
        }
    }
    
    /// 노출 잠금 토글
    func toggleExposureLock() {
        guard let device = currentDevice else { return }
        
        do {
            try device.lockForConfiguration()
            
            if device.exposureMode == .locked {
                // 잠금 해제 -> 연속 노출
                if device.isExposureModeSupported(.continuousAutoExposure) {
                    device.exposureMode = .continuousAutoExposure
                    exposureMode = .continuous
                }
            } else {
                // 현재 상태에서 잠금
                if device.isExposureModeSupported(.locked) {
                    device.exposureMode = .locked
                    exposureMode = .locked
                }
            }
            
            device.unlockForConfiguration()
            
        } catch {
            print("⚠️ 노출 잠금 토글 실패: \(error.localizedDescription)")
        }
    }
    
    /// 노출 보정 범위 반환
    var exposureBiasRange: ClosedRange<Float> {
        guard let device = currentDevice else {
            return -2.0...2.0
        }
        return device.minExposureTargetBias...device.maxExposureTargetBias
    }
    
    /// ISO 범위 반환
    var isoRange: ClosedRange<Float> {
        guard let device = currentDevice else {
            return 50...1600
        }
        return device.activeFormat.minISO...device.activeFormat.maxISO
    }
    
    // MARK: - 화이트밸런스 제어
    
    /// 화이트밸런스 잠금 토글
    func toggleWhiteBalanceLock() {
        guard let device = currentDevice else { return }
        
        do {
            try device.lockForConfiguration()
            
            if device.whiteBalanceMode == .locked {
                if device.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
                    device.whiteBalanceMode = .continuousAutoWhiteBalance
                    whiteBalanceMode = .continuous
                }
            } else {
                if device.isWhiteBalanceModeSupported(.locked) {
                    device.whiteBalanceMode = .locked
                    whiteBalanceMode = .locked
                }
            }
            
            device.unlockForConfiguration()
            
        } catch {
            print("⚠️ 화이트밸런스 잠금 토글 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 줌 제어
    
    /// 줌 배율 설정
    /// - Parameter factor: 줌 배율 (1.0 = 기본)
    func setZoom(_ factor: CGFloat, animated: Bool = true) {
        guard let device = currentDevice else { return }
        
        let clampedFactor = max(zoomSettings.minZoom, min(zoomSettings.maxZoom, factor))
        
        do {
            try device.lockForConfiguration()
            
            if animated {
                device.ramp(toVideoZoomFactor: clampedFactor, withRate: 5.0)
            } else {
                device.videoZoomFactor = clampedFactor
            }
            
            currentZoom = clampedFactor
            device.unlockForConfiguration()
            
        } catch {
            print("⚠️ 줌 설정 실패: \(error.localizedDescription)")
        }
    }
    
    /// 핀치 제스처 시작
    func pinchBegan() {
        pinchStartZoom = currentZoom
    }
    
    /// 핀치 제스처 진행
    /// - Parameter scale: 핀치 스케일 (1.0 = 변화 없음)
    func pinchChanged(scale: CGFloat) {
        let newZoom = pinchStartZoom * scale
        setZoom(newZoom, animated: false)
    }
    
    /// 줌 프리셋 적용 (0.5x, 1x, 2x 등)
    /// - Parameter preset: 프리셋 배율
    func applyZoomPreset(_ preset: CGFloat) {
        setZoom(preset, animated: true)
        
        // 햅틱 피드백
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    /// 사용 가능한 줌 프리셋 목록
    var availableZoomPresets: [CGFloat] {
        zoomSettings.availablePresets
    }
    
    /// 최소/최대 줌 범위
    var zoomRange: ClosedRange<CGFloat> {
        zoomSettings.minZoom...zoomSettings.maxZoom
    }
    
    // MARK: - 플래시/토치 제어
    
    /// 토치 모드 설정 (비디오 촬영 시 조명)
    /// - Parameter mode: 토치 모드
    func setTorchMode(_ mode: AVCaptureDevice.TorchMode) {
        guard let device = currentDevice,
              device.hasTorch,
              device.isTorchModeSupported(mode) else { return }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = mode
            device.unlockForConfiguration()
        } catch {
            print("⚠️ 토치 모드 설정 실패: \(error.localizedDescription)")
        }
    }
    
    /// 토치 밝기 설정
    /// - Parameter level: 밝기 (0.0 ~ 1.0)
    func setTorchLevel(_ level: Float) {
        guard let device = currentDevice,
              device.hasTorch else { return }
        
        do {
            try device.lockForConfiguration()
            try device.setTorchModeOn(level: level)
            device.unlockForConfiguration()
        } catch {
            print("⚠️ 토치 밝기 설정 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 포맷 제어
    
    /// 최적의 포맷 선택
    /// - Parameters:
    ///   - resolution: 원하는 해상도
    ///   - frameRate: 원하는 프레임 레이트
    func selectOptimalFormat(for resolution: VideoResolution, frameRate: VideoFrameRate) {
        guard let device = currentDevice else { return }
        
        // 조건에 맞는 포맷 검색
        let targetFormat = device.formats.first { format in
            let dimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
            let hasTargetResolution = dimensions.height >= Int32(resolutionHeight(for: resolution))
            
            let frameRateRange = format.videoSupportedFrameRateRanges.first { range in
                range.maxFrameRate >= Double(frameRate.rawValue)
            }
            
            return hasTargetResolution && frameRateRange != nil
        }
        
        guard let format = targetFormat else {
            print("⚠️ 적합한 포맷을 찾을 수 없습니다")
            return
        }
        
        do {
            try device.lockForConfiguration()
            
            device.activeFormat = format
            
            // 프레임 레이트 설정
            device.activeVideoMinFrameDuration = CMTime(value: 1, timescale: CMTimeScale(frameRate.rawValue))
            device.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: CMTimeScale(frameRate.rawValue))
            
            device.unlockForConfiguration()
            
            // 기능 업데이트 (포맷에 따라 달라질 수 있음)
            updateCapabilities()
            
        } catch {
            print("⚠️ 포맷 설정 실패: \(error.localizedDescription)")
        }
    }
    
    /// 사용 가능한 포맷 목록
    func availableFormats() -> [AVCaptureDevice.Format] {
        currentDevice?.formats ?? []
    }
    
    // MARK: - Private Helpers
    
    /// 줌 프리셋 계산
    private func calculateZoomPresets(for device: AVCaptureDevice) -> [CGFloat] {
        var presets: [CGFloat] = []
        
        // 울트라 와이드 렌즈가 있으면 0.5x 추가
        if device.deviceType == .builtInTripleCamera || device.deviceType == .builtInDualWideCamera {
            presets.append(0.5)
        }
        
        // 기본 1x
        presets.append(1.0)
        
        // 2x (광학 줌 또는 디지털)
        if device.maxAvailableVideoZoomFactor >= 2.0 {
            presets.append(2.0)
        }
        
        // 3x (트리플 카메라)
        if device.deviceType == .builtInTripleCamera && device.maxAvailableVideoZoomFactor >= 3.0 {
            presets.append(3.0)
        }
        
        return presets
    }
    
    /// 해상도에 해당하는 높이값 반환
    private func resolutionHeight(for resolution: VideoResolution) -> Int {
        switch resolution {
        case .hd720p: 720
        case .hd1080p: 1080
        case .uhd4k: 2160
        }
    }
}

// MARK: - CMTime 헬퍼

private extension CMTime {
    /// 범위 내로 제한
    static func CMTimeClampToRange(_ time: CMTime, range: CMTimeRange) -> CMTime {
        if time < range.start {
            return range.start
        } else if time > range.end {
            return range.end
        }
        return time
    }
}
