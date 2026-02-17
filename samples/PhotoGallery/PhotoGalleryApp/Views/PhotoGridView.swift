import SwiftUI
import Photos

// MARK: - 사진 그리드 뷰
/// LazyVGrid를 사용한 무한 스크롤 사진 그리드
/// PHCachingImageManager를 활용한 프리페칭으로 스크롤 성능 최적화
struct PhotoGridView: View {
    
    // MARK: - 환경 객체
    
    @EnvironmentObject private var viewModel: PhotoLibraryViewModel
    
    // MARK: - 프로퍼티
    
    /// 필터 타입 (외부에서 지정 가능)
    let filterType: MediaAsset.FilterType?
    
    // MARK: - 상태
    
    /// 상세 보기할 에셋
    @State private var selectedAsset: MediaAsset?
    
    /// 상세 보기 표시 여부
    @State private var showDetail = false
    
    /// 정렬/필터 시트 표시 여부
    @State private var showFilterSheet = false
    
    /// 삭제 확인 알림 표시 여부
    @State private var showDeleteConfirmation = false
    
    /// 공유 시트 표시 여부
    @State private var showShareSheet = false
    
    /// 공유할 아이템들
    @State private var shareItems: [Any] = []
    
    // MARK: - 그리드 설정
    
    /// 그리드 컬럼 (반응형)
    private let columns = [
        GridItem(.adaptive(minimum: 100, maximum: 150), spacing: 1)
    ]
    
    /// 썸네일 크기
    private let thumbnailSize = CGSize(width: 200, height: 200)
    
    // MARK: - 초기화
    
    init(filterType: MediaAsset.FilterType? = nil) {
        self.filterType = filterType
    }
    
