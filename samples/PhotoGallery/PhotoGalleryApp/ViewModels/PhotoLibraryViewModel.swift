import SwiftUI
import Photos
import Combine

// MARK: - 사진 라이브러리 뷰모델
/// 사진 라이브러리의 전체 상태를 관리하는 메인 뷰모델
/// 에셋 페치, 필터링, 선택 등 갤러리 핵심 기능 담당
@MainActor
final class PhotoLibraryViewModel: ObservableObject {
    
    // MARK: - Published 프로퍼티
    
    /// 전체 에셋 배열
    @Published private(set) var assets: [MediaAsset] = []
    
    /// 현재 표시 중인 에셋 (필터 적용 후)
    @Published private(set) var displayedAssets: [MediaAsset] = []
    
    /// 선택된 에셋들
    @Published var selectedAssets: Set<MediaAsset> = []
    
    /// 현재 필터 타입
    @Published var currentFilter: MediaAsset.FilterType = .all {
        didSet { applyFilter() }
    }
    
    /// 현재 정렬 순서
    @Published var sortOrder: MediaAsset.SortOrder = .newestFirst {
        didSet { sortAssets() }
    }
    
    /// 권한 상태
    @Published private(set) var authorizationStatus: PHAuthorizationStatus = .notDetermined
    
    /// 로딩 상태
    @Published private(set) var isLoading = false
    
    /// 에러 메시지
    @Published var errorMessage: String?
    
    /// 선택 모드 여부
    @Published var isSelectionMode = false
    
    /// 검색 쿼리
    @Published var searchQuery = "" {
        didSet { applyFilter() }
    }
    
    // MARK: - 내부 프로퍼티
    
    /// 사진 라이브러리 서비스
    private let libraryService = PhotoLibraryService.shared
    
    /// 에셋 캐싱 매니저
    private let cachingManager = AssetCachingManager.shared
    
    /// PHFetchResult 저장 (변경 감지용)
    private var fetchResult: PHFetchResult<PHAsset>?
    
    /// 구독 저장
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 초기화
    
    init() {
        setupObservers()
    }
    
    // MARK: - 관찰자 설정
    
    /// 라이브러리 변경 관찰 설정
    private func setupObservers() {
        // 라이브러리 변경 감지
        libraryService.$libraryChangeToken
            .dropFirst()
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                Task {
                    await self?.refreshAssets()
                }
            }
            .store(in: &cancellables)
        
