import AVFoundation
import UIKit
import Combine

// MARK: - 카메라 매니저
// AVCaptureSession을 관리하고 카메라 기능을 제공합니다.
// HIG: 카메라 접근 권한을 명확히 요청하고, 사용자에게 왜 필요한지 설명합니다.

/// 카메라 위치 (전면/후면)
enum CameraPosition {
    case front
    case back
    
    var avPosition: AVCaptureDevice.Position {
        switch self {
        case .front: .front
        case .back: .back
        }
    }
}

/// 플래시 모드
enum FlashMode {
    case auto
    case on
    case off
    
    var symbol: String {
        switch self {
        case .auto: "bolt.badge.automatic"
        case .on: "bolt.fill"
        case .off: "bolt.slash.fill"
        }
    }
    
    var avFlashMode: AVCaptureDevice.FlashMode {
        switch self {
        case .auto: .auto
        case .on: .on
        case .off: .off
        }
    }
}

/// 카메라 세션 에러
enum CameraError: LocalizedError {
    case unauthorized
    case setupFailed
    case captureError(String)
    
    var errorDescription: String? {
        switch self {
        case .unauthorized:
            "카메라 접근 권한이 필요합니다"
        case .setupFailed:
            "카메라 설정에 실패했습니다"
        case .captureError(let message):
            "촬영 오류: \(message)"
        }
    }
}

/// 카메라 세션 관리자
@MainActor
class CameraManager: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    
    /// 카메라 세션 (프리뷰 레이어에서 사용)
    @Published private(set) var session = AVCaptureSession()
    
    /// 세션 실행 중 여부
    @Published private(set) var isRunning = false
    
    /// 카메라 권한 상태
    @Published private(set) var isAuthorized = false
    
    /// 현재 카메라 위치
    @Published var cameraPosition: CameraPosition = .back
    
    /// 현재 플래시 모드
    @Published var flashMode: FlashMode = .auto
    
    /// 촬영된 미디어 목록
    @Published var capturedMedia: [CapturedMedia] = []
    
    /// 에러 메시지
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    
    /// 현재 카메라 입력
    private var currentInput: AVCaptureDeviceInput?
    
    /// 사진 출력
    private let photoOutput = AVCapturePhotoOutput()
    
    /// 현재 사진 캡처 델리게이트
    private var photoCaptureDelegate: PhotoCaptureDelegate?
    
    // MARK: - Initialization
    
    override init() {
        super.init()
    }
    
    // MARK: - Public Methods
    
    /// 카메라 권한 확인 및 요청
    func checkAuthorization() async {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            isAuthorized = true
        case .notDetermined:
            // 권한 요청
            isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
        case .denied, .restricted:
            isAuthorized = false
        @unknown default:
            isAuthorized = false
        }
    }
    
    /// 카메라 세션 설정
    func setupSession() async {
        guard isAuthorized else {
            errorMessage = CameraError.unauthorized.localizedDescription
            return
        }
        
        session.beginConfiguration()
        session.sessionPreset = .photo
        
        // 카메라 입력 설정
        guard let camera = getCamera(for: cameraPosition),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            session.commitConfiguration()
            errorMessage = CameraError.setupFailed.localizedDescription
            return
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
            currentInput = input
        }
        
        // 사진 출력 설정
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            photoOutput.isHighResolutionCaptureEnabled = true
            photoOutput.maxPhotoQualityPrioritization = .quality
        }
        
        session.commitConfiguration()
    }
    
    /// 세션 시작 (백그라운드 스레드에서 실행)
    func startSession() {
        guard !session.isRunning else { return }
        
        Task.detached(priority: .userInitiated) { [weak self] in
            self?.session.startRunning()
            await MainActor.run {
                self?.isRunning = true
            }
        }
    }
    
    /// 세션 중지 (백그라운드 스레드에서 실행)
    func stopSession() {
        guard session.isRunning else { return }
        
        Task.detached(priority: .userInitiated) { [weak self] in
            self?.session.stopRunning()
            await MainActor.run {
                self?.isRunning = false
            }
        }
    }
    
    /// 카메라 전환 (전면 ↔ 후면)
    func switchCamera() {
        cameraPosition = (cameraPosition == .back) ? .front : .back
        
        session.beginConfiguration()
        
        // 기존 입력 제거
        if let currentInput = currentInput {
            session.removeInput(currentInput)
        }
        
        // 새 카메라 입력 추가
        guard let camera = getCamera(for: cameraPosition),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            session.commitConfiguration()
            return
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
            currentInput = input
        }
        
        session.commitConfiguration()
    }
    
    /// 플래시 모드 순환 (auto → on → off → auto)
    func cycleFlashMode() {
        switch flashMode {
        case .auto: flashMode = .on
        case .on: flashMode = .off
        case .off: flashMode = .auto
        }
    }
    
    /// 사진 촬영
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        
        // 플래시 설정 (후면 카메라에서만 지원)
        if cameraPosition == .back,
           let device = currentInput?.device,
           device.hasFlash {
            settings.flashMode = flashMode.avFlashMode
        }
        
        // 델리게이트 생성 및 캡처
        photoCaptureDelegate = PhotoCaptureDelegate { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success(let image):
                    let media = CapturedMedia(type: .photo, image: image)
                    self?.capturedMedia.insert(media, at: 0)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
        
        photoOutput.capturePhoto(with: settings, delegate: photoCaptureDelegate!)
    }
    
    // MARK: - Private Methods
    
    /// 지정된 위치의 카메라 디바이스 반환
    private func getCamera(for position: CameraPosition) -> AVCaptureDevice? {
        // 듀얼/트리플 카메라 우선 시도
        let deviceTypes: [AVCaptureDevice.DeviceType] = [
            .builtInTripleCamera,
            .builtInDualCamera,
            .builtInDualWideCamera,
            .builtInWideAngleCamera
        ]
        
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: deviceTypes,
            mediaType: .video,
            position: position.avPosition
        )
        
        return discoverySession.devices.first
    }
}
