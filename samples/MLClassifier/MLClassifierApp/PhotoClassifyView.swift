import SwiftUI
import PhotosUI

// MARK: - 사진 분류 뷰
// 사진 라이브러리에서 이미지를 선택하여 분류
// VNCoreMLRequest, VNClassificationObservation 활용

struct PhotoClassifyView: View {
    
    // MARK: - 환경 객체
    @EnvironmentObject private var classifier: ImageClassifier
    
    // MARK: - 상태
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: PlatformImage?
    @State private var isProcessing = false
    @State private var results: [ClassificationResult] = []
    @State private var errorMessage: String?
    @State private var showingModelInfo = false
    @State private var inferenceTimeMs: Double = 0
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 이미지 표시 영역
                    imageDisplayArea
                    
                    // 사진 선택 버튼
                    photoPickerButton
                    
                    // 분류 정보
                    if inferenceTimeMs > 0 && !results.isEmpty {
                        classificationInfo
                    }
                    
                    // 분류 결과
                    if !results.isEmpty {
                        ResultsView(results: results)
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle("사진 분류")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                        showingModelInfo = true
                    } label: {
                        Image(systemName: "info.circle")
                    }
                }
            }
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    await loadAndClassify(item: newItem)
                }
            }
            .alert("오류", isPresented: .constant(errorMessage != nil)) {
                Button("확인") {
                    errorMessage = nil
                }
            } message: {
                if let errorMessage {
                    Text(errorMessage)
                }
            }
            .sheet(isPresented: $showingModelInfo) {
                modelInfoSheet
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
                #if canImport(UIKit)
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                #elseif canImport(AppKit)
                Image(nsImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                #endif
            } else {
                // 플레이스홀더
                VStack(spacing: 12) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary)
                    Text("사진을 선택하세요")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text("사진 라이브러리에서 이미지를 선택하면\n자동으로 분류가 시작됩니다")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                }
            }
            
            // 로딩 오버레이
            if isProcessing {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("분류 중...")
                        .font(.headline)
                    Text(classifier.state.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
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
    
    // MARK: - 분류 정보
    @ViewBuilder
    private var classificationInfo: some View {
        HStack(spacing: 20) {
            // 추론 시간
            VStack {
                Image(systemName: "clock")
                    .font(.title2)
                    .foregroundStyle(.blue)
                Text("\(String(format: "%.1f", inferenceTimeMs))ms")
                    .font(.headline)
                Text("추론 시간")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            
            Divider()
                .frame(height: 50)
            
            // 결과 수
            VStack {
                Image(systemName: "list.number")
                    .font(.title2)
                    .foregroundStyle(.green)
                Text("\(results.count)")
                    .font(.headline)
                Text("결과 수")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            
            Divider()
                .frame(height: 50)
            
            // 최고 신뢰도
            if let topResult = results.first {
                VStack {
                    Image(systemName: topResult.confidenceLevel.iconName)
                        .font(.title2)
                        .foregroundStyle(colorFor(topResult.confidenceLevel))
                    Text(topResult.confidencePercentage)
                        .font(.headline)
                    Text("최고 신뢰도")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - 모델 정보 시트
    @ViewBuilder
    private var modelInfoSheet: some View {
        NavigationStack {
            List {
                Section("현재 모델") {
                    if let modelType = classifier.currentModelType {
                        LabeledContent("모델", value: modelType.rawValue)
                        LabeledContent("카테고리", value: modelType.category.rawValue)
                        LabeledContent("입력 크기", value: "\(Int(modelType.expectedInputSize.width))×\(Int(modelType.expectedInputSize.height))")
                        
                        Text(modelType.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("모델이 로드되지 않음")
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section("분류 설정") {
                    LabeledContent("최대 결과 수", value: "\(classifier.maxResults)")
                    LabeledContent("최소 신뢰도", value: "\(String(format: "%.0f%%", classifier.minimumConfidence * 100))")
                }
                
                Section("상태") {
                    LabeledContent("상태", value: classifier.state.description)
                }
            }
            .navigationTitle("모델 정보")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") {
                        showingModelInfo = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    // MARK: - 이미지 로드 및 분류
    private func loadAndClassify(item: PhotosPickerItem?) async {
        guard let item else { return }
        
        isProcessing = true
        results = []
        inferenceTimeMs = 0
        
        defer { isProcessing = false }
        
        do {
            // 이미지 데이터 로드
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
            
            // 분류 수행
            results = try await classifier.classify(image: image)
            inferenceTimeMs = classifier.lastPredictionTimeMs
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func colorFor(_ level: ConfidenceLevel) -> Color {
        switch level {
        case .high: return .green
        case .medium: return .orange
        case .low: return .yellow
        case .veryLow: return .red
        }
    }
}

// MARK: - 프리뷰
#Preview {
    PhotoClassifyView()
        .environmentObject(ImageClassifier())
}