        // 권한 상태 동기화
        libraryService.$authorizationStatus
            .assign(to: &$authorizationStatus)
    }
    
    // MARK: - 권한 요청
    
    /// 사진 라이브러리 접근 권한 요청
    func requestAuthorization() async {
        let granted = await libraryService.requestAuthorization()
        
        if granted {
            await loadInitialAssets()
        }
    }
    
    // MARK: - 에셋 로드
    
    /// 초기 에셋 로드
    func loadInitialAssets() async {
        isLoading = true
        defer { isLoading = false }
        
        let result = libraryService.fetchAllAssets(
            filterType: currentFilter,
            sortOrder: sortOrder
        )
        
        fetchResult = result
        assets = result.toMediaAssets()
        displayedAssets = assets
        
        // 프리페칭 시작 (처음 50개)
        startPrefetching(for: Array(assets.prefix(50)))
    }
    
    /// 에셋 새로고침
    func refreshAssets() async {
        guard authorizationStatus == .authorized || authorizationStatus == .limited else {
            return
        }
        
        let result = libraryService.fetchAllAssets(
            filterType: currentFilter,
            sortOrder: sortOrder
        )
        
        fetchResult = result
        assets = result.toMediaAssets()
        applyFilter()
    }
    
    // MARK: - 필터 및 정렬
    
    /// 현재 필터 적용
    private func applyFilter() {
        var filtered = assets
        
        // 필터 타입 적용
        if currentFilter != .all {
            switch currentFilter {
            case .images:
                filtered = filtered.filter { $0.mediaType == .image }
            case .videos:
                filtered = filtered.filter { $0.mediaType == .video }
            case .livePhotos:
                filtered = filtered.filter { $0.mediaType == .livePhoto }
            case .favorites:
                filtered = filtered.filter { $0.isFavorite }
            case .screenshots:
                filtered = filtered.filter { $0.isScreenshot }
            case .panoramas:
                filtered = filtered.filter { $0.isPanorama }
            case .hdr:
                filtered = filtered.filter { $0.isHDR }
            case .bursts:
                filtered = filtered.filter { $0.isBurst }
            default:
                break
            }
        }
        
        // 검색 쿼리 적용 (파일명 기준)
        if !searchQuery.isEmpty {
            filtered = filtered.filter { asset in
                asset.originalFilename?.localizedCaseInsensitiveContains(searchQuery) ?? false
            }
        }
        
        displayedAssets = filtered
    }
    
    /// 에셋 정렬
    private func sortAssets() {
        Task {
            await refreshAssets()
        }
    }
    
    // MARK: - 프리페칭
    
    /// 에셋 프리페칭 시작
    /// - Parameter mediaAssets: 프리페칭할 에셋 배열
    func startPrefetching(for mediaAssets: [MediaAsset]) {
        let phAssets = mediaAssets.map { $0.asset }
        cachingManager.startCaching(assets: phAssets)
    }
    
    /// 에셋 프리페칭 중지
    /// - Parameter mediaAssets: 프리페칭 중지할 에셋 배열
    func stopPrefetching(for mediaAssets: [MediaAsset]) {
        let phAssets = mediaAssets.map { $0.asset }
        cachingManager.stopCaching(assets: phAssets)
    }
    
    // MARK: - 선택 관리
    
    /// 에셋 선택 토글
    /// - Parameter asset: 대상 에셋
    func toggleSelection(for asset: MediaAsset) {
        if selectedAssets.contains(asset) {
            selectedAssets.remove(asset)
        } else {
            selectedAssets.insert(asset)
        }
    }
    
    /// 모든 에셋 선택
    func selectAll() {
        selectedAssets = Set(displayedAssets)
    }
    
    /// 모든 선택 해제
    func deselectAll() {
        selectedAssets.removeAll()
    }
    
    /// 선택 모드 종료
    func exitSelectionMode() {
        isSelectionMode = false
        selectedAssets.removeAll()
    }
    
    // MARK: - 에셋 작업
    
    /// 선택된 에셋 삭제
    /// - Returns: 성공 여부
    func deleteSelectedAssets() async -> Bool {
        let phAssets = selectedAssets.map { $0.asset }
        let success = await libraryService.deleteAssets(phAssets)
        
        if success {
            await refreshAssets()
            selectedAssets.removeAll()
        }
        
        return success
    }
    
    /// 선택된 에셋 즐겨찾기 설정
    /// - Parameter favorite: 즐겨찾기 여부
    /// - Returns: 성공 여부
    func setFavoriteForSelected(_ favorite: Bool) async -> Bool {
        let phAssets = selectedAssets.map { $0.asset }
        let success = await libraryService.setFavorite(favorite, for: phAssets)
        
        if success {
            await refreshAssets()
        }
        
        return success
    }
    
    /// 단일 에셋 즐겨찾기 토글
    /// - Parameter asset: 대상 에셋
    /// - Returns: 성공 여부
    func toggleFavorite(for asset: MediaAsset) async -> Bool {
        let success = await libraryService.toggleFavorite(for: asset.asset)
        
        if success {
            await refreshAssets()
        }
        
        return success
    }
    
    // MARK: - 페이지네이션
    
    /// 더 많은 에셋 로드 (무한 스크롤)
    /// - Parameter currentAsset: 현재 표시 중인 마지막 에셋
    func loadMoreIfNeeded(currentAsset: MediaAsset) {
        guard let index = displayedAssets.firstIndex(of: currentAsset) else { return }
        
        // 마지막 10개 이내에 도달하면 프리페칭
        let thresholdIndex = displayedAssets.count - 10
        
        if index >= thresholdIndex {
            let remainingAssets = Array(displayedAssets.suffix(from: thresholdIndex))
            startPrefetching(for: remainingAssets)
        }
    }
    
    // MARK: - 에셋 인덱스
    
    /// 특정 에셋의 인덱스
    /// - Parameter asset: 찾을 에셋
    /// - Returns: 인덱스 (없으면 nil)
    func index(of asset: MediaAsset) -> Int? {
        displayedAssets.firstIndex(of: asset)
    }
    
    /// 특정 인덱스의 에셋
    /// - Parameter index: 인덱스
    /// - Returns: 에셋 (범위 밖이면 nil)
    func asset(at index: Int) -> MediaAsset? {
        guard index >= 0 && index < displayedAssets.count else { return nil }
        return displayedAssets[index]
    }
}

// MARK: - 통계 정보
extension PhotoLibraryViewModel {
    
    /// 전체 에셋 개수
    var totalAssetCount: Int {
        assets.count
    }
    
    /// 표시 중인 에셋 개수
    var displayedAssetCount: Int {
        displayedAssets.count
    }
    
    /// 선택된 에셋 개수
    var selectedAssetCount: Int {
        selectedAssets.count
    }
    
    /// 이미지 개수
    var imageCount: Int {
        assets.filter { $0.mediaType == .image }.count
    }
    
    /// 비디오 개수
    var videoCount: Int {
        assets.filter { $0.mediaType == .video }.count
    }
    
    /// 라이브 포토 개수
    var livePhotoCount: Int {
        assets.filter { $0.mediaType == .livePhoto }.count
    }
    
    /// 즐겨찾기 개수
    var favoriteCount: Int {
        assets.filter { $0.isFavorite }.count
    }
}

// MARK: - 공유 기능
extension PhotoLibraryViewModel {
    
    /// 선택된 에셋들의 공유 가능한 아이템 배열 생성
    /// - Returns: 공유 아이템 배열
    func shareItems() async -> [Any] {
        var items: [Any] = []
        
        for mediaAsset in selectedAssets {
            if mediaAsset.mediaType == .video {
                // 비디오는 AVAsset으로 변환
                if let avAsset = await cachingManager.loadAVAsset(for: mediaAsset.asset) {
                    items.append(avAsset)
                }
            } else {
                // 이미지는 UIImage로 변환
                if let image = await cachingManager.loadFullSizeImage(for: mediaAsset.asset) {
                    items.append(image)
                }
            }
        }
        
        return items
    }
}
