import SwiftUI
import Photos
import PhotosUI

// MARK: - 미디어 에셋 모델
/// PHAsset을 래핑하여 SwiftUI에서 사용하기 쉽게 만든 모델
/// Identifiable, Equatable, Hashable 프로토콜 준수
struct MediaAsset: Identifiable, Equatable, Hashable {
    
    // MARK: - 식별자
    
    /// 고유 식별자 (PHAsset의 localIdentifier 사용)
    let id: String
    
    /// PHAsset 참조
    let asset: PHAsset
    
    // MARK: - 미디어 타입
    
    /// 미디어 타입 열거형
    enum MediaType: String, CaseIterable {
        case image = "사진"
        case video = "비디오"
        case livePhoto = "라이브 포토"
        case unknown = "알 수 없음"
        
        /// SF Symbol 아이콘 이름
        var iconName: String {
            switch self {
            case .image: return "photo"
            case .video: return "video"
            case .livePhoto: return "livephoto"
            case .unknown: return "questionmark.circle"
            }
        }
        
        /// PHAssetMediaType에서 변환
        init(from phMediaType: PHAssetMediaType, subTypes: PHAssetMediaSubtype) {
            switch phMediaType {
            case .image:
                // 라이브 포토 확인
                if subTypes.contains(.photoLive) {
                    self = .livePhoto
                } else {
                    self = .image
                }
            case .video:
                self = .video
            default:
                self = .unknown
            }
        }
    }
    
    // MARK: - 계산 프로퍼티
    
    /// 미디어 타입
    var mediaType: MediaType {
        MediaType(from: asset.mediaType, subTypes: asset.mediaSubtypes)
    }
    
    /// 생성 날짜
    var creationDate: Date? {
        asset.creationDate
    }
    
    /// 수정 날짜
    var modificationDate: Date? {
        asset.modificationDate
    }
    
    /// 즐겨찾기 여부
    var isFavorite: Bool {
        asset.isFavorite
    }
    
    /// 숨김 여부
    var isHidden: Bool {
        asset.isHidden
    }
    
    /// 원본 파일명
    var originalFilename: String? {
        PHAssetResource.assetResources(for: asset).first?.originalFilename
    }
    
    /// 위치 정보
    var location: CLLocation? {
        asset.location
    }
    
    /// 가로 크기 (픽셀)
    var pixelWidth: Int {
        asset.pixelWidth
    }
    
    /// 세로 크기 (픽셀)
    var pixelHeight: Int {
        asset.pixelHeight
    }
    
    /// 해상도 문자열 (예: "4032 x 3024")
    var resolutionString: String {
        "\(pixelWidth) × \(pixelHeight)"
    }
    
    /// 비디오 길이 (초)
    var duration: TimeInterval {
        asset.duration
    }
    
