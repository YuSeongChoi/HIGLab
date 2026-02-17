import SwiftUI
import AVFoundation

// MARK: - 카메라 분류 뷰
// 실시간 카메라 피드를 사용한 이미지 분류

struct CameraClassifyView: View {
    
    // MARK: - 환경 객체
    @EnvironmentObject private var classifier: ImageClassifier
    
    // MARK: - 상태 객체
    @StateObject private var cameraManager = CameraManager()
    
    // MARK: - 상태
    @State private var results: [ClassificationResult] = []
    @State private var isClassifying = false
    @State private var lastClassificationTime = Date.distantPast
    
    /// 분류 간격 (초)
    private let classificationInterval: TimeInterval = 0.5
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                // 카메라 프리뷰
                CameraPreviewView(session: cameraManager.session)
                    .ignoresSafeArea()
                
                // 결과 오버레이
                VStack {
                    Spacer()
                    
                    // 결과 표시
                    if !results.isEmpty {
                        ResultsOverlay(results: results)
                            .padding()
                    }
                }
                
                // 권한 없음 메시지
                if !cameraManager.isAuthorized {
                    permissionDeniedView
                }
            }
            .navigationTitle("실시간 분류")
            .navigationBarTitleDisplayMode(.inline)
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
                #if canImport(UIKit)
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
                #endif
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
            let newResults = try await classifier.classify(ciImage: frame)
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.2)) {
                    results = newResults
                }
            }
        } catch {
            print("분류 오류: \(error)")
        }
    }
}

// MARK: - 결과 오버레이
struct ResultsOverlay: View {
    let results: [ClassificationResult]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(results.prefix(3)) { result in
                HStack {
                    Text(result.label)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(result.confidencePercentage)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(confidenceColor(for: result.confidenceLevel))
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
        case .low: return .red
        }
    }
}

// MARK: - 카메라 매니저
@MainActor
final class CameraManager: NSObject, ObservableObject {
    
    // MARK: - Published 프로퍼티
    @Published private(set) var isAuthorized = false
    @Published private(set) var currentFrame: CIImage?
    
    // MARK: - 세션
    let session = AVCaptureSession()
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
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera),
              session.canAddInput(input) else {
            session.commitConfiguration()
            return
        }
        
        session.addInput(input)
        
        // 비디오 출력 추가
        videoOutput.setSampleBufferDelegate(self, queue: processingQueue)
        videoOutput.alwaysDiscardsLateVideoFrames = true
        
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
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
        let view = UIView()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        
        context.coordinator.previewLayer = previewLayer
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.previewLayer?.frame = uiView.bounds
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
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
