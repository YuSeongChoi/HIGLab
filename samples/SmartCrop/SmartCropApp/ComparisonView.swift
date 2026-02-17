// ComparisonView.swift
// SmartCrop - HIG Lab 샘플 프로젝트
// iOS 26 ExtensibleImage API 활용

import SwiftUI

/// 원본과 처리된 이미지를 비교하는 뷰
/// 슬라이더 방식과 나란히 보기 방식을 지원합니다
struct ComparisonView: View {
    /// 원본 이미지
    let originalImage: UIImage
    
    /// 처리된 이미지
    let processedImage: UIImage
    
    /// 시트 닫기
    @Environment(\.dismiss) private var dismiss
    
    /// 비교 모드
    @State private var comparisonMode: ComparisonMode = .slider
    
    /// 슬라이더 위치 (0.0 ~ 1.0)
    @State private var sliderPosition: CGFloat = 0.5
    
    /// 드래그 중 여부
    @State private var isDragging = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 비교 모드 선택
                modePicker
                
                // 비교 뷰
                comparisonContent
                    .padding()
                
                // 이미지 정보
                imageInfoSection
            }
            .navigationTitle("전후 비교")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - 모드 선택기
    
    private var modePicker: some View {
        Picker("비교 모드", selection: $comparisonMode) {
            ForEach(ComparisonMode.allCases) { mode in
                Text(mode.rawValue).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .padding()
    }
    
    // MARK: - 비교 콘텐츠
    
    @ViewBuilder
    private var comparisonContent: some View {
        switch comparisonMode {
        case .slider:
            sliderComparison
        case .sideBySide:
            sideBySideComparison
        case .toggle:
            toggleComparison
        }
    }
    
    // MARK: - 슬라이더 비교 모드
    
    private var sliderComparison: some View {
        GeometryReader { geometry in
            ZStack {
                // 처리된 이미지 (전체)
                Image(uiImage: processedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
                // 원본 이미지 (클립)
                Image(uiImage: originalImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(
                        SliderClipShape(position: sliderPosition)
                    )
                
                // 슬라이더 핸들
                sliderHandle(in: geometry.size)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 8)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isDragging = true
                        let newPosition = value.location.x / geometry.size.width
                        sliderPosition = min(max(newPosition, 0), 1)
                    }
                    .onEnded { _ in
                        isDragging = false
                    }
            )
        }
        .aspectRatio(
            originalImage.size.width / originalImage.size.height,
            contentMode: .fit
        )
    }
    
    /// 슬라이더 핸들
    private func sliderHandle(in size: CGSize) -> some View {
        ZStack {
            // 수직선
            Rectangle()
                .fill(.white)
                .frame(width: 3)
                .shadow(color: .black.opacity(0.3), radius: 2)
            
            // 핸들 버튼
            Circle()
                .fill(.white)
                .frame(width: 44, height: 44)
                .shadow(color: .black.opacity(0.3), radius: 4)
                .overlay {
                    HStack(spacing: 2) {
                        Image(systemName: "chevron.left")
                        Image(systemName: "chevron.right")
                    }
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                }
                .scaleEffect(isDragging ? 1.1 : 1.0)
                .animation(.spring(response: 0.3), value: isDragging)
        }
        .position(x: size.width * sliderPosition, y: size.height / 2)
    }
    
    // MARK: - 나란히 비교 모드
    
    private var sideBySideComparison: some View {
        HStack(spacing: 12) {
            // 원본
            VStack {
                Text("원본")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Image(uiImage: originalImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            // 결과
            VStack {
                Text("결과")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Image(uiImage: processedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
    
    // MARK: - 토글 비교 모드
    
    @State private var showOriginal = false
    
    private var toggleComparison: some View {
        VStack(spacing: 16) {
            ZStack {
                Image(uiImage: showOriginal ? originalImage : processedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .animation(.easeInOut(duration: 0.2), value: showOriginal)
            }
            
            // 토글 버튼
            Button {
                showOriginal.toggle()
            } label: {
                Label(
                    showOriginal ? "결과 보기" : "원본 보기",
                    systemImage: "arrow.triangle.2.circlepath"
                )
                .font(.headline)
                .padding()
                .background(.tint, in: Capsule())
                .foregroundStyle(.white)
            }
            
            Text(showOriginal ? "원본 이미지" : "처리된 이미지")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - 이미지 정보
    
    private var imageInfoSection: some View {
        HStack {
            // 원본 정보
            imageInfoCard(
                title: "원본",
                image: originalImage,
                color: .blue
            )
            
            Spacer()
            
            // 결과 정보
            imageInfoCard(
                title: "결과",
                image: processedImage,
                color: .green
            )
        }
        .padding()
        .background(.ultraThinMaterial)
    }
    
    private func imageInfoCard(
        title: String,
        image: UIImage,
        color: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(color)
            
            Text("\(Int(image.size.width)) × \(Int(image.size.height))")
                .font(.caption2)
                .foregroundStyle(.secondary)
            
            Text(image.formattedDataSize)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }
}

// MARK: - 비교 모드 열거형

/// 이미지 비교 표시 모드
enum ComparisonMode: String, CaseIterable, Identifiable {
    case slider = "슬라이더"
    case sideBySide = "나란히"
    case toggle = "전환"
    
    var id: String { rawValue }
}

// MARK: - 슬라이더 클립 셰이프

/// 슬라이더 위치에 따라 이미지를 클리핑하는 Shape
struct SliderClipShape: Shape {
    var position: CGFloat
    
    var animatableData: CGFloat {
        get { position }
        set { position = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRect(CGRect(
            x: 0,
            y: 0,
            width: rect.width * position,
            height: rect.height
        ))
        return path
    }
}

// MARK: - 미리보기

#Preview {
    ComparisonView(
        originalImage: UIImage(systemName: "photo")!,
        processedImage: UIImage(systemName: "photo.fill")!
    )
}
