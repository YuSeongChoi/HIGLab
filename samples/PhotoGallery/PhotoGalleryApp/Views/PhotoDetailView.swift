import SwiftUI
import Photos
import PhotosUI

// MARK: - 사진 상세 뷰
/// 사진을 전체 화면으로 표시하고 줌, 팬, 스와이프 등 제스처 지원
/// 라이브 포토 재생, 비디오 재생, 편집 기능 연동
struct PhotoDetailView: View {
    
    // MARK: - 환경 변수
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - 프로퍼티
    
    /// 초기 에셋
    let initialAsset: MediaAsset
    
    /// 전체 에셋 배열 (스와이프 네비게이션용)
    let assets: [MediaAsset]
    
    // MARK: - 상태
    
    /// 현재 표시 중인 인덱스
    @State private var currentIndex: Int = 0
    
    /// UI 표시 여부
    @State private var showUI = true
    
    /// 삭제 확인 알림
    @State private var showDeleteConfirmation = false
    
    /// 편집 화면 표시
    @State private var showEditor = false
    
    /// 공유 시트 표시
    @State private var showShareSheet = false
    
    /// 공유할 아이템
    @State private var shareItems: [Any] = []
    
    /// 정보 시트 표시
    @State private var showInfo = false
    
    /// 앨범 추가 시트 표시
    @State private var showAddToAlbum = false
    
    // MARK: - 뷰 바디
    
    var body: some View {
        ZStack {
            // 배경
            Color.black.ignoresSafeArea()
            
            // 페이지 뷰
            TabView(selection: $currentIndex) {
                ForEach(Array(assets.enumerated()), id: \.element.id) { index, asset in
                    MediaContentView(asset: asset, showUI: $showUI)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
            
            // UI 오버레이
            if showUI {
                overlayUI
            }
        }
        .statusBarHidden(!showUI)
        .onAppear {
            // 초기 인덱스 설정
            if let index = assets.firstIndex(of: initialAsset) {
                currentIndex = index
            }
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                showUI.toggle()
            }
        }
        .gesture(dismissGesture)
        .confirmationDialog(
            "이 항목을 삭제하시겠습니까?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("삭제", role: .destructive) {
                Task {
                    await deleteCurrentAsset()
                }
            }
        }
        .fullScreenCover(isPresented: $showEditor) {
            if let asset = currentAsset {
                PhotoEditorView(asset: asset)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: shareItems)
        }
        .sheet(isPresented: $showInfo) {
            if let asset = currentAsset {
                AssetInfoSheet(asset: asset)
            }
        }
        .sheet(isPresented: $showAddToAlbum) {
            if let asset = currentAsset {
                AddToAlbumSheet(assets: [asset])
            }
        }
    }
    
    // MARK: - 현재 에셋
    
    /// 현재 표시 중인 에셋
    private var currentAsset: MediaAsset? {
        guard currentIndex >= 0 && currentIndex < assets.count else { return nil }
        return assets[currentIndex]
    }
    
    // MARK: - UI 오버레이
    
    /// 상단/하단 UI 오버레이
    private var overlayUI: some View {
        VStack(spacing: 0) {
            // 상단 바
            topBar
            
            Spacer()
            
            // 하단 바
            bottomBar
        }
    }
    
    // MARK: - 상단 바
    
    private var topBar: some View {
        HStack {
            // 닫기 버튼
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .padding()
            }
            
            Spacer()
            
            // 현재 위치
            Text("\(currentIndex + 1) / \(assets.count)")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
            
            Spacer()
            
            // 편집 버튼 (이미지만)
            if currentAsset?.mediaType != .video {
                Button {
                    showEditor = true
                } label: {
                    Text("편집")
                        .foregroundStyle(.white)
                        .padding()
                }
            } else {
                // 공간 유지용
                Color.clear
                    .frame(width: 60)
            }
        }
        .background(
            LinearGradient(
                colors: [.black.opacity(0.6), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .top)
        )
    }
    
    // MARK: - 하단 바
    
