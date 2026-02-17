// ResultView.swift
// SmartCrop - HIG Lab 샘플 프로젝트
// iOS 26 ExtensibleImage API 활용

import SwiftUI

/// 처리 결과를 표시하고 저장/공유 기능을 제공하는 뷰
struct ResultView: View {
    /// 처리된 이미지
    let processedImage: UIImage
    
    /// 원본 이미지 (비교용)
    let originalImage: UIImage?
    
    /// 처리 모드
    let processingMode: ProcessingMode
    
    /// 닫기 액션
    var onDismiss: (() -> Void)?
    
    /// 저장 중 여부
    @State private var isSaving = false
    
    /// 저장 완료 여부
    @State private var didSave = false
    
    /// 오류 메시지
    @State private var errorMessage: String?
    
    /// 비교 모드 표시 여부
    @State private var showComparison = false
    
    /// 체커보드 배경 표시 여부 (투명 이미지용)
    @State private var showCheckerboard = true
    
    /// 확대/축소 스케일
    @State private var zoomScale: CGFloat = 1.0
    
    /// 드래그 오프셋
    @State private var dragOffset: CGSize = .zero
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 이미지 표시 영역
                imageDisplayArea
                
                // 하단 액션 바
                actionBar
            }
            .navigationTitle("처리 결과")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
            .sheet(isPresented: $showComparison) {
                if let original = originalImage {
                    ComparisonView(
                        originalImage: original,
                        processedImage: processedImage
                    )
                }
            }
            .alert("오류", isPresented: .init(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "")
            }
            .overlay {
                // 저장 완료 피드백
                if didSave {
                    saveSuccessFeedback
                }
            }
        }
    }
    
    // MARK: - 이미지 표시 영역
    
    private var imageDisplayArea: some View {
        GeometryReader { geometry in
            ZStack {
                // 배경
                backgroundView
                
                // 이미지
                imageView
                    .scaleEffect(zoomScale)
                    .offset(dragOffset)
                    .gesture(magnificationGesture)
                    .gesture(dragGesture)
                    .onTapGesture(count: 2) {
                        withAnimation(.spring(response: 0.3)) {
                            if zoomScale > 1 {
                                zoomScale = 1
                                dragOffset = .zero
                            } else {
                                zoomScale = 2
                            }
                        }
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    /// 배경 뷰
    @ViewBuilder
    private var backgroundView: some View {
        if showCheckerboard && processingMode == .removeBackground {
            // 체커보드 패턴 (투명 영역 표시)
            CheckerboardPattern()
                .ignoresSafeArea()
        } else {
            Color(.secondarySystemBackground)
                .ignoresSafeArea()
        }
    }
    
    /// 이미지 뷰
    private var imageView: some View {
        Image(uiImage: processedImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.2), radius: 10)
            .padding()
    }
    
    // MARK: - 제스처
    
    /// 확대/축소 제스처
    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let delta = value / zoomScale
                zoomScale = min(max(zoomScale * delta, 0.5), 5)
            }
    }
    
    /// 드래그 제스처
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if zoomScale > 1 {
                    dragOffset = value.translation
                }
            }
            .onEnded { _ in
                if zoomScale <= 1 {
                    withAnimation(.spring(response: 0.3)) {
                        dragOffset = .zero
                    }
                }
            }
    }
    
    // MARK: - 액션 바
    
    private var actionBar: some View {
        HStack(spacing: 20) {
            // 처리 정보
            VStack(alignment: .leading, spacing: 4) {
                Label(processingMode.rawValue, systemImage: processingMode.iconName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text("\(Int(processedImage.size.width)) × \(Int(processedImage.size.height))")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            
            Spacer()
            
            // 비교 버튼
            if originalImage != nil {
                Button {
                    showComparison = true
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "rectangle.on.rectangle")
                        Text("비교")
                            .font(.caption2)
                    }
                }
            }
            
            // 저장 버튼
            Button {
                Task {
                    await saveImage()
                }
            } label: {
                VStack(spacing: 4) {
                    if isSaving {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: "square.and.arrow.down")
                    }
                    Text("저장")
                        .font(.caption2)
                }
            }
            .disabled(isSaving)
            
            // 공유 버튼
            ShareLink(
                item: ShareableImage(image: processedImage),
                preview: SharePreview("SmartCrop 결과", image: Image(uiImage: processedImage))
            ) {
                VStack(spacing: 4) {
                    Image(systemName: "square.and.arrow.up")
                    Text("공유")
                        .font(.caption2)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }
    
    // MARK: - 툴바
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            if let onDismiss {
                Button("닫기", action: onDismiss)
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            if processingMode == .removeBackground {
                Button {
                    showCheckerboard.toggle()
                } label: {
                    Image(systemName: showCheckerboard ? "checkerboard.rectangle" : "rectangle.fill")
                }
                .help("배경 표시 전환")
            }
        }
    }
    
    // MARK: - 저장 완료 피드백
    
    private var saveSuccessFeedback: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 50))
                .foregroundStyle(.green)
            
            Text("저장 완료")
                .font(.headline)
        }
        .padding(30)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .transition(.scale.combined(with: .opacity))
        .onAppear {
            // 2초 후 자동으로 사라짐
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    didSave = false
                }
            }
        }
    }
    
    // MARK: - 메서드
    
    /// 이미지 저장
    private func saveImage() async {
        isSaving = true
        defer { isSaving = false }
        
        let saver = PhotoLibrarySaver()
        do {
            try await saver.saveToPhotoLibrary(processedImage)
            withAnimation(.spring(response: 0.3)) {
                didSave = true
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - 체커보드 패턴 뷰

/// 투명 영역을 시각화하기 위한 체커보드 패턴
struct CheckerboardPattern: View {
    let squareSize: CGFloat = 12
    
    var body: some View {
        Canvas { context, size in
            let cols = Int(ceil(size.width / squareSize))
            let rows = Int(ceil(size.height / squareSize))
            
            let lightColor = Color(white: 0.95)
            let darkColor = Color(white: 0.85)
            
            for row in 0..<rows {
                for col in 0..<cols {
                    let isLight = (row + col) % 2 == 0
                    let rect = CGRect(
                        x: CGFloat(col) * squareSize,
                        y: CGFloat(row) * squareSize,
                        width: squareSize,
                        height: squareSize
                    )
                    context.fill(
                        Path(rect),
                        with: .color(isLight ? lightColor : darkColor)
                    )
                }
            }
        }
    }
}

// MARK: - 이미지 상세 정보 뷰

/// 이미지의 상세 정보를 표시하는 뷰
struct ImageDetailInfoView: View {
    let image: UIImage
    
    var body: some View {
        VStack(spacing: 16) {
            Text("이미지 정보")
                .font(.headline)
            
            Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 12) {
                GridRow {
                    Text("너비")
                        .foregroundStyle(.secondary)
                    Text("\(Int(image.size.width)) px")
                }
                
                GridRow {
                    Text("높이")
                        .foregroundStyle(.secondary)
                    Text("\(Int(image.size.height)) px")
                }
                
                GridRow {
                    Text("스케일")
                        .foregroundStyle(.secondary)
                    Text("\(Int(image.scale))x")
                }
                
                GridRow {
                    Text("용량")
                        .foregroundStyle(.secondary)
                    Text(image.formattedDataSize)
                }
                
                GridRow {
                    Text("방향")
                        .foregroundStyle(.secondary)
                    Text(orientationName)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private var orientationName: String {
        switch image.imageOrientation {
        case .up: return "정상"
        case .down: return "180° 회전"
        case .left: return "왼쪽 90°"
        case .right: return "오른쪽 90°"
        case .upMirrored: return "수평 반전"
        case .downMirrored: return "수직 반전"
        case .leftMirrored: return "왼쪽 반전"
        case .rightMirrored: return "오른쪽 반전"
        @unknown default: return "알 수 없음"
        }
    }
}

// MARK: - 미리보기

#Preview {
    ResultView(
        processedImage: UIImage(systemName: "photo.fill")!,
        originalImage: UIImage(systemName: "photo")!,
        processingMode: .removeBackground
    )
}
