import Photos
import UIKit
import Combine

// MARK: - 사진 라이브러리 서비스
/// PHPhotoLibrary를 래핑하여 사진/비디오 관리 기능 제공
/// 권한 관리, 에셋 페치, CRUD 작업 등을 처리
@MainActor
final class PhotoLibraryService: NSObject, ObservableObject {
    
    // MARK: - 싱글톤
    
    static let shared = PhotoLibraryService()
    
    // MARK: - Published 프로퍼티
    
    /// 현재 권한 상태
    @Published private(set) var authorizationStatus: PHAuthorizationStatus = .notDetermined
    
    /// 라이브러리 변경 알림
    @Published private(set) var libraryChangeToken: UUID = UUID()
    
    // MARK: - 내부 프로퍼티
    
    /// PHPhotoLibrary 인스턴스
    private let photoLibrary = PHPhotoLibrary.shared()
    
    /// 변경 관찰자 토큰
    private var changeObserver: NSObjectProtocol?
    
    // MARK: - 초기화
    
    override init() {
        super.init()
        
        // 현재 권한 상태 확인
        authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        // 라이브러리 변경 관찰 등록
        photoLibrary.register(self)
    }
    
    deinit {
        photoLibrary.unregisterChangeObserver(self)
    }
    
    // MARK: - 권한 관리
    
    /// 사진 라이브러리 접근 권한 요청
    /// - Returns: 권한 승인 여부
    @discardableResult
    func requestAuthorization() async -> Bool {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        
        await MainActor.run {
            self.authorizationStatus = status
        }
        
        return status == .authorized || status == .limited
    }
    
