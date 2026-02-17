// FilterThumbnailView.swift
// FilterLab - 필터 썸네일 프리뷰 뷰
// HIG Lab 샘플 프로젝트

import SwiftUI

// MARK: - 필터 썸네일 뷰
/// 각 필터의 효과를 미리 보여주는 썸네일
struct FilterThumbnailView: View {
    let filterType: FilterType
    let sourceImage: UIImage?
    let size: CGSize
    let isSelected: Bool
    let onTap: () -> Void
    
    @State private var thumbnailImage: UIImage?
    @State private var isLoading: Bool = true
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // 썸네일 이미지
                ZStack {
                    if let thumbnail = thumbnailImage {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                            .clipped()
                    } else if isLoading {
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .frame(width: size.width, height: size.height)
                            .overlay {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                    } else {
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .frame(width: size.width, height: size.height)
                            .overlay {
                                Image(systemName: filterType.category.icon)
                                    .foregroundStyle(.secondary)
                            }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(
                            isSelected ? Color.accentColor : Color.clear,
                            lineWidth: 3
                        )
                }
                .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                
                // 필터 이름
                Text(filterType.rawValue)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundStyle(isSelected ? .accentColor : .primary)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
        .task(id: sourceImage) {
            await generateThumbnail()
        }
    }
    
    // MARK: - 썸네일 생성
    private func generateThumbnail() async {
        guard let sourceImage = sourceImage else {
            isLoading = false
            return
        }
        
        isLoading = true
        
        let processor = ImageProcessor()
        
        // 백그라운드에서 썸네일 생성
        let thumbnail = await Task.detached(priority: .utility) {
            processor.previewFilter(filterType, on: sourceImage, size: size)
        }.value
        
        await MainActor.run {
            thumbnailImage = thumbnail
            isLoading = false
        }
    }
}

// MARK: - 필터 썸네일 그리드
/// 카테고리별 필터 썸네일을 그리드로 표시
struct FilterThumbnailGrid: View {
    let sourceImage: UIImage?
    let category: FilterCategory
    let selectedFilter: FilterType?
    let onSelect: (FilterType) -> Void
    
    private let columns = [
        GridItem(.adaptive(minimum: 80), spacing: 12)
    ]
    
    private var filters: [FilterType] {
        FilterType.allCases.filter { $0.category == category }
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(filters) { filterType in
                    FilterThumbnailView(
                        filterType: filterType,
                        sourceImage: sourceImage,
                        size: CGSize(width: 80, height: 80),
                        isSelected: selectedFilter == filterType
                    ) {
                        onSelect(filterType)
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - 필터 캐러셀
/// 필터를 가로로 스크롤하는 캐러셀
struct FilterCarousel: View {
    let sourceImage: UIImage?
    let filters: [FilterType]
    let selectedFilter: FilterType?
    let onSelect: (FilterType) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // 원본 옵션
                OriginalThumbnail(
                    sourceImage: sourceImage,
                    size: CGSize(width: 70, height: 70),
                    isSelected: selectedFilter == nil
                ) {
                    // 원본 선택 시 처리
                }
                
                // 필터 옵션들
                ForEach(filters) { filterType in
                    FilterThumbnailView(
                        filterType: filterType,
                        sourceImage: sourceImage,
                        size: CGSize(width: 70, height: 70),
                        isSelected: selectedFilter == filterType
                    ) {
                        onSelect(filterType)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - 원본 썸네일
struct OriginalThumbnail: View {
    let sourceImage: UIImage?
    let size: CGSize
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    if let sourceImage = sourceImage {
                        Image(uiImage: sourceImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                            .clipped()
                    } else {
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .frame(width: size.width, height: size.height)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(
                            isSelected ? Color.accentColor : Color.clear,
                            lineWidth: 3
                        )
                }
                .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                
                Text("원본")
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundStyle(isSelected ? .accentColor : .primary)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 비교 슬라이더 뷰
/// 원본과 필터 적용 이미지를 좌우로 비교
struct CompareSliderView: View {
    let originalImage: UIImage?
    let filteredImage: UIImage?
    
    @State private var sliderPosition: CGFloat = 0.5
    @GestureState private var isDragging: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 필터 적용 이미지 (오른쪽)
                if let filteredImage = filteredImage {
                    Image(uiImage: filteredImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                
                // 원본 이미지 (왼쪽, 마스크 적용)
                if let originalImage = originalImage {
                    Image(uiImage: originalImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .mask(
                            HStack(spacing: 0) {
                                Rectangle()
                                    .frame(width: geometry.size.width * sliderPosition)
                                Spacer(minLength: 0)
                            }
                        )
                }
                
                // 슬라이더 핸들
                SliderHandle(position: sliderPosition, height: geometry.size.height)
                    .gesture(
                        DragGesture()
                            .updating($isDragging) { _, state, _ in
                                state = true
                            }
                            .onChanged { value in
                                let newPosition = value.location.x / geometry.size.width
                                sliderPosition = min(max(newPosition, 0.05), 0.95)
                            }
                    )
                
                // 레이블
                VStack {
                    HStack {
                        Text("원본")
                            .labelStyle()
                            .opacity(sliderPosition > 0.15 ? 1 : 0)
                        
                        Spacer()
                        
                        Text("필터")
                            .labelStyle()
                            .opacity(sliderPosition < 0.85 ? 1 : 0)
                    }
                    .padding()
                    
                    Spacer()
                }
            }
        }
    }
}

// MARK: - 슬라이더 핸들
struct SliderHandle: View {
    let position: CGFloat
    let height: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 세로선
                Rectangle()
                    .fill(.white)
                    .frame(width: 2, height: height)
                    .shadow(color: .black.opacity(0.3), radius: 2)
                
                // 핸들
                Circle()
                    .fill(.white)
                    .frame(width: 40, height: 40)
                    .shadow(color: .black.opacity(0.3), radius: 4)
                    .overlay {
                        HStack(spacing: 2) {
                            Image(systemName: "chevron.left")
                            Image(systemName: "chevron.right")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
            }
            .position(
                x: geometry.size.width * position,
                y: geometry.size.height / 2
            )
        }
    }
}

// MARK: - 레이블 스타일
extension Text {
    func labelStyle() -> some View {
        self
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
    }
}

// MARK: - 프리뷰
#Preview("Filter Thumbnail Grid") {
    FilterThumbnailGrid(
        sourceImage: UIImage(systemName: "photo"),
        category: .color,
        selectedFilter: .sepiaTone
    ) { _ in }
}

#Preview("Compare Slider") {
    CompareSliderView(
        originalImage: UIImage(systemName: "photo"),
        filteredImage: UIImage(systemName: "photo.fill")
    )
    .frame(height: 300)
}
