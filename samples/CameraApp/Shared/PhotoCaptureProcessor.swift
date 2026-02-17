import AVFoundation
import UIKit
import Photos

// MARK: - 사진 캡처 프로세서
// AVCapturePhotoCaptureDelegate를 구현하여 다양한 사진 촬영 옵션을 처리합니다.
// HIG: 촬영 과정의 각 단계에서 적절한 피드백을 제공합니다.

/// 사진 캡처 설정
struct PhotoCaptureConfiguration {
    /// 플래시 모드
    var flashMode: FlashMode = .auto
    
    /// HDR 모드
    var hdrMode: HDRMode = .auto
    
    /// 고해상도 캡처
    var isHighResolutionEnabled: Bool = true
    
    /// 품질 우선순위
    var qualityPrioritization: PhotoQuality = .balanced
    
    /// 사진 저장 (포토 라이브러리)
    var saveToPhotoLibrary: Bool = true
    
    /// Raw 포맷 캡처
    var isRawCaptureEnabled: Bool = false
    
    /// 라이브 포토
    var isLivePhotoEnabled: Bool = false
    
    /// 인물 사진 효과 (심도)
    var isPortraitEffectsEnabled: Bool = false
    
    /// 뒤집기 (전면 카메라 미러링)
    var isMirroringEnabled: Bool = true
}

/// 사진 캡처 결과
struct PhotoCaptureOutput {
    let image: UIImage
    let metadata: [String: Any]?
    let fileURL: URL?
    let capturedAt: Date
    
    /// 촬영 설정
    let settings: PhotoCaptureConfiguration
}

// MARK: - 사진 캡처 프로세서

/// 사진 캡처 처리 담당
final class PhotoCaptureProcessor: NSObject {
    
    // MARK: - Callbacks
    
    /// 캡처 시작 콜백 (셔터 사운드 타이밍)
    var willCapturePhotoHandler: (() -> Void)?
    
    /// 캡처 진행 콜백 (프로세싱 중)
    var didCapturePhotoHandler: (() -> Void)?
    
    /// 캡처 완료 콜백
    var completionHandler: ((Result<PhotoCaptureOutput, CameraError>) -> Void)?
    
    /// 라이브 포토 캡처 완료 콜백
    var livePhotoCompletionHandler: ((URL?) -> Void)?
    
    // MARK: - Properties
    
    /// 캡처 설정
    private let configuration: PhotoCaptureConfiguration
    
    /// 고유 설정 ID (AVCapturePhotoSettings.uniqueID와 매칭)
    private let requestedPhotoSettingsID: Int64
    
    /// 현재 카메라 위치 (미러링 판단용)
    private let cameraPosition: CameraPosition
    
    /// 캡처된 이미지 데이터
    private var photoData: Data?
    
    /// 라이브 포토 파일 URL
    private var livePhotoMovieURL: URL?
    
    /// 캡처 시작 시간
    private let captureStartTime = Date()
    
    // MARK: - Initialization
    
    init(
        configuration: PhotoCaptureConfiguration,
        requestedPhotoSettingsID: Int64,
        cameraPosition: CameraPosition
    ) {
        self.configuration = configuration
        self.requestedPhotoSettingsID = requestedPhotoSettingsID
        self.cameraPosition = cameraPosition
        super.init()
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension PhotoCaptureProcessor: AVCapturePhotoCaptureDelegate {
    
    /// 캡처 시작 직전 (셔터 사운드 타이밍)
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings
    ) {
        // UI 업데이트 (예: 화면 깜빡임)
        DispatchQueue.main.async { [weak self] in
            self?.willCapturePhotoHandler?()
        }
    }
    
    /// 캡처 중 (노출 완료)
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings
    ) {
        // 프로세싱 시작 알림
        DispatchQueue.main.async { [weak self] in
            self?.didCapturePhotoHandler?()
        }
    }
    
    /// 사진 처리 완료
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        // 오류 처리
        if let error = error {
            handleError(.captureError(error.localizedDescription))
            return
        }
        