    private var bottomBar: some View {
        VStack(spacing: 0) {
            // 에셋 정보
            if let asset = currentAsset {
                HStack {
                    // 미디어 타입 아이콘
                    Image(systemName: asset.mediaType.iconName)
                    
                    // 날짜
                    if let date = asset.creationDate {
                        Text(date.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                    }
                    
                    Spacer()
                    
                    // 즐겨찾기 상태
                    if asset.isFavorite {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.red)
                    }
                }
                .foregroundStyle(.white.opacity(0.8))
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            
            // 액션 버튼들
            HStack(spacing: 32) {
                // 공유
                actionButton(icon: "square.and.arrow.up", label: "공유") {
                    Task {
                        await prepareShareItems()
                        showShareSheet = true
                    }
                }
                
                // 즐겨찾기
                actionButton(
                    icon: currentAsset?.isFavorite == true ? "heart.fill" : "heart",
                    label: "즐겨찾기",
                    tint: currentAsset?.isFavorite == true ? .red : .white
                ) {
                    Task {
                        await toggleFavorite()
                    }
                }
                
                // 정보
                actionButton(icon: "info.circle", label: "정보") {
                    showInfo = true
                }
                
                // 앨범에 추가
                actionButton(icon: "rectangle.stack.badge.plus", label: "앨범") {
                    showAddToAlbum = true
                }
                
                // 삭제
                actionButton(icon: "trash", label: "삭제", tint: .red) {
                    showDeleteConfirmation = true
                }
            }
            .padding(.vertical, 12)
        }
        .background(
            LinearGradient(
                colors: [.clear, .black.opacity(0.6)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .bottom)
        )
    }
    
    // MARK: - 액션 버튼
    
    private func actionButton(
        icon: String,
        label: String,
        tint: Color = .white,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title2)
                Text(label)
                    .font(.caption2)
            }
            .foregroundStyle(tint)
        }
    }
    
    // MARK: - 닫기 제스처
    
    private var dismissGesture: some Gesture {
        DragGesture()
            .onEnded { value in
                // 아래로 100pt 이상 스와이프하면 닫기
                if value.translation.height > 100 {
                    dismiss()
                }
            }
    }
    
    // MARK: - 액션
    
    /// 현재 에셋 삭제
    private func deleteCurrentAsset() async {
        guard let asset = currentAsset else { return }
        
        let success = await PhotoLibraryService.shared.deleteAsset(asset.asset)
        
        if success {
            // 마지막 에셋이면 닫기
            if assets.count <= 1 {
                dismiss()
            }
        }
    }
    
    /// 즐겨찾기 토글
    private func toggleFavorite() async {
        guard let asset = currentAsset else { return }
        await PhotoLibraryService.shared.toggleFavorite(for: asset.asset)
    }
    
    /// 공유 아이템 준비
    private func prepareShareItems() async {
        guard let asset = currentAsset else { return }
        
        if asset.mediaType == .video {
            if let avAsset = await AssetCachingManager.shared.loadAVAsset(for: asset.asset) {
                shareItems = [avAsset]
            }
        } else {
            if let image = await AssetCachingManager.shared.loadFullSizeImage(for: asset.asset) {
                shareItems = [image]
            }
        }
    }
}

// MARK: - 미디어 콘텐츠 뷰
/// 미디어 타입에 따라 적절한 뷰어 표시
struct MediaContentView: View {
    
    let asset: MediaAsset
    @Binding var showUI: Bool
    
    // MARK: - 상태
    
    @State private var image: UIImage?
    @State private var livePhoto: PHLivePhoto?
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            switch asset.mediaType {
            case .image:
                ZoomableImageView(image: image)
                
            case .livePhoto:
                if let livePhoto = livePhoto {
                    LivePhotoView(livePhoto: livePhoto)
                } else if let image = image {
                    ZoomableImageView(image: image)
                }
                
            case .video:
                VideoPlayerView(asset: asset.asset)
                
            case .unknown:
                ContentUnavailableView(
                    "표시할 수 없음",
                    systemImage: "exclamationmark.triangle"
                )
            }
            
            if isLoading && asset.mediaType != .video {
                ProgressView()
            }
        }
        .task {
            await loadMedia()
        }
    }
    
    /// 미디어 로드
    private func loadMedia() async {
        isLoading = true
        defer { isLoading = false }
        
        switch asset.mediaType {
        case .livePhoto:
            // 라이브 포토와 스틸 이미지 동시 로드
            async let livePhotoTask = AssetCachingManager.shared.loadLivePhoto(for: asset.asset)
            async let imageTask = AssetCachingManager.shared.loadFullSizeImage(for: asset.asset)
            
            livePhoto = await livePhotoTask
            image = await imageTask
            
        case .image:
            image = await AssetCachingManager.shared.loadFullSizeImage(for: asset.asset)
            
        default:
            break
        }
    }
}

// MARK: - 줌 가능 이미지 뷰
/// 핀치 줌과 팬 제스처를 지원하는 이미지 뷰
struct ZoomableImageView: View {
    
