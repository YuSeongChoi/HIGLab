import SwiftUI
import AVFoundation

// MARK: - 카메라 분류 뷰
// 실시간 카메라 피드를 사용한 이미지 분류
// VNCoreMLRequest, VNImageRequestHandler 활용

struct CameraClassifyView: View {
    
    // MARK: - 환경 객체
    @EnvironmentObject private var classifier: ImageClassifier
    
    // MARK: - 상태 객체
    @StateObject private var cameraManager = CameraManager()
    
    // MARK: - 상태
    @State private var results: [ClassificationResult] = []
    @State private var isClassifying = false
    @State private var lastClassificationTime = Date.distantPast
    @State private var showingStats = false
    @State private var fps: Double = 0
    @State private var inferenceTimeMs: Double = 0
    
    /// 분류 간격 (초)
    private let classificationInterval: TimeInterval = 0.3
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                // 카메라 프리뷰
                CameraPreviewView(session: cameraManager.session)
                    .ignoresSafeArea()
                
                // 상단 정보 오버레이
                VStack {
                    if showingStats {
                        statsOverlay
                    }
                    
                    Spacer()
                    
                    // 결과 오버레이
                    if !results.isEmpty {
                        ResultsOverlay(results: results)
                            .padding()
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: results)
                
                // 권한 없음 메시지
                if !cameraManager.isAuthorized {
                    permissionDeniedView
                }
            }
            .navigationTitle("실시간 분류")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                        showingStats.toggle()
                    } label: {
                        Image(systemName: showingStats ? "info.circle.fill" : "info.circle")
                    }
                }
                
                ToolbarItem(placement: .automatic) {
                    Button {
                        cameraManager.toggleCamera()
                    } label: {
                        Image(systemName: "camera.rotate")
                    }
                    .disabled(!cameraManager.isAuthorized)
                }
            }
            .onAppear {
                cameraManager.startSession()
            }
            .onDisappear {
                cameraManager.stopSession()
            }
            .onReceive(cameraManager.$currentFrame) { frame in
                Task {
                    await classifyFrame(frame)
                }
            }
        }
    }
    
    // MARK: - 통계 오버레이
    @ViewBuilder
    private var statsOverlay: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading) {
                Text("FPS")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(String(format: "%.1f", fps))
                    .font(.headline)
            }
            
            Divider()
                .frame(height: 30)
            
            VStack(alignment: .leading) {
                Text("추론 시간")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(String(format: "%.1f ms", inferenceTimeMs))
                    .font(.headline)
            }
            
            if let modelType = classifier.currentModelType {
                Divider()
                    .frame(height: 30)
                
                VStack(alignment: .leading) {
                    Text("모델")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(modelType.rawValue)
                        .font(.headline)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding()
    }
    
    // MARK: - 권한 없음 뷰
    @ViewBuilder
    private var permissionDeniedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.fill")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("카메라 접근 권한 필요")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("설정에서 카메라 접근을 허용해주세요")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button("설정 열기") {
                openSettings()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
    }
    
    // MARK: - 프레임 분류
    private func classifyFrame(_ frame: CIImage?) async {
        guard let frame = frame,
              !isClassifying,
              Date().timeIntervalSince(lastClassificationTime) >= classificationInterval
        else { return }
        
        isClassifying = true
        lastClassificationTime = Date()
        
        defer { isClassifying = false }
        
        do {
            let startTime = CFAbsoluteTimeGetCurrent()
            let newResults = try await classifier.classify(ciImage: frame)
            let endTime = CFAbsoluteTimeGetCurrent()
            
            let elapsed = endTime - startTime
            
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.2)) {
                    results = newResults
                    inferenceTimeMs = elapsed * 1000
                    fps = 1.0 / elapsed
                }
            }
        } catch {
            print("분류 오류: \(error)")
        }
    }
    
    private func openSettings() {
        #if canImport(UIKit)
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
        #endif
    }
}