    /// 권한 상태가 제한된 경우 추가 사진 선택
    func presentLimitedLibraryPicker(from viewController: UIViewController) {
        guard authorizationStatus == .limited else { return }
        PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: viewController)
    }
    
    /// 권한 상태 확인
    var hasFullAccess: Bool {
        authorizationStatus == .authorized
    }
    
    /// 제한된 권한인지 확인
    var hasLimitedAccess: Bool {
        authorizationStatus == .limited
    }
    
    /// 권한 거부 여부
    var isAccessDenied: Bool {
        authorizationStatus == .denied || authorizationStatus == .restricted
    }
    
    // MARK: - 에셋 페치
    
    /// 모든 에셋 페치
    /// - Parameters:
    ///   - filterType: 필터 타입
    ///   - sortOrder: 정렬 순서
    /// - Returns: PHFetchResult<PHAsset>
    func fetchAllAssets(
        filterType: MediaAsset.FilterType = .all,
        sortOrder: MediaAsset.SortOrder = .newestFirst
    ) -> PHFetchResult<PHAsset> {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = sortOrder.sortDescriptors
        fetchOptions.predicate = filterType.predicate
        
        return PHAsset.fetchAssets(with: fetchOptions)
    }
    
    /// 최근 사진 페치 (지정된 개수)
    /// - Parameters:
    ///   - count: 페치할 사진 개수
    ///   - mediaType: 미디어 타입 (nil이면 전체)
    /// - Returns: PHFetchResult<PHAsset>
    func fetchRecentAssets(
        count: Int,
        mediaType: PHAssetMediaType? = nil
    ) -> PHFetchResult<PHAsset> {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = count
        
        if let mediaType = mediaType {
            fetchOptions.predicate = NSPredicate(format: "mediaType == %d", mediaType.rawValue)
        }
        
        return PHAsset.fetchAssets(with: fetchOptions)
    }
    
    /// 특정 날짜 범위의 에셋 페치
    /// - Parameters:
    ///   - startDate: 시작 날짜
    ///   - endDate: 종료 날짜
    /// - Returns: PHFetchResult<PHAsset>
    func fetchAssets(from startDate: Date, to endDate: Date) -> PHFetchResult<PHAsset> {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(
            format: "creationDate >= %@ AND creationDate <= %@",
            startDate as NSDate,
            endDate as NSDate
        )
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        return PHAsset.fetchAssets(with: fetchOptions)
    }
    
    /// localIdentifier로 에셋 페치
    /// - Parameter identifiers: localIdentifier 배열
    /// - Returns: PHFetchResult<PHAsset>
    func fetchAssets(with identifiers: [String]) -> PHFetchResult<PHAsset> {
        PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)
    }
    
    /// 특정 에셋 페치
    /// - Parameter identifier: localIdentifier
    /// - Returns: PHAsset (없으면 nil)
    func fetchAsset(with identifier: String) -> PHAsset? {
        let result = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
        return result.firstObject
    }
    
    // MARK: - 즐겨찾기
    
    /// 즐겨찾기 토글
    /// - Parameter asset: 대상 에셋
    /// - Returns: 성공 여부
    func toggleFavorite(for asset: PHAsset) async -> Bool {
        do {
            try await photoLibrary.performChanges {
                let request = PHAssetChangeRequest(for: asset)
                request.isFavorite = !asset.isFavorite
            }
            return true
        } catch {
            print("즐겨찾기 토글 실패: \(error.localizedDescription)")
            return false
        }
    }
    
    /// 여러 에셋 즐겨찾기 설정
    /// - Parameters:
    ///   - assets: 대상 에셋 배열
    ///   - favorite: 즐겨찾기 여부
    /// - Returns: 성공 여부
    func setFavorite(_ favorite: Bool, for assets: [PHAsset]) async -> Bool {
        do {
            try await photoLibrary.performChanges {
                for asset in assets {
                    let request = PHAssetChangeRequest(for: asset)
                    request.isFavorite = favorite
                }
            }
            return true
        } catch {
            print("즐겨찾기 설정 실패: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - 삭제
    
    /// 에셋 삭제
    /// - Parameter assets: 삭제할 에셋 배열
    /// - Returns: 성공 여부
    func deleteAssets(_ assets: [PHAsset]) async -> Bool {
        do {
            try await photoLibrary.performChanges {
                PHAssetChangeRequest.deleteAssets(assets as NSFastEnumeration)
            }
            return true
        } catch {
            print("에셋 삭제 실패: \(error.localizedDescription)")
            return false
        }
    }
    
    /// 단일 에셋 삭제
    /// - Parameter asset: 삭제할 에셋
    /// - Returns: 성공 여부
    func deleteAsset(_ asset: PHAsset) async -> Bool {
        await deleteAssets([asset])
    }
    
    // MARK: - 앨범 관리
    
    /// 새 앨범 생성
    /// - Parameter title: 앨범 제목
    /// - Returns: 생성된 앨범의 localIdentifier (실패시 nil)
    func createAlbum(title: String) async -> String? {
        var localIdentifier: String?
        
        do {
            try await photoLibrary.performChanges {
                let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: title)
                localIdentifier = request.placeholderForCreatedAssetCollection.localIdentifier
            }
            return localIdentifier
        } catch {
            print("앨범 생성 실패: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// 앨범에 에셋 추가
    /// - Parameters:
    ///   - assets: 추가할 에셋 배열
    ///   - album: 대상 앨범
    /// - Returns: 성공 여부
    func addAssets(_ assets: [PHAsset], to album: PHAssetCollection) async -> Bool {
        do {
            try await photoLibrary.performChanges {
                guard let request = PHAssetCollectionChangeRequest(for: album) else {
                    return
                }
                request.addAssets(assets as NSFastEnumeration)
            }
            return true
        } catch {
            print("에셋 추가 실패: \(error.localizedDescription)")
            return false
        }
    }
    
    /// 앨범에서 에셋 제거
    /// - Parameters:
    ///   - assets: 제거할 에셋 배열
    ///   - album: 대상 앨범
    /// - Returns: 성공 여부
    func removeAssets(_ assets: [PHAsset], from album: PHAssetCollection) async -> Bool {
        do {
            try await photoLibrary.performChanges {
                guard let request = PHAssetCollectionChangeRequest(for: album) else {
                    return
                }
                request.removeAssets(assets as NSFastEnumeration)
            }
            return true
        } catch {
            print("에셋 제거 실패: \(error.localizedDescription)")
            return false
        }
    }
    
    /// 앨범 삭제
    /// - Parameter album: 삭제할 앨범
    /// - Returns: 성공 여부
    func deleteAlbum(_ album: PHAssetCollection) async -> Bool {
        do {
            try await photoLibrary.performChanges {
                PHAssetCollectionChangeRequest.deleteAssetCollections([album] as NSFastEnumeration)
            }
            return true
        } catch {
            print("앨범 삭제 실패: \(error.localizedDescription)")
            return false
        }
    }
    
    /// 앨범 이름 변경
    /// - Parameters:
    ///   - album: 대상 앨범
    ///   - newTitle: 새 제목
    /// - Returns: 성공 여부
    func renameAlbum(_ album: PHAssetCollection, to newTitle: String) async -> Bool {
        do {
            try await photoLibrary.performChanges {
                guard let request = PHAssetCollectionChangeRequest(for: album) else {
                    return
                }
                request.title = newTitle
            }
            return true
        } catch {
            print("앨범 이름 변경 실패: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - 앨범 페치
    
    /// 모든 스마트 앨범 페치
    /// - Returns: 스마트 앨범 배열
    func fetchSmartAlbums() -> [Album] {
        var albums: [Album] = []
        
        // 주요 스마트 앨범 서브타입
        let subtypes: [PHAssetCollectionSubtype] = [
            .smartAlbumUserLibrary,      // 카메라 롤
            .smartAlbumFavorites,        // 즐겨찾기
            .smartAlbumRecentlyAdded,    // 최근 추가된 항목
            .smartAlbumVideos,           // 비디오
            .smartAlbumScreenshots,      // 스크린샷
            .smartAlbumLivePhotos,       // 라이브 포토
            .smartAlbumPanoramas,        // 파노라마
            .smartAlbumBursts,           // 버스트
            .smartAlbumSlomoVideos,      // 슬로모션
            .smartAlbumTimelapses,       // 타임랩스
            .smartAlbumSelfPortraits,    // 셀피
            .smartAlbumDepthEffect,      // 인물 사진
            .smartAlbumAnimated,         // 움직이는 사진
            .smartAlbumLongExposures,    // 장노출
            .smartAlbumRAW,              // RAW
        ]
        
        for subtype in subtypes {
            let result = PHAssetCollection.fetchAssetCollections(
                with: .smartAlbum,
                subtype: subtype,
                options: nil
            )
            
            if let collection = result.firstObject {
                // 에셋이 있는 앨범만 추가
                let assetCount = PHAsset.fetchAssets(in: collection, options: nil).count
                if assetCount > 0 {
                    albums.append(Album(collection: collection))
                }
            }
        }
        
        return albums
    }
    
    /// 사용자 앨범 페치
    /// - Returns: 사용자 앨범 배열
    func fetchUserAlbums() -> [Album] {
        let result = PHAssetCollection.fetchAssetCollections(
            with: .album,
            subtype: .albumRegular,
            options: nil
        )
        return result.toAlbums()
    }
    
    /// 공유 앨범 페치
    /// - Returns: 공유 앨범 배열
    func fetchSharedAlbums() -> [Album] {
        let result = PHAssetCollection.fetchAssetCollections(
            with: .album,
            subtype: .albumCloudShared,
            options: nil
        )
        return result.toAlbums()
    }
    
    /// 전체 앨범을 섹션별로 페치
    /// - Returns: 앨범 섹션 배열
    func fetchAllAlbumSections() -> [AlbumSection] {
        var sections: [AlbumSection] = []
        
        // 스마트 앨범 섹션
        let smartAlbums = fetchSmartAlbums()
        if !smartAlbums.isEmpty {
            sections.append(AlbumSection(
                title: "미디어 유형",
                albums: smartAlbums,
                iconName: "folder.badge.gearshape"
            ))
        }
        
        // 사용자 앨범 섹션
        let userAlbums = fetchUserAlbums()
        if !userAlbums.isEmpty {
            sections.append(AlbumSection(
                title: "나의 앨범",
                albums: userAlbums,
                iconName: "rectangle.stack"
            ))
        }
        
        // 공유 앨범 섹션
        let sharedAlbums = fetchSharedAlbums()
        if !sharedAlbums.isEmpty {
            sections.append(AlbumSection(
                title: "공유 앨범",
                albums: sharedAlbums,
                iconName: "person.2.fill"
            ))
        }
        
        return sections
    }
}

// MARK: - PHPhotoLibraryChangeObserver
extension PhotoLibraryService: PHPhotoLibraryChangeObserver {
    
    /// 사진 라이브러리 변경 감지
    nonisolated func photoLibraryDidChange(_ changeInstance: PHChange) {
        Task { @MainActor in
            // 변경 토큰 업데이트하여 뷰 리프레시 트리거
            libraryChangeToken = UUID()
        }
    }
}

// MARK: - 클라우드 식별자 서비스
extension PhotoLibraryService {
    
    /// PHCloudIdentifier로 에셋 찾기
    /// - Parameter cloudIdentifiers: 클라우드 식별자 배열
    /// - Returns: (클라우드 식별자, PHAsset) 매핑 딕셔너리
    func fetchAssets(with cloudIdentifiers: [PHCloudIdentifier]) -> [PHCloudIdentifier: PHAsset] {
        var result: [PHCloudIdentifier: PHAsset] = [:]
        
        let localIdentifierResults = PHPhotoLibrary.shared().localIdentifierMappings(for: cloudIdentifiers)
        
        var localIdentifiers: [String] = []
        var cloudIdMap: [String: PHCloudIdentifier] = [:]
        
        for (cloudId, mapping) in zip(cloudIdentifiers, localIdentifierResults) {
            switch mapping {
            case .success(let localId):
                localIdentifiers.append(localId)
                cloudIdMap[localId] = cloudId
            case .failure:
                continue
            }
        }
        
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: localIdentifiers, options: nil)
        assets.enumerateObjects { asset, _, _ in
            if let cloudId = cloudIdMap[asset.localIdentifier] {
                result[cloudId] = asset
            }
        }
        
        return result
    }
    
    /// 에셋의 클라우드 식별자 가져오기
    /// - Parameter assets: PHAsset 배열
    /// - Returns: (localIdentifier, PHCloudIdentifier) 매핑 딕셔너리
    func cloudIdentifiers(for assets: [PHAsset]) -> [String: PHCloudIdentifier] {
        var result: [String: PHCloudIdentifier] = [:]
        
        let identifiers = assets.map { $0.localIdentifier }
        let cloudIds = PHPhotoLibrary.shared().cloudIdentifierMappings(forLocalIdentifiers: identifiers)
        
        for (localId, mapping) in zip(identifiers, cloudIds) {
            switch mapping {
            case .success(let cloudId):
                result[localId] = cloudId
            case .failure:
                continue
            }
        }
        
        return result
    }
}