    let image: UIImage?
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(scale)
                    .offset(offset)
                    .gesture(magnificationGesture)
                    .gesture(dragGesture)
                    .onTapGesture(count: 2) {
                        // 더블 탭으로 확대/축소
                        withAnimation(.spring()) {
                            if scale > 1 {
                                scale = 1
                                offset = .zero
                            } else {
                                scale = 2
                            }
                            lastScale = scale
                            lastOffset = offset
                        }
                    }
            }
        }
    }
    
    /// 확대/축소 제스처
    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let delta = value / lastScale
                lastScale = value
                scale = max(1, min(scale * delta, 5))
            }
            .onEnded { _ in
                lastScale = 1
                
                // 1배 이하로 축소되면 리셋
                if scale < 1.1 {
                    withAnimation(.spring()) {
                        scale = 1
                        offset = .zero
                        lastOffset = .zero
                    }
                }
            }
    }
    
    /// 드래그 제스처
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if scale > 1 {
                    offset = CGSize(
                        width: lastOffset.width + value.translation.width,
                        height: lastOffset.height + value.translation.height
                    )
                }
            }
            .onEnded { _ in
                lastOffset = offset
                
                // 1배 상태에서는 오프셋 리셋
                if scale <= 1 {
                    withAnimation(.spring()) {
                        offset = .zero
                        lastOffset = .zero
                    }
                }
            }
    }
}

// MARK: - 에셋 정보 시트
/// 에셋의 상세 메타데이터 표시
struct AssetInfoSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let asset: MediaAsset
    
    var body: some View {
        NavigationStack {
            List {
                // 기본 정보
                Section("기본 정보") {
                    infoRow("타입", value: asset.mediaType.rawValue)
                    infoRow("해상도", value: asset.resolutionString)
                    
                    if let filename = asset.originalFilename {
                        infoRow("파일명", value: filename)
                    }
                    
                    if asset.mediaType == .video, let duration = asset.formattedDuration {
                        infoRow("길이", value: duration)
                    }
                }
                
                // 날짜 정보
                Section("날짜") {
                    if let date = asset.creationDate {
                        infoRow("촬영 날짜", value: date.formatted())
                    }
                    
                    if let date = asset.modificationDate {
                        infoRow("수정 날짜", value: date.formatted())
                    }
                }
                
                // 위치 정보
                if let location = asset.location {
                    Section("위치") {
                        infoRow("위도", value: String(format: "%.6f", location.coordinate.latitude))
                        infoRow("경도", value: String(format: "%.6f", location.coordinate.longitude))
                    }
                }
                
                // 추가 속성
                Section("속성") {
                    if asset.isFavorite { attributeRow("즐겨찾기") }
                    if asset.isHDR { attributeRow("HDR") }
                    if asset.isPanorama { attributeRow("파노라마") }
                    if asset.isScreenshot { attributeRow("스크린샷") }
                    if asset.isBurst { attributeRow("버스트") }
                    if asset.isSlowMotion { attributeRow("슬로모션") }
                    if asset.isTimelapse { attributeRow("타임랩스") }
                }
            }
            .navigationTitle("정보")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    private func infoRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
        }
    }
    
    private func attributeRow(_ label: String) -> some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text(label)
        }
    }
}

// MARK: - 앨범 추가 시트
/// 선택한 에셋을 앨범에 추가하는 시트
struct AddToAlbumSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var albumViewModel: AlbumViewModel
    
    let assets: [MediaAsset]
    
    @State private var showCreateAlbum = false
    @State private var newAlbumName = ""
    
    var body: some View {
        NavigationStack {
            List {
                // 새 앨범 만들기
                Section {
                    Button {
                        showCreateAlbum = true
                    } label: {
                        Label("새 앨범 만들기", systemImage: "plus.rectangle.on.folder")
                    }
                }
                
                // 기존 앨범 목록
                ForEach(albumViewModel.albumSections) { section in
                    Section(section.title) {
                        ForEach(section.albums.filter { $0.isUserAlbum }) { album in
                            Button {
                                Task {
                                    await addToAlbum(album)
                                }
                            } label: {
                                HStack {
                                    Image(systemName: album.albumType.iconName)
                                        .frame(width: 30)
                                    Text(album.title)
                                    Spacer()
                                    Text("\(album.actualAssetCount)")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .foregroundStyle(.primary)
                        }
                    }
                }
            }
            .navigationTitle("앨범에 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
            }
            .alert("새 앨범", isPresented: $showCreateAlbum) {
                TextField("앨범 이름", text: $newAlbumName)
                Button("취소", role: .cancel) {}
                Button("만들기") {
                    Task {
                        if await albumViewModel.createAlbum(title: newAlbumName) {
                            newAlbumName = ""
                        }
                    }
                }
            }
        }
        .task {
            await albumViewModel.loadAlbums()
        }
    }
    
    private func addToAlbum(_ album: Album) async {
        let success = await albumViewModel.addAssets(assets, to: album)
        if success {
            dismiss()
        }
    }
}

// MARK: - 프리뷰
#Preview {
    Text("상세 뷰 프리뷰")
}
