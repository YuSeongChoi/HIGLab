//
//  TextRecognitionView.swift
//  VisionScanner
//
//  텍스트 인식 (OCR) 화면
//

import SwiftUI
import PhotosUI
import Vision

/// 텍스트 인식 (OCR) 뷰
struct TextRecognitionView: View {
    
    // MARK: - 상태
    
    /// Vision 매니저
    @EnvironmentObject var visionManager: VisionManager
    
    /// 선택된 사진
    @State private var selectedItem: PhotosPickerItem?
    
    /// 분석할 이미지
    @State private var selectedImage: UIImage?
    
    /// 인식된 텍스트 결과
    @State private var results: [TextRecognitionResult] = []
    
    /// 인식 정확도 설정
    @State private var useAccurateRecognition = true
    
    /// 결과 오버레이 표시 여부
    @State private var showOverlay = true
    
    /// 결과 시트 표시 여부
    @State private var showResultSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 이미지 선택 영역
                imageSection
                
                // 설정 섹션
                settingsSection
                
                // 분석 버튼
                analyzeButton
                
                // 결과 요약
                if !results.isEmpty {
                    resultSummary
                }
            }
            .padding()
        }
        .navigationTitle("텍스트 인식")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedItem) { _, newItem in
            loadImage(from: newItem)
        }
        .sheet(isPresented: $showResultSheet) {
            resultSheet
        }
        .alert("오류", isPresented: .init(
            get: { visionManager.errorMessage != nil },
            set: { if !$0 { visionManager.clearError() } }
        )) {
            Button("확인") { visionManager.clearError() }
        } message: {
            Text(visionManager.errorMessage ?? "")
        }
    }
    
    // MARK: - 이미지 섹션
    
    /// 이미지 선택 및 표시 영역
    private var imageSection: some View {
        VStack(spacing: 12) {
            // 이미지 표시 영역
            ZStack {
                if let image = selectedImage {
                    // 선택된 이미지 표시
                    GeometryReader { geometry in
                        ZStack {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                            
                            // 인식된 영역 오버레이
                            if showOverlay {
                                overlayView(in: geometry.size, image: image)
                            }
                        }
                    }
                    .aspectRatio(selectedImage?.size ?? CGSize(width: 1, height: 1), contentMode: .fit)
                } else {
                    // 플레이스홀더
                    placeholderView
                }
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 200)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // 이미지 선택 버튼
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Label(selectedImage == nil ? "이미지 선택" : "다른 이미지 선택", systemImage: "photo.on.rectangle")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
    
    /// 플레이스홀더 뷰
    private var placeholderView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.viewfinder")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)
            
            Text("텍스트를 인식할 이미지를 선택하세요")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
    
    /// 인식된 영역 오버레이
    private func overlayView(in size: CGSize, image: UIImage) -> some View {
        // 이미지 실제 표시 크기 계산
        let imageAspect = image.size.width / image.size.height
        let viewAspect = size.width / size.height
        
        let displaySize: CGSize
        if imageAspect > viewAspect {
            displaySize = CGSize(width: size.width, height: size.width / imageAspect)
        } else {
            displaySize = CGSize(width: size.height * imageAspect, height: size.height)
        }
        
        return ZStack {
            ForEach(results) { result in
                let rect = VisionManager.convertBoundingBox(result.boundingBox, to: displaySize)
                
                Rectangle()
                    .stroke(Color.blue, lineWidth: 2)
                    .background(Color.blue.opacity(0.1))
                    .frame(width: rect.width, height: rect.height)
                    .position(x: rect.midX, y: rect.midY)
            }
        }
        .frame(width: displaySize.width, height: displaySize.height)
    }
    
    // MARK: - 설정 섹션
    
    /// 설정 섹션
    private var settingsSection: some View {
        VStack(spacing: 12) {
            // 정확도 설정
            Toggle(isOn: $useAccurateRecognition) {
                HStack {
                    Image(systemName: "scope")
                        .foregroundStyle(.blue)
                    VStack(alignment: .leading) {
                        Text("정확한 인식")
                        Text("더 정확하지만 느릴 수 있습니다")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            // 오버레이 표시 설정
            Toggle(isOn: $showOverlay) {
                HStack {
                    Image(systemName: "rectangle.dashed")
                        .foregroundStyle(.blue)
                    Text("인식 영역 표시")
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - 분석 버튼
    
    /// 분석 시작 버튼
    private var analyzeButton: some View {
        Button {
            Task {
                await analyzeImage()
            }
        } label: {
            HStack {
                if visionManager.isProcessing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "text.viewfinder")
                }
                Text(visionManager.isProcessing ? "분석 중..." : "텍스트 인식 시작")
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(selectedImage == nil ? Color.gray : Color.blue)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(selectedImage == nil || visionManager.isProcessing)
    }
    
    // MARK: - 결과 요약
    
    /// 결과 요약 뷰
    private var resultSummary: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text("\(results.count)개의 텍스트 블록 인식됨")
                    .font(.headline)
                Spacer()
                Button("전체 보기") {
                    showResultSheet = true
                }
                .font(.subheadline)
            }
            
            // 미리보기 (처음 3개)
            VStack(alignment: .leading, spacing: 8) {
                ForEach(results.prefix(3)) { result in
                    HStack {
                        Text(result.text)
                            .lineLimit(1)
                        Spacer()
                        Text(result.confidencePercentage)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                if results.count > 3 {
                    Text("외 \(results.count - 3)개...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 12)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 5)
    }
    
    // MARK: - 결과 시트
    
    /// 전체 결과 시트
    private var resultSheet: some View {
        NavigationStack {
            List {
                // 전체 텍스트 복사 섹션
                Section {
                    let allText = results.map(\.text).joined(separator: "\n")
                    Button {
                        UIPasteboard.general.string = allText
                    } label: {
                        Label("전체 텍스트 복사", systemImage: "doc.on.doc")
                    }
                }
                
                // 개별 결과 섹션
                Section("인식된 텍스트 (\(results.count)개)") {
                    ForEach(results) { result in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(result.text)
                                .font(.body)
                            
                            HStack {
                                Text("신뢰도: \(result.confidencePercentage)")
                                Spacer()
                                Button {
                                    UIPasteboard.general.string = result.text
                                } label: {
                                    Image(systemName: "doc.on.doc")
                                }
                                .buttonStyle(.borderless)
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("인식 결과")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") {
                        showResultSheet = false
                    }
                }
            }
        }
    }
    
    // MARK: - 메서드
    
    /// 선택된 아이템에서 이미지를 로드합니다
    private func loadImage(from item: PhotosPickerItem?) {
        guard let item else { return }
        
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    selectedImage = image
                    results = []  // 이전 결과 초기화
                }
            }
        }
    }
    
    /// 이미지 분석을 실행합니다
    private func analyzeImage() async {
        guard let image = selectedImage else { return }
        
        // 이미지 전처리
        let processedImage = ImageProcessor.preprocessForOCR(image)
        
        // 텍스트 인식 실행
        let recognitionLevel: VNRequestTextRecognitionLevel = useAccurateRecognition ? .accurate : .fast
        results = await visionManager.recognizeText(
            in: processedImage,
            recognitionLevel: recognitionLevel,
            languages: ["ko-KR", "en-US", "ja-JP"]  // 한국어, 영어, 일본어 지원
        )
    }
}

// MARK: - 프리뷰

#Preview {
    NavigationStack {
        TextRecognitionView()
            .environmentObject(VisionManager())
    }
}
