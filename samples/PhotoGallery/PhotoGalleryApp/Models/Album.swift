import SwiftUI
import Photos

// MARK: - 앨범 모델
/// PHAssetCollection을 래핑하여 SwiftUI에서 사용하기 쉽게 만든 앨범 모델
struct Album: Identifiable, Equatable, Hashable {
    
    // MARK: - 식별자
    
    /// 고유 식별자 (PHAssetCollection의 localIdentifier 사용)
    let id: String
    
    /// PHAssetCollection 참조
    let collection: PHAssetCollection
    
    // MARK: - 앨범 타입
    
    /// 앨범 종류 열거형
    enum AlbumType: String {
        // 스마트 앨범
        case cameraRoll = "카메라 롤"
        case favorites = "즐겨찾기"
        case screenshots = "스크린샷"
        case recentlyAdded = "최근 추가된 항목"
        case recentlyDeleted = "최근 삭제된 항목"
        case videos = "비디오"
        case panoramas = "파노라마"
        case livePhotos = "라이브 포토"
        case bursts = "버스트"
        case slowMotion = "슬로모션"
        case timelapse = "타임랩스"
        case hidden = "가려진 항목"
        case selfPortraits = "셀피"
        case depthEffect = "인물 사진"
        case animated = "움직이는 사진"
        case longExposure = "장노출"
        case raw = "RAW"
        case cinematic = "시네마틱"
        
        // 사용자 앨범
        case userAlbum = "사용자 앨범"
        case sharedAlbum = "공유 앨범"
        case cloudShared = "나의 사진 스트림"
        
        // 스마트 폴더
        case smartFolder = "스마트 폴더"
        
        // 기타
        case unknown = "알 수 없음"
        
        /// 아이콘 이름
        var iconName: String {
            switch self {
            case .cameraRoll: return "photo.on.rectangle.angled"
            case .favorites: return "heart.fill"
            case .screenshots: return "camera.viewfinder"
            case .recentlyAdded: return "clock.arrow.circlepath"
            case .recentlyDeleted: return "trash"
            case .videos: return "video"
            case .panoramas: return "pano"
            case .livePhotos: return "livephoto"
            case .bursts: return "square.stack.3d.up"
            case .slowMotion: return "slowmo"
            case .timelapse: return "timelapse"
            case .hidden: return "eye.slash"
            case .selfPortraits: return "person.crop.square"
            case .depthEffect: return "person.crop.rectangle"
            case .animated: return "photo.stack"
            case .longExposure: return "camera.aperture"
            case .raw: return "r.square"
            case .cinematic: return "film"
            case .userAlbum: return "rectangle.stack"
            case .sharedAlbum: return "person.2.fill"
            case .cloudShared: return "cloud"
            case .smartFolder: return "folder"
            case .unknown: return "questionmark.folder"
            }
        }
        
        /// PHAssetCollectionSubtype에서 변환
        init(from subtype: PHAssetCollectionSubtype, type: PHAssetCollectionType) {
            switch subtype {
            case .smartAlbumUserLibrary:
                self = .cameraRoll
            case .smartAlbumFavorites:
                self = .favorites
            case .smartAlbumScreenshots:
                self = .screenshots
            case .smartAlbumRecentlyAdded:
                self = .recentlyAdded
            case .smartAlbumVideos:
                self = .videos
            case .smartAlbumPanoramas:
                self = .panoramas
            case .smartAlbumLivePhotos:
                self = .livePhotos
            case .smartAlbumBursts:
                self = .bursts
            case .smartAlbumSlomoVideos:
                self = .slowMotion
            case .smartAlbumTimelapses:
                self = .timelapse
            case .smartAlbumSelfPortraits:
                self = .selfPortraits
            case .smartAlbumDepthEffect:
                self = .depthEffect
            case .smartAlbumAnimated:
                self = .animated
            case .smartAlbumLongExposures:
                self = .longExposure
            case .smartAlbumRAW:
                self = .raw
            case .smartAlbumCinematic:
                self = .cinematic
            default:
                switch type {
                case .album:
                    self = .userAlbum
                case .smartAlbum:
                    self = .smartFolder
                case .moment:
                    self = .unknown
                @unknown default:
                    self = .unknown
                }
            }
        }
    }
    
    // MARK: - 계산 프로퍼티
    
    /// 앨범 제목
    var title: String {
        collection.localizedTitle ?? "제목 없음"
    }
    
    /// 앨범 타입
    var albumType: AlbumType {
        AlbumType(from: collection.assetCollectionSubtype, type: collection.assetCollectionType)
    }
    
    /// 에셋 개수
    var estimatedAssetCount: Int {
        collection.estimatedAssetCount
    }
    