    // MARK: - 뷰 바디
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading && viewModel.displayedAssets.isEmpty {
                    // 로딩 중
                    loadingView
                } else if viewModel.displayedAssets.isEmpty {
                    // 빈 상태
                    emptyStateView
                } else {
                    // 그리드 콘텐츠
                    gridContent
                }
            }
            .navigationTitle(navigationTitle)
            .toolbar {
                // 필터/정렬 버튼
                ToolbarItem(placement: .topBarLeading) {
                    filterButton
                }
                
                // 선택 모드 버튼
                ToolbarItem(placement: .topBarTrailing) {
                    selectButton
                }
            }
            .toolbar {
                // 선택 모드 툴바
                if viewModel.isSelectionMode {
                    ToolbarItemGroup(placement: .bottomBar) {
                        selectionToolbar
                    }
                }
            }
            .sheet(isPresented: $showFilterSheet) {
                filterSheet
            }
            .fullScreenCover(isPresented: $showDetail) {
                if let asset = selectedAsset {
                    PhotoDetailView(
                        initialAsset: asset,
                        assets: viewModel.displayedAssets
                    )
                }
            }
            .confirmationDialog(
                "선택한 \(viewModel.selectedAssetCount)개 항목을 삭제하시겠습니까?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("삭제", role: .destructive) {
                    Task {
                        await viewModel.deleteSelectedAssets()
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(items: shareItems)
            }
        }
        .onAppear {
            // 외부 필터 적용
            if let filter = filterType {
                viewModel.currentFilter = filter
            }
        }
    }
    
    // MARK: - 네비게이션 타이틀
    
    private var navigationTitle: String {
        if let filter = filterType {
            return filter.rawValue
        }
        return "사진"
    }
    
    // MARK: - 그리드 콘텐츠
    
    /// 메인 그리드 뷰
    private var gridContent: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 1) {
                ForEach(viewModel.displayedAssets) { asset in
                    PhotoThumbnailView(
                        asset: asset,
                        isSelected: viewModel.selectedAssets.contains(asset),
                        isSelectionMode: viewModel.isSelectionMode
                    )
                    .aspectRatio(1, contentMode: .fill)
                    .clipped()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        handleTap(on: asset)
                    }
                    .onLongPressGesture {
                        handleLongPress(on: asset)
                    }
                    .onAppear {
                        // 무한 스크롤 - 프리페칭
                        viewModel.loadMoreIfNeeded(currentAsset: asset)
                    }
                }
            }
        }
    }
    
    // MARK: - 탭 핸들러
    
    /// 탭 제스처 핸들링
    private func handleTap(on asset: MediaAsset) {
        if viewModel.isSelectionMode {
            viewModel.toggleSelection(for: asset)
        } else {
            selectedAsset = asset
            showDetail = true
        }
    }
    
    /// 롱 프레스 제스처 핸들링
    private func handleLongPress(on asset: MediaAsset) {
        if !viewModel.isSelectionMode {
            viewModel.isSelectionMode = true
            viewModel.toggleSelection(for: asset)
        }
    }
    
    // MARK: - 로딩 뷰
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("사진을 불러오는 중...")
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - 빈 상태 뷰
    
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("사진이 없습니다", systemImage: "photo.on.rectangle.angled")
        } description: {
            if filterType != nil {
                Text("선택한 필터에 해당하는 사진이 없습니다")
            } else {
                Text("사진 라이브러리가 비어있습니다")
            }
        }
    }
    
    // MARK: - 필터 버튼
    
    private var filterButton: some View {
        Button {
            showFilterSheet = true
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
        }
    }
    
    // MARK: - 선택 버튼
    
    private var selectButton: some View {
        Button {
            if viewModel.isSelectionMode {
                viewModel.exitSelectionMode()
            } else {
                viewModel.isSelectionMode = true
            }
        } label: {
            Text(viewModel.isSelectionMode ? "취소" : "선택")
        }
    }
    
    // MARK: - 선택 모드 툴바
    
    private var selectionToolbar: some View {
        HStack {
            // 전체 선택
            Button {
                viewModel.selectAll()
            } label: {
                Text("전체 선택")
            }
            .disabled(viewModel.displayedAssetCount == 0)
            
            Spacer()
            
            // 선택 개수 표시
            Text("\(viewModel.selectedAssetCount)개 선택됨")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            // 공유
            Button {
                Task {
                    shareItems = await viewModel.shareItems()
                    showShareSheet = true
                }
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
            .disabled(viewModel.selectedAssetCount == 0)
            
            // 즐겨찾기
            Button {
                Task {
                    await viewModel.setFavoriteForSelected(true)
                }
            } label: {
                Image(systemName: "heart")
            }
            .disabled(viewModel.selectedAssetCount == 0)
            
            // 삭제
            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Image(systemName: "trash")
            }
            .disabled(viewModel.selectedAssetCount == 0)
        }
    }
    
    // MARK: - 필터 시트
    
    private var filterSheet: some View {
        NavigationStack {
            List {
                // 필터 섹션
                Section("필터") {
                    ForEach(MediaAsset.FilterType.allCases, id: \.self) { filter in
                        Button {
                            viewModel.currentFilter = filter
                            showFilterSheet = false
                        } label: {
                            HStack {
                                Image(systemName: filter.iconName)
                                    .foregroundStyle(.primary)
                                Text(filter.rawValue)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if viewModel.currentFilter == filter {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }
                
                // 정렬 섹션
                Section("정렬") {
                    ForEach(MediaAsset.SortOrder.allCases, id: \.self) { order in
                        Button {
                            viewModel.sortOrder = order
                            showFilterSheet = false
                        } label: {
                            HStack {
                                Text(order.rawValue)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if viewModel.sortOrder == order {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("필터 및 정렬")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") {
                        showFilterSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - 공유 시트
/// UIActivityViewController를 SwiftUI로 래핑
struct ShareSheet: UIViewControllerRepresentable {
    
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - 프리뷰
#Preview {
    PhotoGridView()
        .environmentObject(PhotoLibraryViewModel())
}
