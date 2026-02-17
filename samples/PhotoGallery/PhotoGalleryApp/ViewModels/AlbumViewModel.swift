import SwiftUI
import Photos
import Combine

// MARK: - 앨범 뷰모델
/// 앨범 목록 및 개별 앨범 관리를 담당하는 뷰모델
/// 앨범 생성, 삭제, 이름 변경 등 앨범 관련 모든 작업 처리
@MainActor
final class AlbumViewModel: ObservableObject {
    
    // MARK: - Published 프로퍼티
    
    /// 앨범 섹션 배열 (스마트 앨범, 사용자 앨범, 공유 앨범)
    @Published private(set) var albumSections: [AlbumSection] = []
    
    /// 현재 선택된 앨범
    @Published var selectedAlbum: Album?
    
    /// 선택된 앨범의 에셋들
    @Published private(set) var selectedAlbumAssets: [MediaAsset] = []
    
    /// 로딩 상태
    @Published private(set) var isLoading = false
    
    /// 에러 메시지
    @Published var errorMessage: String?
    
    /// 새 앨범 이름 (생성용)
    @Published var newAlbumName = ""
    
    /// 앨범 생성 시트 표시 여부
    @Published var showCreateAlbumSheet = false
    
    /// 앨범 이름 변경 시트 표시 여부
    @Published var showRenameSheet = false
    
    /// 이름 변경할 앨범
    @Published var albumToRename: Album?
    
    // MARK: - 내부 프로퍼티
    
    /// 사진 라이브러리 서비스
    private let libraryService = PhotoLibraryService.shared
    
    /// 에셋 캐싱 매니저
    private let cachingManager = AssetCachingManager.shared
    
    /// 구독 저장
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 초기화
    
    init() {
        setupObservers()
    }
    
    // MARK: - 관찰자 설정
    
    private func setupObservers() {
        // 라이브러리 변경 감지
        libraryService.$libraryChangeToken
            .dropFirst()
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                Task {
                    await self?.refreshAlbums()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - 앨범 로드
    
    /// 전체 앨범 목록 로드
    func loadAlbums() async {
        isLoading = true
        defer { isLoading = false }
        
        albumSections = libraryService.fetchAllAlbumSections()
    }
    
    /// 앨범 목록 새로고침
    func refreshAlbums() async {
        albumSections = libraryService.fetchAllAlbumSections()
        
        // 선택된 앨범이 있으면 에셋도 새로고침
        if let album = selectedAlbum {
            await loadAssets(for: album)
        }
    }
    
    /// 특정 앨범의 에셋 로드
    /// - Parameter album: 대상 앨범
    func loadAssets(for album: Album) async {
        isLoading = true
        defer { isLoading = false }
        
        selectedAlbum = album
        selectedAlbumAssets = album.fetchMediaAssets()
        
        // 프리페칭 시작
        let phAssets = selectedAlbumAssets.prefix(50).map { $0.asset }
        cachingManager.startCaching(assets: Array(phAssets))
    }
    
    // MARK: - 앨범 생성
    
    /// 새 앨범 생성
    /// - Parameter title: 앨범 제목
    /// - Returns: 성공 여부
    func createAlbum(title: String) async -> Bool {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "앨범 이름을 입력해주세요"
            return false
        }
        
        isLoading = true
        defer { isLoading = false }
        
        let localIdentifier = await libraryService.createAlbum(title: title)
        
        if localIdentifier != nil {
            await refreshAlbums()
            newAlbumName = ""
            return true
        } else {
            errorMessage = "앨범 생성에 실패했습니다"
            return false
        }
    }
    
    // MARK: - 앨범 삭제
    
    /// 앨범 삭제
    /// - Parameter album: 삭제할 앨범
    /// - Returns: 성공 여부
    func deleteAlbum(_ album: Album) async -> Bool {
        // 스마트 앨범은 삭제 불가
        guard album.isUserAlbum else {
            errorMessage = "시스템 앨범은 삭제할 수 없습니다"
            return false
        }
        
        isLoading = true
        defer { isLoading = false }
        
        let success = await libraryService.deleteAlbum(album.collection)
        
        if success {
            if selectedAlbum == album {
                selectedAlbum = nil
                selectedAlbumAssets = []
            }
            await refreshAlbums()
        } else {
            errorMessage = "앨범 삭제에 실패했습니다"
        }
        
        return success
    }
    
    // MARK: - 앨범 이름 변경
    
    /// 앨범 이름 변경
    /// - Parameters:
    ///   - album: 대상 앨범
    ///   - newTitle: 새 제목
    /// - Returns: 성공 여부
    func renameAlbum(_ album: Album, to newTitle: String) async -> Bool {
        guard !newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "앨범 이름을 입력해주세요"
            return false
        }
        
        // 사용자 앨범만 이름 변경 가능
        guard album.isUserAlbum else {
            errorMessage = "시스템 앨범의 이름은 변경할 수 없습니다"
            return false
        }
        
        isLoading = true
        defer { isLoading = false }
        
        let success = await libraryService.renameAlbum(album.collection, to: newTitle)
        
        if success {
            await refreshAlbums()
        } else {
            errorMessage = "앨범 이름 변경에 실패했습니다"
        }
        
        return success
    }
    
