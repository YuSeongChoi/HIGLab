import AVFoundation
import UIKit
import Combine
import Photos

// MARK: - 카메라 매니저
// 카메라 앱의 핵심 로직을 총괄합니다.
// AVCaptureSession 관리, 사진/비디오 촬영, QR 스캔 등 모든 카메라 기능을 통합합니다.
// HIG: 카메라 접근 권한을 명확히 요청하고, 사용자에게 왜 필요한지 설명합니다.

/// 카메라 매니저 - 앱의 핵심 카메라 로직
@MainActor
final class CameraManager: NSObject, ObservableObject {
    
    // MARK: - Published Properties (상태)
    
    /// 카메라 세션
    @Published private(set) var session = AVCaptureSession()
    
    /// 세션 상태
    @Published private(set) var sessionState: SessionState = .idle
    
    /// 카메라 권한 상태
    @Published private(set) var isCameraAuthorized = false
    
    /// 마이크 권한 상태
    @Published private(set) var isMicrophoneAuthorized = false
    
    /// 현재 카메라 위치
    @Published var cameraPosition: CameraPosition = .back {
        didSet {
            if oldValue != cameraPosition {
                Task { await switchCamera() }
            }
        }
    }
    
    /// 현재 캡처 모드
    @Published var captureMode: CaptureMode = .photo {
        didSet {
            if oldValue != captureMode {
                Task { await configureCaptureMode() }
            }
        }
    }
    
    /// 플래시 모드
    @Published var flashMode: FlashMode = .auto
    
    /// 타이머 설정
    @Published var timerSetting: TimerSetting = .off
    
    /// HDR 모드
    @Published var hdrMode: HDRMode = .auto
    
    /// 촬영된 미디어 목록
    @Published private(set) var capturedMedia: [CapturedMedia] = []
    
    /// 에러 메시지
    @Published var errorMessage: String?
    
    /// 촬영 중 상태 (셔터 애니메이션용)
    @Published private(set) var isCapturing = false
    
    /// 타이머 카운트다운 (0이면 비활성)
    @Published private(set) var timerCountdown: Int = 0
    
    // MARK: - Sub Managers
    
    /// 카메라 디바이스 제어 (포커스, 노출, 줌 등)
    let deviceManager = CameraDeviceManager()
    
    /// 비디오 녹화 처리
    let videoProcessor = VideoRecordingProcessor()
    
    /// QR 코드 스캐너
    let qrScanner = QRCodeScanner()
    
    /// 타이머 촬영 처리
    private let timerProcessor = TimerCaptureProcessor()
    
    /// 연속 촬영 처리
    private let burstProcessor = BurstCaptureProcessor()
    
    // MARK: - Private Properties
    
    /// 현재 카메라 입력
    private var currentVideoInput: AVCaptureDeviceInput?
    
    /// 현재 마이크 입력
    private var currentAudioInput: AVCaptureDeviceInput?
    
    /// 사진 출력
    private let photoOutput = AVCapturePhotoOutput()
    
    /// 비디오 데이터 출력 (실시간 처리용)
    private let videoDataOutput = AVCaptureVideoDataOutput()
    
    /// 오디오 데이터 출력
    private let audioDataOutput = AVCaptureAudioDataOutput()
    
    /// 현재 사진 캡처 프로세서
    private var currentPhotoProcessor: PhotoCaptureProcessor?
    
    /// 세션 설정 큐
    private let sessionQueue = DispatchQueue(label: "com.cameraapp.session", qos: .userInitiated)
    
    /// 비디오 데이터 처리 큐
    private let videoDataQueue = DispatchQueue(label: "com.cameraapp.videodata", qos: .userInitiated)
    
    /// Combine 구독 저장
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    
    /// 세션 실행 중 여부
    var isRunning: Bool { sessionState.isActive }
    
    /// 녹화 중 여부
    var isRecording: Bool { videoProcessor.isRecording }
    
    /// 녹화 시간 (포맷된 문자열)
    var recordingDuration: String { videoProcessor.formattedDuration }
    
    /// 현재 줌 배율
    var currentZoom: CGFloat { deviceManager.currentZoom }
    
    /// 줌 범위
    var zoomRange: ClosedRange<CGFloat> { deviceManager.zoomRange }
    
    /// 줌 프리셋
    var zoomPresets: [CGFloat] { deviceManager.availableZoomPresets }
    