// MARK: - 결과 오버레이
struct ResultsOverlay: View {
    let results: [ClassificationResult]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(results.prefix(3)) { result in
                HStack {
                    // 신뢰도 레벨 아이콘
                    Image(systemName: result.confidenceLevel.iconName)
                        .foregroundStyle(confidenceColor(for: result.confidenceLevel))
                    
                    Text(result.formattedLabel)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // 신뢰도 바
                    ConfidenceBar(confidence: result.confidence)
                        .frame(width: 60)
                    
                    Text(result.confidencePercentage)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(confidenceColor(for: result.confidenceLevel))
                        .frame(width: 50, alignment: .trailing)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func confidenceColor(for level: ConfidenceLevel) -> Color {
        switch level {
        case .high: return .green
        case .medium: return .orange
        case .low: return .yellow
        case .veryLow: return .red
        }
    }
}

// MARK: - 신뢰도 바
struct ConfidenceBar: View {
    let confidence: Float
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(.gray.opacity(0.3))
                
                RoundedRectangle(cornerRadius: 2)
                    .fill(barColor)
                    .frame(width: geometry.size.width * CGFloat(confidence))
            }
        }
        .frame(height: 6)
    }
    
    private var barColor: Color {
        switch confidence {
        case 0.8...1.0: return .green
        case 0.5..<0.8: return .orange
        case 0.2..<0.5: return .yellow
        default: return .red
        }
    }
}

// MARK: - 카메라 매니저
@MainActor
final class CameraManager: NSObject, ObservableObject {
    
    // MARK: - Published 프로퍼티
    @Published private(set) var isAuthorized = false
    @Published private(set) var currentFrame: CIImage?
    @Published private(set) var currentCameraPosition: AVCaptureDevice.Position = .back
    
    // MARK: - 세션
    let session = AVCaptureSession()
    private var currentInput: AVCaptureDeviceInput?
    private let videoOutput = AVCaptureVideoDataOutput()
    private let processingQueue = DispatchQueue(label: "camera.processing", qos: .userInitiated)
    
    // MARK: - 초기화
    override init() {
        super.init()
        checkAuthorization()
    }
    
    // MARK: - 권한 확인
    private func checkAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isAuthorized = true
            setupSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                Task { @MainActor in
                    self?.isAuthorized = granted
                    if granted {
                        self?.setupSession()
                    }
                }
            }
        default:
            isAuthorized = false
        }
    }
    
    // MARK: - 세션 설정
    private func setupSession() {
        session.beginConfiguration()
        session.sessionPreset = .high
        
        // 카메라 입력 추가
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentCameraPosition),
              let input = try? AVCaptureDeviceInput(device: camera),
              session.canAddInput(input) else {
            session.commitConfiguration()
            return
        }
        
        session.addInput(input)
        currentInput = input
        
        // 비디오 출력 추가
        videoOutput.setSampleBufferDelegate(self, queue: processingQueue)
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }
        
        // 비디오 방향 설정
        if let connection = videoOutput.connection(with: .video) {
            if connection.isVideoOrientationSupported {
                connection.videoOrientation = .portrait
            }
        }
        
        session.commitConfiguration()
    }
    
    // MARK: - 카메라 전환
    func toggleCamera() {
        let newPosition: AVCaptureDevice.Position = currentCameraPosition == .back ? .front : .back
        
        guard let newCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition),
              let newInput = try? AVCaptureDeviceInput(device: newCamera) else {
            return
        }
        
        session.beginConfiguration()
        
        if let currentInput = currentInput {
            session.removeInput(currentInput)
        }
        
        if session.canAddInput(newInput) {
            session.addInput(newInput)
            currentInput = newInput
            currentCameraPosition = newPosition
        }
        
        session.commitConfiguration()
    }
    
    // MARK: - 세션 제어
    func startSession() {
        guard !session.isRunning, isAuthorized else { return }
        processingQueue.async { [weak self] in
            self?.session.startRunning()
        }
    }
    
    func stopSession() {
        guard session.isRunning else { return }
        processingQueue.async { [weak self] in
            self?.session.stopRunning()
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        Task { @MainActor in
            currentFrame = ciImage
        }
    }
}

// MARK: - 카메라 프리뷰 뷰
#if canImport(UIKit)
struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = CameraPreviewUIView(session: session)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

class CameraPreviewUIView: UIView {
    private let previewLayer: AVCaptureVideoPreviewLayer
    
    init(session: AVCaptureSession) {
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        super.init(frame: .zero)
        
        previewLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(previewLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = bounds
    }
}
#elseif canImport(AppKit)
struct CameraPreviewView: NSViewRepresentable {
    let session: AVCaptureSession
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.wantsLayer = true
        view.layer = previewLayer
        
        context.coordinator.previewLayer = previewLayer
        
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        context.coordinator.previewLayer?.frame = nsView.bounds
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
    }
}
#endif

// MARK: - 프리뷰
#Preview {
    CameraClassifyView()
        .environmentObject(ImageClassifier())
}