    /// 실제 에셋 개수 (정확한 값)
    var actualAssetCount: Int {
        let fetchOptions = PHFetchOptions()
        let result = PHAsset.fetchAssets(in: collection, options: fetchOptions)
        return result.count
    }
    
    /// 시작 날짜
    var startDate: Date? {
        collection.startDate
    }
    
    /// 종료 날짜
    var endDate: Date? {
        collection.endDate
    }
    
    /// 대표 위치
    var approximateLocation: CLLocation? {
        collection.approximateLocation
    }
    
    /// 사용자 생성 앨범 여부
    var isUserAlbum: Bool {
        collection.assetCollectionType == .album
    }
    
    /// 스마트 앨범 여부
    var isSmartAlbum: Bool {
        collection.assetCollectionType == .smartAlbum
    }
    
    /// 공유 앨범 여부
    var isSharedAlbum: Bool {
        collection.assetCollectionSubtype == .albumCloudShared
    }
    
    // MARK: - 초기화
    
    /// PHAssetCollection으로 초기화
    /// - Parameter collection: Photos Framework의 PHAssetCollection 객체
    init(collection: PHAssetCollection) {
        self.id = collection.localIdentifier
        self.collection = collection
    }
    
    // MARK: - 에셋 페치
    
    /// 앨범 내 에셋 페치
    /// - Parameters:
    ///   - filterType: 필터 타입
    ///   - sortOrder: 정렬 순서
    /// - Returns: PHFetchResult<PHAsset>
    func fetchAssets(
        filterType: MediaAsset.FilterType = .all,
        sortOrder: MediaAsset.SortOrder = .newestFirst
    ) -> PHFetchResult<PHAsset> {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = sortOrder.sortDescriptors
        
        // 기본 필터에 추가 필터 적용
        if let predicate = filterType.predicate {
            fetchOptions.predicate = predicate
        }
        
        return PHAsset.fetchAssets(in: collection, options: fetchOptions)
    }
    
    /// 앨범 내 MediaAsset 배열 페치
    /// - Parameters:
    ///   - filterType: 필터 타입
    ///   - sortOrder: 정렬 순서
    /// - Returns: MediaAsset 배열
    func fetchMediaAssets(
        filterType: MediaAsset.FilterType = .all,
        sortOrder: MediaAsset.SortOrder = .newestFirst
    ) -> [MediaAsset] {
        fetchAssets(filterType: filterType, sortOrder: sortOrder).toMediaAssets()
    }
    
    /// 커버 이미지용 첫 번째 에셋 페치
    /// - Returns: 첫 번째 PHAsset (없으면 nil)
    func fetchCoverAsset() -> PHAsset? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 1
        
        let result = PHAsset.fetchAssets(in: collection, options: fetchOptions)
        return result.firstObject
    }
    
    // MARK: - Equatable
    
    static func == (lhs: Album, rhs: Album) -> Bool {
        lhs.id == rhs.id
    }
    
    // MARK: - Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - 앨범 섹션
/// 앨범 목록을 섹션별로 그룹화하기 위한 모델
struct AlbumSection: Identifiable {
    
    /// 섹션 식별자
    let id = UUID()
    
    /// 섹션 제목
    let title: String
    
    /// 섹션 내 앨범 배열
    var albums: [Album]
    
    /// 섹션 아이콘 이름
    let iconName: String?
    
    // MARK: - 초기화
    
    init(title: String, albums: [Album], iconName: String? = nil) {
        self.title = title
        self.albums = albums
        self.iconName = iconName
    }
}

// MARK: - 앨범 카테고리
extension Album {
    
    /// 앨범 카테고리 열거형
    enum Category: String, CaseIterable {
        case mediaTypes = "미디어 유형"
        case myAlbums = "나의 앨범"
        case sharedAlbums = "공유 앨범"
        case people = "사람들"
        case places = "장소"
        
        /// 아이콘 이름
        var iconName: String {
            switch self {
            case .mediaTypes: return "photo.on.rectangle.angled"
            case .myAlbums: return "rectangle.stack"
            case .sharedAlbums: return "person.2.fill"
            case .people: return "person.crop.circle"
            case .places: return "map"
            }
        }
    }
}

// MARK: - PHFetchResult 확장 (앨범)
extension PHFetchResult where ObjectType == PHAssetCollection {
    
    /// PHFetchResult를 Album 배열로 변환
    /// - Returns: Album 배열
    func toAlbums() -> [Album] {
        var albums: [Album] = []
        albums.reserveCapacity(count)
        
        enumerateObjects { collection, _, _ in
            albums.append(Album(collection: collection))
        }
        
        return albums
    }
}