        // 이미지 데이터 추출
        guard let imageData = photo.fileDataRepresentation() else {
            handleError(.captureError("이미지 데이터를 추출할 수 없습니다"))
            return
        }
        
        photoData = imageData
        
        // 메타데이터 추출
        let metadata = photo.metadata
        
        print("📸 사진 캡처 완료 - 크기: \(imageData.count) bytes")
        print("   메타데이터: \(metadata.keys)")
    }
    
    /// 라이브 포토 무비 캡처 완료
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishRecordingLivePhotoMovieForEventualFileAt outputFileURL: URL,
        resolvedSettings: AVCaptureResolvedPhotoSettings
    ) {
        print("📹 라이브 포토 녹화 완료")
    }
    
    /// 라이브 포토 처리 완료
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingLivePhotoToMovieFileAt outputFileURL: URL,
        duration: CMTime,
        photoDisplayTime: CMTime,
        resolvedSettings: AVCaptureResolvedPhotoSettings,
        error: Error?
    ) {
        if let error = error {
            print("⚠️ 라이브 포토 처리 오류: \(error.localizedDescription)")
            return
        }
        
        livePhotoMovieURL = outputFileURL
        
        DispatchQueue.main.async { [weak self] in
            self?.livePhotoCompletionHandler?(outputFileURL)
        }
    }
    
    /// 전체 캡처 과정 완료
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings,
        error: Error?
    ) {
        // 최종 오류 확인
        if let error = error {
            handleError(.captureError(error.localizedDescription))
            return
        }
        
        // 이미지 처리
        guard let photoData = photoData,
              var image = UIImage(data: photoData) else {
            handleError(.captureError("이미지를 생성할 수 없습니다"))
            return
        }
        
        // 이미지 방향 보정
        image = fixImageOrientation(image)
        
        // 전면 카메라 미러링 처리
        if cameraPosition == .front && configuration.isMirroringEnabled {
            image = mirrorImage(image)
        }
        
        // 파일 저장
        var savedURL: URL?
        if configuration.saveToPhotoLibrary {
            savedURL = saveToPhotoLibrary(image: image)
        }
        
        // 결과 생성
        let output = PhotoCaptureOutput(
            image: image,
            metadata: nil,
            fileURL: savedURL,
            capturedAt: captureStartTime,
            settings: configuration
        )
        
        // 완료 콜백
        DispatchQueue.main.async { [weak self] in
            self?.completionHandler?(.success(output))
        }
    }
    
    // MARK: - Private Methods
    
    /// 오류 처리
    private func handleError(_ error: CameraError) {
        DispatchQueue.main.async { [weak self] in
            self?.completionHandler?(.failure(error))
        }
    }
    
    /// 이미지 방향 보정
    private func fixImageOrientation(_ image: UIImage) -> UIImage {
        guard image.imageOrientation != .up else { return image }
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        defer { UIGraphicsEndImageContext() }
        
        image.draw(in: CGRect(origin: .zero, size: image.size))
        return UIGraphicsGetImageFromCurrentImageContext() ?? image
    }
    
    /// 이미지 좌우 반전 (전면 카메라용)
    private func mirrorImage(_ image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        return UIImage(
            cgImage: cgImage,
            scale: image.scale,
            orientation: .upMirrored
        )
    }
    
    /// 포토 라이브러리에 저장
    private func saveToPhotoLibrary(image: UIImage) -> URL? {
        var savedURL: URL?
        
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized else {
                print("⚠️ 사진 저장 권한 없음")
                return
            }
            
            PHPhotoLibrary.shared().performChanges {
                let request = PHAssetCreationRequest.forAsset()
                if let imageData = image.jpegData(compressionQuality: 1.0) {
                    request.addResource(with: .photo, data: imageData, options: nil)
                }
            } completionHandler: { success, error in
                if success {
                    print("✅ 사진이 라이브러리에 저장됨")
                } else if let error = error {
                    print("⚠️ 사진 저장 실패: \(error.localizedDescription)")
                }
            }
        }
        
        return savedURL
    }
}

// MARK: - 연속 촬영 (Burst Mode) 프로세서