    /// 포맷된 비디오 길이 문자열
    var formattedDuration: String? {
        guard mediaType == .video else { return nil }
        
        let totalSeconds = Int(duration)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    /// iCloud 상태
    var isCloud: Bool {
        // sourceType으로 iCloud 에셋인지 확인
        asset.sourceType.contains(.typeCloudShared)
    }
    
    /// 버스트 사진 여부
    var isBurst: Bool {
        asset.representsBurst
    }
    
    /// HDR 사진 여부
    var isHDR: Bool {
        asset.mediaSubtypes.contains(.photoHDR)
    }
    
    /// 파노라마 사진 여부
    var isPanorama: Bool {
        asset.mediaSubtypes.contains(.photoPanorama)
    }
    
    /// 스크린샷 여부
    var isScreenshot: Bool {
        asset.mediaSubtypes.contains(.photoScreenshot)
    }
    
    /// 슬로모션 비디오 여부
    var isSlowMotion: Bool {
        asset.mediaSubtypes.contains(.videoHighFrameRate)
    }
    
    /// 타임랩스 비디오 여부
    var isTimelapse: Bool {
        asset.mediaSubtypes.contains(.videoTimelapse)
    }
    
    // MARK: - 초기화
    
    /// PHAsset으로 초기화
    /// - Parameter asset: Photos Framework의 PHAsset 객체
    init(asset: PHAsset) {
        self.id = asset.localIdentifier
        self.asset = asset
    }
    
    // MARK: - Equatable
    
    static func == (lhs: MediaAsset, rhs: MediaAsset) -> Bool {
        lhs.id == rhs.id
    }
    
    // MARK: - Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - PHFetchResult 확장
extension PHFetchResult where ObjectType == PHAsset {
    
    /// PHFetchResult를 MediaAsset 배열로 변환
    /// - Returns: MediaAsset 배열
    func toMediaAssets() -> [MediaAsset] {
        var assets: [MediaAsset] = []
        assets.reserveCapacity(count)
        
        enumerateObjects { asset, _, _ in
            assets.append(MediaAsset(asset: asset))
        }
        
        return assets
    }
    
    /// 특정 인덱스의 MediaAsset 반환
    /// - Parameter index: 인덱스
    /// - Returns: MediaAsset
    func mediaAsset(at index: Int) -> MediaAsset {
        MediaAsset(asset: object(at: index))
    }
}

// MARK: - 캐시 키 제공 프로토콜
extension MediaAsset {
    
    /// 썸네일 캐시 키
    var thumbnailCacheKey: String {
        "\(id)_thumb"
    }
    
    /// 전체 크기 이미지 캐시 키
    var fullSizeCacheKey: String {
        "\(id)_full"
    }
    
    /// 라이브 포토 캐시 키
    var livePhotoCacheKey: String {
        "\(id)_live"
    }
}

// MARK: - 정렬 옵션
extension MediaAsset {
    
    /// 정렬 기준 열거형
    enum SortOrder: String, CaseIterable {
        case newestFirst = "최신순"
        case oldestFirst = "오래된순"
        case filename = "파일명순"
        
        /// PHFetchOptions의 sortDescriptors 반환
        var sortDescriptors: [NSSortDescriptor] {
            switch self {
            case .newestFirst:
                return [NSSortDescriptor(key: "creationDate", ascending: false)]
            case .oldestFirst:
                return [NSSortDescriptor(key: "creationDate", ascending: true)]
            case .filename:
                return [NSSortDescriptor(key: "filename", ascending: true)]
            }
        }
    }
}

// MARK: - 필터 옵션
extension MediaAsset {
    
    /// 필터 조건 열거형
    enum FilterType: String, CaseIterable {
        case all = "전체"
        case images = "사진만"
        case videos = "비디오만"
        case livePhotos = "라이브 포토만"
        case favorites = "즐겨찾기"
        case screenshots = "스크린샷"
        case panoramas = "파노라마"
        case hdr = "HDR"
        case bursts = "버스트"
        
        /// PHFetchOptions의 predicate 반환
        var predicate: NSPredicate? {
            switch self {
            case .all:
                return nil
            case .images:
                return NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
            case .videos:
                return NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
            case .livePhotos:
                return NSPredicate(format: "(mediaSubtypes & %d) != 0", PHAssetMediaSubtype.photoLive.rawValue)
            case .favorites:
                return NSPredicate(format: "isFavorite == YES")
            case .screenshots:
                return NSPredicate(format: "(mediaSubtypes & %d) != 0", PHAssetMediaSubtype.photoScreenshot.rawValue)
            case .panoramas:
                return NSPredicate(format: "(mediaSubtypes & %d) != 0", PHAssetMediaSubtype.photoPanorama.rawValue)
            case .hdr:
                return NSPredicate(format: "(mediaSubtypes & %d) != 0", PHAssetMediaSubtype.photoHDR.rawValue)
            case .bursts:
                return NSPredicate(format: "representsBurst == YES")
            }
        }
        
        /// 아이콘 이름
        var iconName: String {
            switch self {
            case .all: return "photo.on.rectangle.angled"
            case .images: return "photo"
            case .videos: return "video"
            case .livePhotos: return "livephoto"
            case .favorites: return "heart.fill"
            case .screenshots: return "camera.viewfinder"
            case .panoramas: return "pano"
            case .hdr: return "camera.filters"
            case .bursts: return "square.stack.3d.up"
            }
        }
    }
}
