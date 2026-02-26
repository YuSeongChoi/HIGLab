# AVFoundation AI Reference

> Camera, audio, and video capture guide. Read this document to generate AVFoundation code.

## Overview

AVFoundation is a framework for media capture, playback, and editing.
It implements camera apps, video recording, audio processing, and more.

## Required Imports

```swift
import AVFoundation
import AVKit  // Playback UI
```

## Project Setup (Info.plist)

```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required for taking photos/videos.</string>

<key>NSMicrophoneUsageDescription</key>
<string>Microphone access is required for video recording.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Required to save captured media.</string>
```

## Core Components

### 1. Camera Session Setup

```swift
class CameraManager: NSObject {
    let captureSession = AVCaptureSession()
    private var videoOutput: AVCapturePhotoOutput?
    
    func setupCamera() {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .photo
        
        // Camera input
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera) else { return }
        
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        
        // Photo output
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

### 2. Permission Request

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

## Complete Working Example

### Camera App

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
        
        // Select camera
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            error = CameraError.noCameraAvailable
            return
        }
        currentDevice = camera
        
        // Add input
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch {
            self.error = error
            return
        }
        
        // Add output
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
            print("Zoom setting failed: \(error)")
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
            // Camera preview
            CameraPreview(session: camera.captureSession)
                .ignoresSafeArea()
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            zoomFactor = value
                            camera.setZoom(value)
                        }
                )
            
            // Controls
            VStack {
                Spacer()
                
                HStack(spacing: 60) {
                    // Switch camera
                    Button {
                        camera.switchCamera()
                    } label: {
                        Image(systemName: "camera.rotate")
                            .font(.title)
                            .foregroundStyle(.white)
                    }
                    
                    // Capture button
                    Button {
                        camera.capturePhoto()
                    } label: {
                        Circle()
                            .stroke(.white, lineWidth: 4)
                            .frame(width: 70, height: 70)
                    }
                    
                    // Flash
                    Button {
                        // Toggle flash
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

## Advanced Patterns

### 1. Video Recording

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
        // Handle save completion
        print("Recording complete: \(outputFileURL)")
    }
}
```

### 2. Audio Recording

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

### 3. Real-time Frame Processing

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

## Important Notes

1. **Thread Safety**
   - `captureSession.startRunning()` is blocking → run in background
   - Configuration changes must be between `beginConfiguration()` / `commitConfiguration()`

2. **Permissions**
   - Camera permission check is async
   - Microphone permission also required separately (for video recording)

3. **Memory Management**
   - Use `autoreleasepool` for real-time frame processing
   - Set `alwaysDiscardsLateVideoFrames = true`

4. **Simulator Limitations**
   - Camera can only be tested on real devices
