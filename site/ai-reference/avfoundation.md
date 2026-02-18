# AVFoundation AI Reference

> 카메라, 오디오, 비디오 캡처 가이드. 이 문서를 읽고 AVFoundation 코드를 생성할 수 있습니다.

## 개요

AVFoundation은 미디어 캡처, 재생, 편집을 위한 프레임워크입니다.
카메라 앱, 비디오 녹화, 오디오 처리 등을 구현합니다.

## 필수 Import

```swift
import AVFoundation
import AVKit  // 재생 UI
```

## 프로젝트 설정 (Info.plist)

```xml
<key>NSCameraUsageDescription</key>
<string>사진/비디오 촬영을 위해 카메라 접근이 필요합니다.</string>

<key>NSMicrophoneUsageDescription</key>
<string>비디오 녹화 시 오디오 녹음이 필요합니다.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>촬영한 미디어를 저장하기 위해 필요합니다.</string>
```

## 핵심 구성요소

### 1. 카메라 세션 설정

```swift
class CameraManager: NSObject {
    let captureSession = AVCaptureSession()
    private var videoOutput: AVCapturePhotoOutput?
    
    func setupCamera() {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .photo
        
        // 카메라 입력
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera) else { return }
        
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        
        // 사진 출력
        let output = AVCapturePhotoOutput()
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
            videoOutput = output
        }
        
        captureSession.commitConfiguration()
    }
    
    func startSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
    func stopSession() {
        captureSession.stopRunning()
    }
}
```

### 2. 권한 요청

```swift
func requestCameraPermission() async -> Bool {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized:
        return true
    case .notDetermined:
        return await AVCaptureDevice.requestAccess(for: .video)
    case .denied, .restricted:
        return false
    @unknown default:
        return false
    }
}
```

## 전체 작동 예제

### 카메라 앱

```swift
import SwiftUI
import AVFoundation

// MARK: - Camera Manager
@Observable
class CameraManager: NSObject {
    let captureSession = AVCaptureSession()
    var capturedImage: UIImage?
    var isSessionRunning = false
    var error: Error?
    
    private var photoOutput: AVCapturePhotoOutput?
    private var currentDevice: AVCaptureDevice?
    
    override init() {
        super.init()
    }
    
    func checkPermission() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        default:
            return false
        }
    }
    
    func setupSession() {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .photo
        
        // 카메라 선택
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            error = CameraError.noCameraAvailable
            return
        }
        currentDevice = camera
        
        // 입력 추가
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch {
            self.error = error
            return
        }
        
        // 출력 추가
        let output = AVCapturePhotoOutput()
        output.maxPhotoQualityPrioritization = .quality
        
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
            photoOutput = output
        }
        
        captureSession.commitConfiguration()
    }
    
    func startSession() {
        guard !captureSession.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
            DispatchQueue.main.async {
                self?.isSessionRunning = true
            }
        }
    }
    
    func stopSession() {
        guard captureSession.isRunning else { return }
        captureSession.stopRunning()
        isSessionRunning = false
    }
    
    func capturePhoto() {
        guard let output = photoOutput else { return }
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        
        output.capturePhoto(with: settings, delegate: self)
    }
    
    func switchCamera() {
        guard let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput else { return }
        
        let newPosition: AVCaptureDevice.Position = currentInput.device.position == .back ? .front : .back
        guard let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition) else { return }
        
        captureSession.beginConfiguration()
        captureSession.removeInput(currentInput)
        
        if let newInput = try? AVCaptureDeviceInput(device: newDevice),
           captureSession.canAddInput(newInput) {
            captureSession.addInput(newInput)
            currentDevice = newDevice
        }
        
        captureSession.commitConfiguration()
    }
    
    func setZoom(_ factor: CGFloat) {
        guard let device = currentDevice else { return }
        
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = max(1.0, min(factor, device.activeFormat.videoMaxZoomFactor))
            device.unlockForConfiguration()
        } catch {
            print("줌 설정 실패: \(error)")
        }
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error {
            self.error = error
            return
        }
        
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else { return }
        
        DispatchQueue.main.async {
            self.capturedImage = image
        }
    }
}

enum CameraError: Error {
    case noCameraAvailable
    case permissionDenied
}

// MARK: - Camera Preview
struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        DispatchQueue.main.async {
            previewLayer.frame = view.bounds
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let layer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            layer.frame = uiView.bounds
        }
    }
}

// MARK: - View
struct CameraView: View {
    @State private var camera = CameraManager()
    @State private var zoomFactor: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // 카메라 프리뷰
            CameraPreview(session: camera.captureSession)
                .ignoresSafeArea()
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            zoomFactor = value
                            camera.setZoom(value)
                        }
                )
            
            // 컨트롤
            VStack {
                Spacer()
                
                HStack(spacing: 60) {
                    // 카메라 전환
                    Button {
                        camera.switchCamera()
                    } label: {
                        Image(systemName: "camera.rotate")
                            .font(.title)
                            .foregroundStyle(.white)
                    }
                    
                    // 촬영 버튼
                    Button {
                        camera.capturePhoto()
                    } label: {
                        Circle()
                            .stroke(.white, lineWidth: 4)
                            .frame(width: 70, height: 70)
                    }
                    
                    // 플래시
                    Button {
                        // 플래시 토글
                    } label: {
                        Image(systemName: "bolt.fill")
                            .font(.title)
                            .foregroundStyle(.white)
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .task {
            if await camera.checkPermission() {
                camera.setupSession()
                camera.startSession()
            }
        }
        .onDisappear {
            camera.stopSession()
        }
        .sheet(item: Binding(
            get: { camera.capturedImage.map { CapturedImage(image: $0) } },
            set: { _ in camera.capturedImage = nil }
        )) { captured in
            Image(uiImage: captured.image)
                .resizable()
                .scaledToFit()
        }
    }
}

struct CapturedImage: Identifiable {
    let id = UUID()
    let image: UIImage
}
```