    // MARK: - 에셋 관리
    
    /// 앨범에 에셋 추가
    /// - Parameters:
    ///   - assets: 추가할 에셋들
    ///   - album: 대상 앨범
    /// - Returns: 성공 여부
    func addAssets(_ assets: [MediaAsset], to album: Album) async -> Bool {
        guard album.isUserAlbum else {
            errorMessage = "시스템 앨범에는 사진을 추가할 수 없습니다"
            return false
        }
        
        isLoading = true
        defer { isLoading = false }
        
        let phAssets = assets.map { $0.asset }
        let success = await libraryService.addAssets(phAssets, to: album.collection)
        
        if success {
            if selectedAlbum == album {
                await loadAssets(for: album)
            }
        } else {
            errorMessage = "사진 추가에 실패했습니다"
        }
        
        return success
    }
    
    /// 앨범에서 에셋 제거
    /// - Parameters:
    ///   - assets: 제거할 에셋들
    ///   - album: 대상 앨범
    /// - Returns: 성공 여부
    func removeAssets(_ assets: [MediaAsset], from album: Album) async -> Bool {
        guard album.isUserAlbum else {
            errorMessage = "시스템 앨범에서는 사진을 제거할 수 없습니다"
            return false
        }
        
        isLoading = true
        defer { isLoading = false }
        
        let phAssets = assets.map { $0.asset }
        let success = await libraryService.removeAssets(phAssets, from: album.collection)
        
        if success {
            if selectedAlbum == album {
                await loadAssets(for: album)
            }
        } else {
            errorMessage = "사진 제거에 실패했습니다"
        }
        
        return success
    }
    
    // MARK: - 커버 이미지
    
    /// 앨범 커버 이미지 로드
    /// - Parameter album: 대상 앨범
    /// - Returns: UIImage (없으면 nil)
    func loadCoverImage(for album: Album) async -> UIImage? {
        guard let coverAsset = album.fetchCoverAsset() else { return nil }
        return await cachingManager.loadThumbnail(for: coverAsset)
    }
}

// MARK: - 스마트 앨범 헬퍼
extension AlbumViewModel {
    
    /// 카메라 롤 앨범 가져오기
    var cameraRollAlbum: Album? {
        albumSections
            .flatMap { $0.albums }
            .first { $0.albumType == .cameraRoll }
    }
    
    /// 즐겨찾기 앨범 가져오기
    var favoritesAlbum: Album? {
        albumSections
            .flatMap { $0.albums }
            .first { $0.albumType == .favorites }
    }
    
    /// 최근 추가된 항목 앨범 가져오기
    var recentlyAddedAlbum: Album? {
        albumSections
            .flatMap { $0.albums }
            .first { $0.albumType == .recentlyAdded }
    }
    
    /// 비디오 앨범 가져오기
    var videosAlbum: Album? {
        albumSections
            .flatMap { $0.albums }
            .first { $0.albumType == .videos }
    }
    
    /// 스크린샷 앨범 가져오기
    var screenshotsAlbum: Album? {
        albumSections
            .flatMap { $0.albums }
            .first { $0.albumType == .screenshots }
    }
}

// MARK: - 통계 정보
extension AlbumViewModel {
    
    /// 전체 앨범 개수
    var totalAlbumCount: Int {
        albumSections.reduce(0) { $0 + $1.albums.count }
    }
    
    /// 사용자 앨범 개수
    var userAlbumCount: Int {
        albumSections
            .flatMap { $0.albums }
            .filter { $0.isUserAlbum }
            .count
    }
    
    /// 스마트 앨범 개수
    var smartAlbumCount: Int {
        albumSections
            .flatMap { $0.albums }
            .filter { $0.isSmartAlbum }
            .count
    }
}
