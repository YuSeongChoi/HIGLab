import SwiftUI
import Photos

// MARK: - 앨범 목록 뷰
/// 모든 앨범을 섹션별로 표시하는 목록 뷰
/// 스마트 앨범, 사용자 앨범, 공유 앨범 섹션으로 구분
struct AlbumListView: View {
    
    // MARK: - 환경 객체
    
    @EnvironmentObject private var albumViewModel: AlbumViewModel
    @EnvironmentObject private var photoLibraryViewModel: PhotoLibraryViewModel
    
    // MARK: - 상태
    
    /// 새 앨범 생성 시트 표시
    @State private var showCreateAlbum = false
    
    /// 새 앨범 이름
    @State private var newAlbumName = ""
    
    /// 삭제할 앨범
    @State private var albumToDelete: Album?
    
    /// 삭제 확인 표시
    @State private var showDeleteConfirmation = false
    
    // MARK: - 그리드 설정
    
    /// 앨범 그리드 컬럼
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    // MARK: - 뷰 바디
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 24) {
                    ForEach(albumViewModel.albumSections) { section in
                        albumSection(section)
                    }
                }
                .padding()
            }
            .navigationTitle("앨범")
            .toolbar {
                // 새 앨범 만들기 버튼
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCreateAlbum = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert("새 앨범", isPresented: $showCreateAlbum) {
                TextField("앨범 이름", text: $newAlbumName)
                Button("취소", role: .cancel) {
                    newAlbumName = ""
                }
                Button("만들기") {
                    Task {
                        if await albumViewModel.createAlbum(title: newAlbumName) {
                            newAlbumName = ""
                        }
                    }
                }
            }
            .confirmationDialog(
                "'\(albumToDelete?.title ?? "")'을(를) 삭제하시겠습니까?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("삭제", role: .destructive) {
                    if let album = albumToDelete {
                        Task {
                            await albumViewModel.deleteAlbum(album)
                        }
                    }
                }
            } message: {
                Text("앨범만 삭제되며, 사진은 라이브러리에 유지됩니다.")
            }
            .refreshable {
                await albumViewModel.refreshAlbums()
            }
        }
        .task {
            await albumViewModel.loadAlbums()
        }
    }
    
    // MARK: - 앨범 섹션
    
    /// 앨범 섹션 뷰
    private func albumSection(_ section: AlbumSection) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // 섹션 헤더
            HStack {
                if let iconName = section.iconName {
                    Image(systemName: iconName)
                        .foregroundStyle(.secondary)
                }
                
                Text(section.title)
                    .font(.title2.bold())
            }
            
            // 앨범 그리드
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(section.albums) { album in
                    NavigationLink(destination: AlbumDetailView(album: album)) {
                        AlbumCellView(album: album)
                    }
                    .contextMenu {
                        albumContextMenu(for: album)
                    }
                }
            }
        }
    }
    
    // MARK: - 앨범 컨텍스트 메뉴
    
    @ViewBuilder
    private func albumContextMenu(for album: Album) -> some View {
        // 이름 변경 (사용자 앨범만)
        if album.isUserAlbum {
            Button {
                albumViewModel.albumToRename = album
                albumViewModel.newAlbumName = album.title
                albumViewModel.showRenameSheet = true
            } label: {
                Label("이름 변경", systemImage: "pencil")
            }
            
            Button(role: .destructive) {
                albumToDelete = album
                showDeleteConfirmation = true
            } label: {
                Label("삭제", systemImage: "trash")
            }
        }
        
        // 앨범 정보
        Button {
            // 앨범 정보 표시 (추후 구현)
        } label: {
            Label("정보", systemImage: "info.circle")
        }
    }
}

// MARK: - 앨범 셀 뷰
/// 앨범 그리드에서 사용되는 개별 앨범 셀
struct AlbumCellView: View {
    
    // MARK: - 프로퍼티
    
    let album: Album
    
    // MARK: - 상태
    
    /// 커버 이미지
    @State private var coverImage: UIImage?
    
    // MARK: - 뷰 바디
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 커버 이미지
            coverImageView
                .aspectRatio(1, contentMode: .fill)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(color: .black.opacity(0.1), radius: 4)
            
            // 앨범 정보
            VStack(alignment: .leading, spacing: 2) {
                Text(album.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .foregroundStyle(.primary)
                
                Text("\(album.actualAssetCount)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .task {
            await loadCoverImage()
        }
    }
    
    // MARK: - 커버 이미지 뷰
    
    @ViewBuilder
    private var coverImageView: some View {
        if let image = coverImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            // 플레이스홀더
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .overlay {
                    Image(systemName: album.albumType.iconName)
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                }
        }
    }
    
