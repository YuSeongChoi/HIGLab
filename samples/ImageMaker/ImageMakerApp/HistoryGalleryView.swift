import SwiftUI

// MARK: - HistoryGalleryView
// 생성된 이미지 히스토리 갤러리
// 그리드 레이아웃으로 이미지 목록 표시, 필터링 및 검색 지원

/// 히스토리 갤러리 뷰
struct HistoryGalleryView: View {
    
    // MARK: - Environment
    
    @EnvironmentObject private var storageManager: ImageStorageManager
    @EnvironmentObject private var viewModel: ImageMakerViewModel
    
    // MARK: - State
    
    /// 그리드 레이아웃 (2열)
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    /// 선택 모드
    @State private var isSelectionMode = false
    
    /// 선택된 이미지들
    @State private var selectedImages: Set<UUID> = []
    
    /// 삭제 확인 표시
    @State private var showDeleteConfirmation = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Group {
                if storageManager.images.isEmpty {
                    emptyStateView
                } else {
                    galleryContent
                }
            }
            .navigationTitle("갤러리")
            .toolbar {
                toolbarContent
            }
            .searchable(
                text: $viewModel.searchQuery,
                placement: .navigationBarDrawer(displayMode: .automatic),
                prompt: "프롬프트 또는 메모 검색"
            )
            .confirmationDialog(
                "선택한 이미지 삭제",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("삭제 (\(selectedImages.count)개)", role: .destructive) {
                    deleteSelectedImages()
                }
                Button("취소", role: .cancel) {}
            } message: {
                Text("선택한 \(selectedImages.count)개의 이미지를 삭제합니다. 이 작업은 되돌릴 수 없습니다.")
            }
        }
    }
    
    // MARK: - Subviews
    
    /// 빈 상태 뷰
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("아직 이미지가 없어요", systemImage: "photo.stack")
        } description: {
            Text("이미지를 생성하면 여기에 저장됩니다")
        } actions: {
            NavigationLink(destination: ImageGeneratorView()) {
                Text("이미지 만들러 가기")
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    /// 갤러리 콘텐츠
    private var galleryContent: some View {
        VStack(spacing: 0) {
            // 필터 바
            filterBar
            
            // 이미지 그리드
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(viewModel.filteredImages) { image in
                        GalleryImageCard(
                            image: image,
                            isSelectionMode: isSelectionMode,
                            isSelected: selectedImages.contains(image.id)
                        ) {
                            handleImageTap(image)
                        } onLongPress: {
                            enableSelectionMode(with: image)
                        }
                    }
                }
                .padding()
            }
            
            // 선택 모드 액션 바
            if isSelectionMode {
                selectionActionBar
            }
        }
    }
    
    /// 필터 바
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // 즐겨찾기 필터
                FilterChip(
                    title: "즐겨찾기",
                    icon: "heart.fill",
                    isSelected: viewModel.showFavoritesOnly,
                    color: .red
                ) {
                    viewModel.showFavoritesOnly.toggle()
                }
                
                Divider()
                    .frame(height: 24)
                
                // 스타일 필터
                ForEach(ImageStyle.allCases) { style in
                    FilterChip(
                        title: style.displayName,
                        icon: style.iconName,
                        isSelected: viewModel.filterStyle == style,
                        color: style.themeColor
                    ) {
                        viewModel.toggleStyleFilter(style)
                    }
                }
                
                // 필터 초기화
                if viewModel.filterStyle != nil || viewModel.showFavoritesOnly {
                    Button {
                        viewModel.clearFilters()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
    }
    
    /// 선택 모드 액션 바
    private var selectionActionBar: some View {
        HStack(spacing: 20) {
            // 선택 카운트
            Text("\(selectedImages.count)개 선택됨")
                .font(.subheadline)
            
            Spacer()
            
            // 전체 선택/해제
            Button {
                if selectedImages.count == viewModel.filteredImages.count {
                    selectedImages.removeAll()
                } else {
                    selectedImages = Set(viewModel.filteredImages.map { $0.id })
                }
            } label: {
                Text(selectedImages.count == viewModel.filteredImages.count ? "전체 해제" : "전체 선택")
                    .font(.subheadline)
            }
            
            // 삭제 버튼
            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Image(systemName: "trash")
            }
            .disabled(selectedImages.isEmpty)
        }
        .padding()
        .background(.ultraThinMaterial)
    }
    
    /// 툴바 콘텐츠
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            if isSelectionMode {
                Button("완료") {
                    exitSelectionMode()
                }
            } else {
                Menu {
                    // 선택 모드 진입
                    Button {
                        isSelectionMode = true
                    } label: {
                        Label("선택", systemImage: "checkmark.circle")
                    }
                    .disabled(storageManager.images.isEmpty)
                    
                    // 정렬 옵션
                    Menu {
                        Button("최신순") {}
                        Button("오래된순") {}
                        Button("스타일별") {}
                    } label: {
                        Label("정렬", systemImage: "arrow.up.arrow.down")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        
        ToolbarItem(placement: .topBarLeading) {
            if !storageManager.images.isEmpty {
                Text("\(viewModel.filteredImages.count)개")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    // MARK: - Actions
    
    /// 이미지 탭 처리
    private func handleImageTap(_ image: GeneratedImage) {
        if isSelectionMode {
            toggleSelection(image)
        } else {
            viewModel.showImageDetail(image)
        }
    }
    
    /// 선택 토글
    private func toggleSelection(_ image: GeneratedImage) {
        if selectedImages.contains(image.id) {
            selectedImages.remove(image.id)
        } else {
            selectedImages.insert(image.id)
        }
        HapticFeedback.selection()
    }
    
    /// 선택 모드 활성화
    private func enableSelectionMode(with image: GeneratedImage) {
        isSelectionMode = true
        selectedImages.insert(image.id)
        HapticFeedback.medium()
    }
    
    /// 선택 모드 종료
    private func exitSelectionMode() {
        isSelectionMode = false
        selectedImages.removeAll()
    }
    
    /// 선택된 이미지 삭제
    private func deleteSelectedImages() {
        let imagesToDelete = storageManager.images.filter {
            selectedImages.contains($0.id)
        }
        storageManager.deleteImages(imagesToDelete)
        exitSelectionMode()
        HapticFeedback.success()
    }
}

// MARK: - GalleryImageCard
// 갤러리 이미지 카드

/// 갤러리 이미지 카드 뷰
struct GalleryImageCard: View {
    let image: GeneratedImage
    let isSelectionMode: Bool
    let isSelected: Bool
    let onTap: () -> Void
    let onLongPress: () -> Void
    
    @EnvironmentObject private var storageManager: ImageStorageManager
    
    var body: some View {
        Button {
            onTap()
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                // 이미지
                ZStack(alignment: .topTrailing) {
                    storageManager.image(for: image)
                        .resizable()
                        .aspectRatio(1, contentMode: .fill)
                        .clipped()
                    
                    // 선택 인디케이터
                    if isSelectionMode {
                        ZStack {
                            Circle()
                                .fill(isSelected ? Color.accentColor : Color.white.opacity(0.8))
                                .frame(width: 26, height: 26)
                            
                            if isSelected {
                                Image(systemName: "checkmark")
                                    .font(.caption.bold())
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(8)
                    }
                    
                    // 즐겨찾기 표시
                    if image.isFavorite && !isSelectionMode {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.red)
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .padding(8)
                    }
                }
                
                // 정보 영역
                VStack(alignment: .leading, spacing: 4) {
                    // 프롬프트
                    Text(image.shortPrompt)
                        .font(.caption)
                        .lineLimit(2)
                        .foregroundStyle(.primary)
                    
                    // 스타일과 시간
                    HStack(spacing: 4) {
                        Image(systemName: image.style.iconName)
                            .font(.caption2)
                            .foregroundStyle(image.style.themeColor)
                        
                        Text(image.relativeTimeString)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground))
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        isSelected ? Color.accentColor : Color.clear,
                        lineWidth: 3
                    )
            )
        }
        .buttonStyle(.plain)
        .contextMenu {
            contextMenuContent
        }
        .onLongPressGesture {
            onLongPress()
        }
    }
    
    /// 컨텍스트 메뉴
    @ViewBuilder
    private var contextMenuContent: some View {
        Button {
            ImageStorageManager.shared.toggleFavorite(image)
        } label: {
            Label(
                image.isFavorite ? "즐겨찾기 해제" : "즐겨찾기 추가",
                systemImage: image.isFavorite ? "heart.slash" : "heart"
            )
        }
        
        Button {
            Task {
                await ImageStorageManager.shared.saveToPhotoLibrary(image)
            }
        } label: {
            Label("사진 앱에 저장", systemImage: "square.and.arrow.down")
        }
        
        ShareLink(item: storageManager.image(for: image), preview: SharePreview(image.prompt, image: storageManager.image(for: image)))
        
        Divider()
        
        Button(role: .destructive) {
            ImageStorageManager.shared.deleteImage(image)
        } label: {
            Label("삭제", systemImage: "trash")
        }
    }
}

// MARK: - FilterChip
// 필터 칩 버튼

/// 필터 칩 뷰
struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                isSelected ? color.opacity(0.15) : Color(.tertiarySystemBackground)
            )
            .foregroundStyle(isSelected ? color : .secondary)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(isSelected ? color : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    HistoryGalleryView()
        .environmentObject(ImageStorageManager.shared)
        .environmentObject(ImageMakerViewModel())
}