## 고급 패턴

### 1. 비디오 녹화

```swift
class VideoRecorder: NSObject {
    private var movieOutput: AVCaptureMovieFileOutput?
    private var captureSession: AVCaptureSession
    
    var isRecording: Bool {
        movieOutput?.isRecording ?? false
    }
    
    init(session: AVCaptureSession) {
        self.captureSession = session
        super.init()
        setupMovieOutput()
    }
    
    private func setupMovieOutput() {
        let output = AVCaptureMovieFileOutput()
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
            movieOutput = output
        }
    }
    
    func startRecording() {
        guard let output = movieOutput, !output.isRecording else { return }
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).mov")
        output.startRecording(to: tempURL, recordingDelegate: self)
    }
    
    func stopRecording() {
        movieOutput?.stopRecording()
    }
}

extension VideoRecorder: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        // 저장 완료 처리
        print("녹화 완료: \(outputFileURL)")
    }
}
```

### 2. 오디오 녹음

```swift
import AVFAudio

class AudioRecorder {
    private var audioRecorder: AVAudioRecorder?
    
    func startRecording() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default)
        try session.setActive(true)
        
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("recording.m4a")
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        audioRecorder = try AVAudioRecorder(url: url, settings: settings)
        audioRecorder?.record()
    }
    
    func stopRecording() -> URL? {
        audioRecorder?.stop()
        return audioRecorder?.url
    }
}
```

### 3. 실시간 프레임 처리

```swift
class FrameProcessor: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    var onFrame: ((CVPixelBuffer) -> Void)?
    
    func setupVideoOutput(for session: AVCaptureSession) {
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "video.queue"))
        output.alwaysDiscardsLateVideoFrames = true
        
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        onFrame?(pixelBuffer)
    }
}
```

## 주의사항

1. **스레드 안전**
   - `captureSession.startRunning()` 은 블로킹 → 백그라운드에서
   - 설정 변경은 `beginConfiguration()` / `commitConfiguration()` 사이에서

2. **권한**
   - 카메라 권한은 비동기 확인
   - 마이크 권한도 별도 필요 (비디오 녹화 시)

3. **메모리 관리**
   - 실시간 프레임 처리 시 `autoreleasepool` 사용
   - `alwaysDiscardsLateVideoFrames = true` 설정

4. **시뮬레이터 제한**
   - 카메라는 실제 기기에서만 테스트 가능
