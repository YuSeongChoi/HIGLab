import SwiftUI
import PhotosUI

// MARK: - Vision Lab 뷰
// 텍스트 인식, 얼굴 감지, 포즈 감지를 통합한 실험실 뷰
// VNRecognizeTextRequest, VNDetectFaceRectanglesRequest, VNDetectHumanBodyPoseRequest 활용

struct VisionLabView: View {
    
    // MARK: - 환경 객체
    @EnvironmentObject private var analyzer: VisionAnalyzer
    
    // MARK: - 상태
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: PlatformImage?
    @State private var selectedMode: AnalysisMode = .all
    @State private var isProcessing = false
    @State private var errorMessage: String?
    
    // MARK: - 분석 결과
    @State private var recognizedTexts: [RecognizedText] = []
    @State private var detectedFaces: [DetectedFace] = []
    @State private var detectedPoses: [DetectedPose] = []
    @State private var analysisTimeMs: Double = 0
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 이미지 표시 영역
                    imageDisplayArea
                    
                    // 분석 모드 선택
                    modeSelector
                    
                    // 사진 선택 버튼
                    photoPickerButton
                    
                    // 결과 표시
                    if !isProcessing {
                        resultsSection
                    }
                }
                .padding()
            }
            .navigationTitle("Vision 분석")
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    await loadAndAnalyze(item: newItem)
                }
            }
            .alert("오류", isPresented: .constant(errorMessage != nil)) {
                Button("확인") { errorMessage = nil }
            } message: {
                if let errorMessage { Text(errorMessage) }
            }
        }
    }
    
    // MARK: - 이미지 표시 영역
    @ViewBuilder
    private var imageDisplayArea: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(.gray.opacity(0.1))
                .frame(height: 300)
            
            if let selectedImage {
                GeometryReader { geometry in
                    ZStack {
                        // 이미지
                        #if canImport(UIKit)
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                        #elseif canImport(AppKit)
                        Image(nsImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                        #endif
                        
                        // 얼굴 오버레이
                        ForEach(detectedFaces) { face in
                            FaceOverlay(face: face, viewSize: geometry.size)
                        }
                        
                        // 포즈 오버레이
                        ForEach(detectedPoses) { pose in
                            PoseOverlay(pose: pose, viewSize: geometry.size)
                        }
                        
                        // 텍스트 영역 오버레이
                        ForEach(recognizedTexts) { text in
                            TextRegionOverlay(text: text, viewSize: geometry.size)
                        }
                    }
                }
                .frame(height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "eye.circle")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary)
                    Text("이미지를 선택하세요")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }
            
            // 로딩 오버레이
            if isProcessing {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("분석 중...")
                        .font(.headline)
                }
            }
        }
    }
    
    // MARK: - 분석 모드 선택
    @ViewBuilder
    private var modeSelector: some View {
        Picker("분석 모드", selection: $selectedMode) {
            ForEach(AnalysisMode.allCases) { mode in
                Text(mode.rawValue).tag(mode)
            }
        }
        .pickerStyle(.segmented)
    }
    
    // MARK: - 사진 선택 버튼
    @ViewBuilder
    private var photoPickerButton: some View {
        PhotosPicker(
            selection: $selectedItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
            Label("사진 선택", systemImage: "photo.badge.plus")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(isProcessing)
    }
    
    // MARK: - 결과 섹션
    @ViewBuilder
    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 분석 시간
            if analysisTimeMs > 0 {
                HStack {
                    Image(systemName: "clock")
                    Text("분석 시간: \(String(format: "%.1f", analysisTimeMs))ms")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            // 텍스트 인식 결과
            if selectedMode == .all || selectedMode == .text {
                if !recognizedTexts.isEmpty {
                    ResultSection(title: "인식된 텍스트", systemImage: "doc.text") {
                        ForEach(recognizedTexts) { text in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(text.text)
                                    .font(.body)
                                Text("신뢰도: \(String(format: "%.1f%%", text.confidence * 100))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            
            // 얼굴 감지 결과
            if selectedMode == .all || selectedMode == .face {
                if !detectedFaces.isEmpty {
                    ResultSection(title: "감지된 얼굴", systemImage: "face.smiling") {
                        ForEach(Array(detectedFaces.enumerated()), id: \.element.id) { index, face in
                            VStack(alignment: .leading, spacing: 4) {
                                Text("얼굴 #\(index + 1)")
                                    .font(.headline)
                                
                                if let roll = face.rollDegrees {
                                    Text("회전: \(String(format: "%.1f°", roll))")
                                        .font(.caption)
                                }
                                
                                if let yaw = face.yawDegrees {
                                    Text("기울기: \(String(format: "%.1f°", yaw))")
                                        .font(.caption)
                                }
                                
                                if face.landmarks != nil {
                                    Text("랜드마크 포함")
                                        .font(.caption)
                                        .foregroundStyle(.blue)
                                }
                            }
                            .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            
            // 포즈 감지 결과
            if selectedMode == .all || selectedMode == .pose {
                if !detectedPoses.isEmpty {
                    ResultSection(title: "감지된 포즈", systemImage: "figure.stand") {
                        ForEach(Array(detectedPoses.enumerated()), id: \.element.id) { index, pose in
                            VStack(alignment: .leading, spacing: 4) {
                                Text("사람 #\(index + 1)")
                                    .font(.headline)
                                Text("관절점: \(pose.joints.count)개")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 이미지 로드 및 분석
    private func loadAndAnalyze(item: PhotosPickerItem?) async {
        guard let item else { return }
        
        isProcessing = true
        clearResults()
        
        defer { isProcessing = false }
        
        do {
            guard let data = try await item.loadTransferable(type: Data.self) else {
                errorMessage = "이미지를 로드할 수 없습니다"
                return
            }
            
            #if canImport(UIKit)
            guard let image = UIImage(data: data) else {
                errorMessage = "이미지 형식이 올바르지 않습니다"
                return
            }
            #elseif canImport(AppKit)
            guard let image = NSImage(data: data) else {
                errorMessage = "이미지 형식이 올바르지 않습니다"
                return
            }
            #endif
            
            selectedImage = image
            
            // 선택된 모드에 따라 분석 수행
            switch selectedMode {
            case .all:
                let result = try await analyzer.analyzeAll(in: image)
                recognizedTexts = result.texts
                detectedFaces = result.faces
                detectedPoses = result.poses
                analysisTimeMs = result.analysisTimeMs
                
            case .text:
                recognizedTexts = try await analyzer.recognizeText(in: image)
                analysisTimeMs = analyzer.lastAnalysisTimeMs
                
            case .face:
                detectedFaces = try await analyzer.detectFaces(in: image)
                analysisTimeMs = analyzer.lastAnalysisTimeMs
                
            case .pose:
                detectedPoses = try await analyzer.detectPoses(in: image)
                analysisTimeMs = analyzer.lastAnalysisTimeMs
            }
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func clearResults() {
        recognizedTexts = []
        detectedFaces = []
        detectedPoses = []
        analysisTimeMs = 0
    }
}

// MARK: - 분석 모드
enum AnalysisMode: String, CaseIterable, Identifiable {
    case all = "전체"
    case text = "텍스트"
    case face = "얼굴"
    case pose = "포즈"
    
    var id: String { rawValue }
}

// MARK: - 결과 섹션 컨테이너
struct ResultSection<Content: View>: View {
    let title: String
    let systemImage: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .foregroundStyle(.primary)
            
            content()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 얼굴 오버레이
struct FaceOverlay: View {
    let face: DetectedFace
    let viewSize: CGSize
    
    var body: some View {
        let rect = face.screenBoundingBox(in: viewSize)
        
        RoundedRectangle(cornerRadius: 4)
            .stroke(.green, lineWidth: 2)
            .frame(width: rect.width, height: rect.height)
            .position(x: rect.midX, y: rect.midY)
    }
}

// MARK: - 포즈 오버레이
struct PoseOverlay: View {
    let pose: DetectedPose
    let viewSize: CGSize
    
    var body: some View {
        Canvas { context, size in
            // 관절 연결선 그리기
            for connection in pose.connections {
                guard let start = pose.screenPoint(for: connection.0, in: viewSize),
                      let end = pose.screenPoint(for: connection.1, in: viewSize) else {
                    continue
                }
                
                var path = Path()
                path.move(to: start)
                path.addLine(to: end)
                
                context.stroke(path, with: .color(.blue), lineWidth: 2)
            }
            
            // 관절점 그리기
            for (_, point) in pose.joints {
                let screenPoint = CGPoint(
                    x: point.x * viewSize.width,
                    y: point.y * viewSize.height
                )
                
                let circle = Path(ellipseIn: CGRect(
                    x: screenPoint.x - 4,
                    y: screenPoint.y - 4,
                    width: 8,
                    height: 8
                ))
                
                context.fill(circle, with: .color(.red))
            }
        }
    }
}

// MARK: - 텍스트 영역 오버레이
struct TextRegionOverlay: View {
    let text: RecognizedText
    let viewSize: CGSize
    
    var body: some View {
        let rect = text.screenBoundingBox(in: viewSize)
        
        RoundedRectangle(cornerRadius: 2)
            .stroke(.orange, lineWidth: 1)
            .background(
                RoundedRectangle(cornerRadius: 2)
                    .fill(.orange.opacity(0.1))
            )
            .frame(width: rect.width, height: rect.height)
            .position(x: rect.midX, y: rect.midY)
    }
}

// MARK: - 프리뷰
#Preview {
    VisionLabView()
        .environmentObject(VisionAnalyzer())
}