    // MARK: - 커버 이미지 로드
    
    private func loadCoverImage() async {
        guard let coverAsset = album.fetchCoverAsset() else { return }
        coverImage = await AssetCachingManager.shared.loadThumbnail(
            for: coverAsset,
            targetSize: CGSize(width: 300, height: 300)
        )
    }
}

// MARK: - 앨범 상세 뷰
/// 선택된 앨범의 사진들을 그리드로 표시
struct AlbumDetailView: View {
    
    // MARK: - 환경 변수
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var albumViewModel: AlbumViewModel
    
    // MARK: - 프로퍼티
    
    let album: Album
    
    // MARK: - 상태
    
    /// 선택된 에셋
    @State private var selectedAsset: MediaAsset?
    
    /// 상세 뷰 표시
    @State private var showDetail = false
    
    /// 선택 모드
    @State private var isSelectionMode = false
    
    /// 선택된 에셋들
    @State private var selectedAssets: Set<MediaAsset> = []
    
    /// 삭제 확인
    @State private var showDeleteConfirmation = false
    
    // MARK: - 그리드 설정
    
    private let columns = [
        GridItem(.adaptive(minimum: 100, maximum: 150), spacing: 1)
    ]
    
    // MARK: - 뷰 바디
    
    var body: some View {
        ZStack {
            if albumViewModel.isLoading && albumViewModel.selectedAlbumAssets.isEmpty {
                ProgressView()
            } else if albumViewModel.selectedAlbumAssets.isEmpty {
                ContentUnavailableView {
                    Label("사진이 없습니다", systemImage: "photo.on.rectangle.angled")
                } description: {
                    Text("이 앨범에는 아직 사진이 없습니다")
                }
            } else {
                gridContent
            }
        }
        .navigationTitle(album.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // 선택 버튼
            ToolbarItem(placement: .topBarTrailing) {
                Button(isSelectionMode ? "취소" : "선택") {
                    isSelectionMode.toggle()
                    if !isSelectionMode {
                        selectedAssets.removeAll()
                    }
                }
            }
        }
        .toolbar {
            // 선택 모드 툴바
            if isSelectionMode && album.isUserAlbum {
                ToolbarItemGroup(placement: .bottomBar) {
                    selectionToolbar
                }
            }
        }
        .fullScreenCover(isPresented: $showDetail) {
            if let asset = selectedAsset {
                PhotoDetailView(
                    initialAsset: asset,
                    assets: albumViewModel.selectedAlbumAssets
                )
            }
        }
        .confirmationDialog(
            "선택한 \(selectedAssets.count)개 항목을 앨범에서 제거하시겠습니까?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("앨범에서 제거", role: .destructive) {
                Task {
                    await removeSelectedFromAlbum()
                }
            }
        } message: {
            Text("사진은 삭제되지 않고 앨범에서만 제거됩니다.")
        }
        .task {
            await albumViewModel.loadAssets(for: album)
        }
    }
    
    // MARK: - 그리드 콘텐츠
    
    private var gridContent: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 1) {
                ForEach(albumViewModel.selectedAlbumAssets) { asset in
                    PhotoThumbnailView(
                        asset: asset,
                        isSelected: selectedAssets.contains(asset),
                        isSelectionMode: isSelectionMode
                    )
                    .aspectRatio(1, contentMode: .fill)
                    .clipped()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if isSelectionMode {
                            toggleSelection(asset)
                        } else {
                            selectedAsset = asset
                            showDetail = true
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 선택 모드 툴바
    
    private var selectionToolbar: some View {
        HStack {
            Text("\(selectedAssets.count)개 선택됨")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Text("앨범에서 제거")
            }
            .disabled(selectedAssets.isEmpty)
        }
    }
    
    // MARK: - 선택 토글
    
    private func toggleSelection(_ asset: MediaAsset) {
        if selectedAssets.contains(asset) {
            selectedAssets.remove(asset)
        } else {
            selectedAssets.insert(asset)
        }
    }
    
    // MARK: - 앨범에서 제거
    
    private func removeSelectedFromAlbum() async {
        let assets = Array(selectedAssets)
        let success = await albumViewModel.removeAssets(assets, from: album)
        
        if success {
            selectedAssets.removeAll()
            isSelectionMode = false
        }
    }
}

// MARK: - 프리뷰
#Preview {
    AlbumListView()
        .environmentObject(AlbumViewModel())
        .environmentObject(PhotoLibraryViewModel())
}