/// 연속 촬영 처리 담당
final class BurstCaptureProcessor {
    
    // MARK: - Properties
    
    /// 연속 촬영 설정
    private var settings: BurstSettings
    
    /// 캡처된 이미지들
    private var capturedImages: [UIImage] = []
    
    /// 촬영 중 여부
    private(set) var isCapturing = false
    
    /// 현재 촬영 수
    var captureCount: Int { capturedImages.count }
    
    /// 촬영 완료 콜백
    var completionHandler: (([UIImage]) -> Void)?
    
    /// 진행 상황 콜백
    var progressHandler: ((Int, Int) -> Void)?
    
    /// 촬영 타이머
    private var captureTimer: Timer?
    
    /// 사진 출력
    private weak var photoOutput: AVCapturePhotoOutput?
    
    /// 현재 설정
    private var currentConfiguration: PhotoCaptureConfiguration
    
    // MARK: - Initialization
    
    init(
        settings: BurstSettings = BurstSettings(),
        configuration: PhotoCaptureConfiguration = PhotoCaptureConfiguration()
    ) {
        self.settings = settings
        self.currentConfiguration = configuration
    }
    
    // MARK: - Public Methods
    
    /// 연속 촬영 시작
    /// - Parameters:
    ///   - photoOutput: AVCapturePhotoOutput
    ///   - configuration: 촬영 설정
    func startBurst(
        with photoOutput: AVCapturePhotoOutput,
        configuration: PhotoCaptureConfiguration
    ) {
        guard !isCapturing else { return }
        
        self.photoOutput = photoOutput
        self.currentConfiguration = configuration
        isCapturing = true
        capturedImages.removeAll()
        
        // 첫 촬영
        captureNextPhoto()
        
        // 타이머 시작
        captureTimer = Timer.scheduledTimer(
            withTimeInterval: settings.interval,
            repeats: true
        ) { [weak self] _ in
            self?.captureNextPhoto()
        }
        
        print("🔄 연속 촬영 시작 (최대 \(settings.maxCount)장)")
    }
    
    /// 연속 촬영 중지
    func stopBurst() {
        captureTimer?.invalidate()
        captureTimer = nil
        isCapturing = false
        
        print("🔄 연속 촬영 종료 - \(capturedImages.count)장 촬영됨")
        
        completionHandler?(capturedImages)
    }
    
    /// 촬영된 이미지 추가
    func addCapturedImage(_ image: UIImage) {
        capturedImages.append(image)
        progressHandler?(capturedImages.count, settings.maxCount)
        
        // 최대 촬영 수 도달
        if capturedImages.count >= settings.maxCount {
            stopBurst()
        }
    }
    
    // MARK: - Private Methods
    
    private func captureNextPhoto() {
        guard let photoOutput = photoOutput,
              capturedImages.count < settings.maxCount else {
            stopBurst()
            return
        }
        
        // 연속 촬영용 설정 (빠른 품질)
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .off  // 연속 촬영 시 플래시 비활성화
        
        // 캡처 (간단한 델리게이트 사용)
        let processor = SimpleBurstDelegate { [weak self] image in
            if let image = image {
                self?.addCapturedImage(image)
            }
        }
        
        photoOutput.capturePhoto(with: settings, delegate: processor)
    }
}

// MARK: - 간단한 연속 촬영 델리게이트

/// 연속 촬영용 간단한 델리게이트
private final class SimpleBurstDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    
    private let completion: (UIImage?) -> Void
    
    init(completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
        super.init()
    }
    
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        guard error == nil,
              let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            completion(nil)
            return
        }
        
        completion(image)
    }
}

// MARK: - 타이머 촬영 프로세서

/// 타이머 촬영 처리 담당
final class TimerCaptureProcessor {
    
    // MARK: - Properties
    
    /// 타이머 설정
    private var timerSetting: TimerSetting
    
    /// 남은 시간
    @Published private(set) var remainingSeconds: Int = 0
    
    /// 타이머 활성화 여부
    private(set) var isActive = false
    
