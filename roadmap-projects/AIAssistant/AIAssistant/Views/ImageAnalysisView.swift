import SwiftUI
import PhotosUI

struct ImageAnalysisView: View {
    @State private var visionManager = VisionManager()
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var analysisResult: AnalysisResult?
    @State private var analysisType: AnalysisType = .text
    
    enum AnalysisType: String, CaseIterable {
        case text = "텍스트 인식"
        case classification = "이미지 분류"
        case faces = "얼굴 감지"
    }
    
    struct AnalysisResult {
        let type: AnalysisType
        let content: String
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 이미지 선택
                    imageSection
                    
                    // 분석 유형 선택
                    if selectedImage != nil {
                        analysisTypeSection
                    }
                    
                    // 분석 버튼
                    if selectedImage != nil {
                        analyzeButton
                    }
                    
                    // 결과 표시
                    if let result = analysisResult {
                        resultSection(result)
                    }
                }
                .padding()
            }
            .navigationTitle("이미지 분석")
            .onChange(of: selectedItem) {
                loadImage()
            }
        }
    }
    
    // MARK: - Image Section
    private var imageSection: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            Group {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 50))
                            .foregroundStyle(.secondary)
                        
                        Text("이미지를 선택하세요")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
        }
    }
    
    // MARK: - Analysis Type Section
    private var analysisTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("분석 유형")
                .font(.headline)
            
            ForEach(AnalysisType.allCases, id: \.self) { type in
                AnalysisTypeRow(
                    type: type,
                    isSelected: analysisType == type
                ) {
                    analysisType = type
                    analysisResult = nil
                }
            }
        }
    }
    
    // MARK: - Analyze Button
    private var analyzeButton: some View {
        Button {
            analyzeImage()
        } label: {
            HStack {
                if visionManager.isProcessing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "sparkle.magnifyingglass")
                }
                Text(visionManager.isProcessing ? "분석 중..." : "분석하기")
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.accentColor)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(visionManager.isProcessing)
    }
    
    // MARK: - Result Section
    private func resultSection(_ result: AnalysisResult) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text("분석 결과")
                    .font(.headline)
            }
            
            Text(result.content)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // 복사 버튼
            Button {
                UIPasteboard.general.string = result.content
            } label: {
                Label("결과 복사", systemImage: "doc.on.doc")
                    .font(.subheadline)
            }
        }
    }
    
    // MARK: - Actions
    private func loadImage() {
        Task {
            if let data = try? await selectedItem?.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                selectedImage = image
                analysisResult = nil
            }
        }
    }
    
    private func analyzeImage() {
        guard let image = selectedImage else { return }
        
        Task {
            do {
                let content: String
                
                switch analysisType {
                case .text:
                    content = try await visionManager.recognizeText(from: image)
                    if content.isEmpty {
                        analysisResult = AnalysisResult(type: analysisType, content: "텍스트를 찾을 수 없습니다.")
                    } else {
                        analysisResult = AnalysisResult(type: analysisType, content: content)
                    }
                    
                case .classification:
                    let objects = try await visionManager.classifyImage(image)
                    if objects.isEmpty {
                        content = "객체를 인식할 수 없습니다."
                    } else {
                        content = objects.map { "\($0.label): \(Int($0.confidence * 100))%" }.joined(separator: "\n")
                    }
                    analysisResult = AnalysisResult(type: analysisType, content: content)
                    
                case .faces:
                    let faceCount = try await visionManager.detectFaces(in: image)
                    content = faceCount == 0 ? "얼굴을 찾을 수 없습니다." : "\(faceCount)개의 얼굴이 감지되었습니다."
                    analysisResult = AnalysisResult(type: analysisType, content: content)
                }
            } catch {
                analysisResult = AnalysisResult(type: analysisType, content: "오류: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Analysis Type Row
struct AnalysisTypeRow: View {
    let type: ImageAnalysisView.AnalysisType
    let isSelected: Bool
    let action: () -> Void
    
    private var icon: String {
        switch type {
        case .text: return "doc.text.viewfinder"
        case .classification: return "tag"
        case .faces: return "face.smiling"
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .frame(width: 30)
                
                Text(type.rawValue)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.accent)
                }
            }
            .padding()
            .background(isSelected ? Color.accentColor.opacity(0.1) : Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ImageAnalysisView()
}