    /// 디바이스 기능
    var capabilities: CameraCapabilities { deviceManager.capabilities }
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        setupTimerProcessor()
        setupBurstProcessor()
    }
    
    // MARK: - 권한 관리
    
    /// 카메라 권한 확인 및 요청
    func checkAuthorization() async {
        // 카메라 권한
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraStatus {
        case .authorized:
            isCameraAuthorized = true
        case .notDetermined:
            isCameraAuthorized = await AVCaptureDevice.requestAccess(for: .video)
        case .denied, .restricted:
            isCameraAuthorized = false
        @unknown default:
            isCameraAuthorized = false
        }
        
        // 마이크 권한
        let micStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        
        switch micStatus {
        case .authorized:
            isMicrophoneAuthorized = true
        case .notDetermined:
            isMicrophoneAuthorized = await AVCaptureDevice.requestAccess(for: .audio)
        case .denied, .restricted:
            isMicrophoneAuthorized = false
        @unknown default:
            isMicrophoneAuthorized = false
        }
    }
    
    // MARK: - 세션 관리
    
    /// 카메라 세션 설정
    func setupSession() async {
        guard isCameraAuthorized else {
            errorMessage = CameraError.unauthorized.localizedDescription
            return
        }
        
        sessionState = .configuring
        
        session.beginConfiguration()
        
        // 세션 프리셋 설정
        if session.canSetSessionPreset(.photo) {
            session.sessionPreset = .photo
        }
        
        // 카메라 입력 설정
        await setupCameraInput()
        
        // 출력 설정
        setupPhotoOutput()
        
        // QR 스캐너 설정
        _ = qrScanner.configureOutput(for: session)
        
        session.commitConfiguration()
        
        sessionState = .stopped
        
        print("📷 카메라 세션 설정 완료")
    }
    
    /// 세션 시작
    func startSession() {
        guard sessionState == .stopped || sessionState == .paused else { return }
        
        sessionQueue.async { [weak self] in
            self?.session.startRunning()
            
            Task { @MainActor in
                self?.sessionState = .running
                print("📷 카메라 세션 시작")
            }
        }
    }
    
    /// 세션 중지
    func stopSession() {
        guard sessionState == .running else { return }
        
        sessionQueue.async { [weak self] in
            self?.session.stopRunning()
            
            Task { @MainActor in
                self?.sessionState = .stopped
                print("📷 카메라 세션 중지")
            }
        }
    }
    
    // MARK: - 카메라 전환
    
    /// 카메라 전환 (전면 ↔ 후면)
    func switchCamera() async {
        session.beginConfiguration()
        
        // 기존 입력 제거
        if let currentInput = currentVideoInput {
            session.removeInput(currentInput)
        }
        
        // 새 카메라 설정
        await setupCameraInput()
        
        session.commitConfiguration()
        
        // 햅틱 피드백
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        print("📷 카메라 전환: \(cameraPosition.rawValue)")
    }
    
    /// 플래시 모드 순환
    func cycleFlashMode() {
        flashMode = flashMode.next
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    /// 타이머 설정 순환
    func cycleTimerSetting() {
        timerSetting = timerSetting.next
        timerProcessor.setTimer(timerSetting)
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    // MARK: - 포커스 & 노출
    
    /// 탭 투 포커스
    func focusAt(point: CGPoint) {
        deviceManager.focusAt(point: point, adjustExposure: true)
    }
    
    /// 포커스 포인트 (UI 표시용)
    var focusPoint: FocusPoint? { deviceManager.focusPoint }
    
    /// 노출 보정
    var exposureBias: Float {
        get { deviceManager.exposureBias }
        set { deviceManager.exposureBias = newValue }
    }
    
    /// 노출 보정 범위
    var exposureBiasRange: ClosedRange<Float> { deviceManager.exposureBiasRange }
    
    // MARK: - 줌 제어
    
    /// 줌 설정
    func setZoom(_ factor: CGFloat) {
        deviceManager.setZoom(factor)
    }
    
    /// 핀치 시작
    func pinchBegan() {
        deviceManager.pinchBegan()
    }
    
    /// 핀치 변경
    func pinchChanged(scale: CGFloat) {
        deviceManager.pinchChanged(scale: scale)
    }
    
    /// 줌 프리셋 적용
    func applyZoomPreset(_ preset: CGFloat) {
        deviceManager.applyZoomPreset(preset)
    }
    
    // MARK: - 사진 촬영
    
    /// 사진 촬영 (타이머 지원)
    func capturePhoto() {
        guard captureMode == .photo else { return }
        
        // 타이머가 설정된 경우
        if timerSetting != .off {
            timerProcessor.startTimer()
        } else {
            performPhotoCapture()
        }
    }
    
    /// 실제 사진 촬영 수행
    private func performPhotoCapture() {
        isCapturing = true
        
        // 캡처 설정 생성
        let configuration = PhotoCaptureConfiguration(
            flashMode: flashMode,
            hdrMode: hdrMode,
            isHighResolutionEnabled: true,
            qualityPrioritization: .balanced,
            saveToPhotoLibrary: true,
            isMirroringEnabled: cameraPosition == .front
        )
        
        // AVCapturePhotoSettings 생성
        let settings = PhotoSettingsBuilder.build(
            from: configuration,
            photoOutput: photoOutput,
            device: currentVideoInput?.device
        )
        
        // 프로세서 생성
        let processor = PhotoCaptureProcessor(
            configuration: configuration,
            requestedPhotoSettingsID: settings.uniqueID,
            cameraPosition: cameraPosition
        )
        
        // 셔터 타이밍 콜백
        processor.willCapturePhotoHandler = { [weak self] in
            // 화면 깜빡임 효과는 뷰에서 처리
        }
        
        // 캡처 완료 콜백
        processor.completionHandler = { [weak self] result in
            Task { @MainActor in
                self?.isCapturing = false
                
                switch result {
                case .success(let output):
                    let media = CapturedMedia(
                        type: .photo,
                        image: output.image,
                        capturedAt: output.capturedAt,
                        fileURL: output.fileURL
                    )
                    self?.capturedMedia.insert(media, at: 0)
                    print("📸 사진 촬영 완료")
                    
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("⚠️ 사진 촬영 실패: \(error.localizedDescription)")
                }
            }
        }
        
        currentPhotoProcessor = processor
        photoOutput.capturePhoto(with: settings, delegate: processor)
        
        // 햅틱 피드백
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    /// 타이머 촬영 취소
    func cancelTimer() {
        timerProcessor.cancelTimer()
        timerCountdown = 0
    }
    
    // MARK: - 연속 촬영 (Burst)
    
    /// 연속 촬영 시작
    func startBurstCapture() {
        let configuration = PhotoCaptureConfiguration(
            flashMode: .off,  // 연속 촬영 시 플래시 비활성화
            qualityPrioritization: .speed
        )
        
        burstProcessor.startBurst(with: photoOutput, configuration: configuration)
    }
    
    /// 연속 촬영 중지
    func stopBurstCapture() {
        burstProcessor.stopBurst()
    }
    
    /// 연속 촬영 중 여부
    var isBurstCapturing: Bool { burstProcessor.isCapturing }
    
    // MARK: - 비디오 녹화
    
    /// 비디오 녹화 시작
    func startVideoRecording() {
        guard captureMode == .video else { return }
        
        // 비디오 출력 설정 (아직 안 되어 있으면)
        if !session.outputs.contains(videoProcessor.output) {
            session.beginConfiguration()
            _ = videoProcessor.configureOutput(for: session)
            
            // 오디오 입력 추가
            if isMicrophoneAuthorized {
                setupAudioInput()
            }
            
            session.commitConfiguration()
        }
        
        let configuration = VideoRecordingConfiguration(
            resolution: .hd1080p,
            frameRate: .fps30,
            isAudioEnabled: isMicrophoneAuthorized,
            saveToPhotoLibrary: true
        )
        
        videoProcessor.startRecording(configuration: configuration) { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success(let media):
                    self?.capturedMedia.insert(media, at: 0)
                    print("🎬 비디오 녹화 완료")
                    
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("⚠️ 비디오 녹화 실패: \(error.localizedDescription)")
                }
            }
        }
        
        // 토치 모드 설정
        if flashMode == .on {
            deviceManager.setTorchMode(.on)
        }
        
        // 햅틱
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    /// 비디오 녹화 중지
    func stopVideoRecording() {
        videoProcessor.stopRecording()
        deviceManager.setTorchMode(.off)
        
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    /// 비디오 녹화 토글
    func toggleVideoRecording() {
        if isRecording {
            stopVideoRecording()
        } else {
            startVideoRecording()
        }
    }
    
    // MARK: - QR 코드 스캔
    
    /// QR 스캔 시작
    func startQRScanning() {
        captureMode = .qrCode
        qrScanner.startScanning()
    }
    
    /// QR 스캔 중지
    func stopQRScanning() {
        qrScanner.stopScanning()
    }
    
    /// QR 스캔 결과 콜백 설정
    func setQRScanHandler(_ handler: @escaping (QRCodeScanResult) -> Void) {
        qrScanner.onScanResult = handler
    }
    
    // MARK: - Private Setup Methods
    
    /// 카메라 입력 설정
    private func setupCameraInput() async {
        guard let camera = getCamera(for: cameraPosition) else {
            errorMessage = CameraError.deviceNotFound.localizedDescription
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            
            if session.canAddInput(input) {
                session.addInput(input)
                currentVideoInput = input
                
                // 디바이스 매니저 설정
                deviceManager.configureDevice(camera)
            }
        } catch {
            errorMessage = CameraError.setupFailed(error.localizedDescription).localizedDescription
        }
    }
    
    /// 오디오 입력 설정
    private func setupAudioInput() {
        guard let microphone = AVCaptureDevice.default(for: .audio) else { return }
        
        do {
            let input = try AVCaptureDeviceInput(device: microphone)
            
            if session.canAddInput(input) {
                session.addInput(input)
                currentAudioInput = input
            }
        } catch {
            print("⚠️ 마이크 설정 실패: \(error.localizedDescription)")
        }
    }
    
    /// 사진 출력 설정
    private func setupPhotoOutput() {
        guard session.canAddOutput(photoOutput) else { return }
        
        session.addOutput(photoOutput)
        
        // 고해상도 캡처
        photoOutput.isHighResolutionCaptureEnabled = true
        photoOutput.maxPhotoQualityPrioritization = .quality
        
        // 최대 해상도 설정
        if let connection = photoOutput.connection(with: .video) {
            if connection.isVideoRotationAngleSupported(90) {
                connection.videoRotationAngle = 90
            }
        }
    }
    
    /// 캡처 모드 변경 시 설정
    private func configureCaptureMode() async {
        session.beginConfiguration()
        
        switch captureMode {
        case .photo:
            // 사진 프리셋
            if session.canSetSessionPreset(.photo) {
                session.sessionPreset = .photo
            }
            qrScanner.stopScanning()
            
        case .video:
            // 비디오 프리셋
            if session.canSetSessionPreset(.hd1920x1080) {
                session.sessionPreset = .hd1920x1080
            }
            
            // 비디오 출력 설정
            if !session.outputs.contains(videoProcessor.output) {
                _ = videoProcessor.configureOutput(for: session)
            }
            
            // 오디오 입력
            if isMicrophoneAuthorized && currentAudioInput == nil {
                setupAudioInput()
            }
            
            qrScanner.stopScanning()
            
        case .qrCode:
            qrScanner.startScanning()
        }
        
        session.commitConfiguration()
    }
    
    /// 타이머 프로세서 설정
    private func setupTimerProcessor() {
        timerProcessor.captureHandler = { [weak self] in
            self?.performPhotoCapture()
        }
        
        timerProcessor.countdownHandler = { [weak self] seconds in
            self?.timerCountdown = seconds
        }
        
        timerProcessor.cancelHandler = { [weak self] in
            self?.timerCountdown = 0
        }
    }
    
    /// 연속 촬영 프로세서 설정
    private func setupBurstProcessor() {
        burstProcessor.completionHandler = { [weak self] images in
            Task { @MainActor in
                for image in images {
                    let media = CapturedMedia(type: .photo, image: image)
                    self?.capturedMedia.insert(media, at: 0)
                }
                print("📸 연속 촬영 완료: \(images.count)장")
            }
        }
    }
    
    /// 카메라 디바이스 가져오기
    private func getCamera(for position: CameraPosition) -> AVCaptureDevice? {
        // 트리플/듀얼 카메라 우선
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

// MARK: - 미디어 관리

extension CameraManager {
    
    /// 미디어 삭제
    func deleteMedia(_ media: CapturedMedia) {
        capturedMedia.removeAll { $0.id == media.id }
    }
    
    /// 모든 미디어 삭제
    func clearAllMedia() {
        capturedMedia.removeAll()
    }
    
    /// 마지막 촬영 미디어
    var lastCapturedMedia: CapturedMedia? {
        capturedMedia.first
    }
}