    /// 카운트다운 타이머
    private var countdownTimer: Timer?
    
    /// 촬영 콜백
    var captureHandler: (() -> Void)?
    
    /// 카운트다운 콜백
    var countdownHandler: ((Int) -> Void)?
    
    /// 취소 콜백
    var cancelHandler: (() -> Void)?
    
    // MARK: - Initialization
    
    init(timerSetting: TimerSetting = .off) {
        self.timerSetting = timerSetting
    }
    
    // MARK: - Public Methods
    
    /// 타이머 설정 변경
    func setTimer(_ setting: TimerSetting) {
        timerSetting = setting
    }
    
    /// 타이머 촬영 시작
    func startTimer() {
        guard timerSetting != .off else {
            // 타이머 없으면 바로 촬영
            captureHandler?()
            return
        }
        
        isActive = true
        remainingSeconds = timerSetting.rawValue
        
        // 첫 카운트다운 알림
        countdownHandler?(remainingSeconds)
        
        // 카운트다운 시작
        countdownTimer = Timer.scheduledTimer(
            withTimeInterval: 1.0,
            repeats: true
        ) { [weak self] _ in
            self?.tick()
        }
        
        print("⏱️ 타이머 촬영 시작 (\(timerSetting.displayText))")
    }
    
    /// 타이머 취소
    func cancelTimer() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        isActive = false
        remainingSeconds = 0
        
        cancelHandler?()
        print("⏱️ 타이머 취소됨")
    }
    
    // MARK: - Private Methods
    
    private func tick() {
        remainingSeconds -= 1
        countdownHandler?(remainingSeconds)
        
        // 햅틱 피드백
        let generator = UIImpactFeedbackGenerator(style: remainingSeconds == 0 ? .heavy : .light)
        generator.impactOccurred()
        
        if remainingSeconds <= 0 {
            // 타이머 종료 - 촬영
            countdownTimer?.invalidate()
            countdownTimer = nil
            isActive = false
            
            captureHandler?()
            print("⏱️ 타이머 완료 - 촬영!")
        }
    }
}

// MARK: - 사진 설정 빌더

/// AVCapturePhotoSettings 생성 헬퍼
struct PhotoSettingsBuilder {
    
    /// 사진 설정 생성
    /// - Parameters:
    ///   - configuration: 캡처 설정
    ///   - photoOutput: AVCapturePhotoOutput
    ///   - device: 현재 카메라 디바이스
    /// - Returns: AVCapturePhotoSettings
    static func build(
        from configuration: PhotoCaptureConfiguration,
        photoOutput: AVCapturePhotoOutput,
        device: AVCaptureDevice?
    ) -> AVCapturePhotoSettings {
        
        var settings: AVCapturePhotoSettings
        
        // Raw 캡처 지원 여부 확인
        if configuration.isRawCaptureEnabled,
           let rawFormat = photoOutput.availableRawPhotoPixelFormatTypes.first {
            settings = AVCapturePhotoSettings(
                rawPixelFormatType: rawFormat,
                processedFormat: [AVVideoCodecKey: AVVideoCodecType.hevc]
            )
        } else {
            // HEVC 또는 JPEG
            if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
                settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
            } else {
                settings = AVCapturePhotoSettings()
            }
        }
        
        // 고해상도 캡처
        settings.isHighResolutionPhotoEnabled = configuration.isHighResolutionEnabled
        
        // 품질 우선순위
        settings.maxPhotoDimensions = photoOutput.maxPhotoDimensions
        settings.photoQualityPrioritization = configuration.qualityPrioritization.avQualityPrioritization
        
        // 플래시 설정 (후면 카메라에서만)
        if let device = device, device.hasFlash, device.position == .back {
            settings.flashMode = configuration.flashMode.avFlashMode
        }
        
        // 프리뷰 썸네일
        if let previewFormat = settings.availablePreviewPhotoPixelFormatTypes.first {
            settings.previewPhotoFormat = [
                kCVPixelBufferPixelFormatTypeKey as String: previewFormat
            ]
        }
        
        return settings
    }
}
