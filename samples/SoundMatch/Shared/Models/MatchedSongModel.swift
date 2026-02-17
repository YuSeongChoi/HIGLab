import Foundation
import SwiftData
import ShazamKit

// MARK: - MatchedSongModel
/// SwiftData 기반 인식된 곡 모델
/// SHMediaItem의 모든 속성을 활용하여 풍부한 메타데이터 저장

@Model
final class MatchedSongModel {
    // MARK: - 기본 식별자
    /// 로컬 고유 ID
    @Attribute(.unique) var id: UUID
    
    /// Shazam 고유 ID (SHMediaItemProperty.shazamID)
    var shazamID: String?
    
    /// ISRC 코드 (국제 표준 녹음 코드)
    var isrc: String?
    
    // MARK: - 곡 정보
    /// 곡 제목 (SHMediaItemProperty.title)
    var title: String
    
    /// 부제목 (SHMediaItemProperty.subtitle)
    var subtitle: String?
    
    /// 아티스트 (SHMediaItemProperty.artist)
    var artist: String
    
    /// 앨범명
    var albumTitle: String?
    
    // MARK: - 미디어 URL
    /// 앨범 아트워크 URL (SHMediaItemProperty.artworkURL)
    var artworkURLString: String?
    
    /// Apple Music URL (SHMediaItemProperty.appleMusicURL)
    var appleMusicURLString: String?
    
    /// 웹 URL (SHMediaItemProperty.webURL)
    var webURLString: String?
    
    /// 비디오 URL (SHMediaItemProperty.videoURL)
    var videoURLString: String?
    
    // MARK: - 장르 및 분류
    /// 장르 목록 (SHMediaItemProperty.genres)
    var genres: [String]
    
    /// 명시적 콘텐츠 여부 (SHMediaItemProperty.explicitContent)
    var isExplicitContent: Bool
    
    // MARK: - 매칭 정보
    /// 매칭 시간 오프셋 (초 단위)
    var matchOffset: TimeInterval?
    
    /// 곡의 해당 구간 시작 위치 (초)
    var frequencySkewStart: Double?
    
    /// 곡의 해당 구간 끝 위치 (초)
    var frequencySkewEnd: Double?
    
    /// 매칭 신뢰도 (0.0 ~ 1.0)
    var matchConfidence: Float?
    
    // MARK: - 타임스탬프
    /// 인식된 시간
    var matchedAt: Date
    
    /// 마지막 재생 시간
    var lastPlayedAt: Date?
    
    // MARK: - 사용자 데이터
    /// 즐겨찾기 여부
    var isFavorite: Bool
    
    /// 사용자 메모
    var userNote: String?
    
    /// 재생 횟수
    var playCount: Int
    
    /// Shazam Library에 추가됨
    var isAddedToShazamLibrary: Bool
    
    // MARK: - 위치 정보
    /// 인식된 위치 (위도)
    var latitude: Double?
    
    /// 인식된 위치 (경도)
    var longitude: Double?
    
    /// 위치명
    var locationName: String?
    
    // MARK: - 커스텀 카탈로그 관련
    /// 커스텀 카탈로그에서 매칭된 경우
    var isFromCustomCatalog: Bool
    
    /// 커스텀 카탈로그 이름
    var customCatalogName: String?
    
    // MARK: - 계산 프로퍼티
    var artworkURL: URL? {
        guard let urlString = artworkURLString else { return nil }
        return URL(string: urlString)
    }
    
    var appleMusicURL: URL? {
        guard let urlString = appleMusicURLString else { return nil }
        return URL(string: urlString)
    }
    
    var webURL: URL? {
        guard let urlString = webURLString else { return nil }
        return URL(string: urlString)
    }
    
    var videoURL: URL? {
        guard let urlString = videoURLString else { return nil }
        return URL(string: urlString)
    }
    
    /// 매칭 구간 범위 (SHRange 표현)
    var matchRange: ClosedRange<Double>? {
        guard let start = frequencySkewStart, let end = frequencySkewEnd else {
            return nil
        }
        return start...end
    }
    
    // MARK: - 초기화
    init(
        id: UUID = UUID(),
        shazamID: String? = nil,
        isrc: String? = nil,
        title: String,
        subtitle: String? = nil,
        artist: String,
        albumTitle: String? = nil,
        artworkURL: URL? = nil,
        appleMusicURL: URL? = nil,
        webURL: URL? = nil,
        videoURL: URL? = nil,
        genres: [String] = [],
        isExplicitContent: Bool = false,
        matchOffset: TimeInterval? = nil,
        frequencySkewStart: Double? = nil,
        frequencySkewEnd: Double? = nil,
        matchConfidence: Float? = nil,
        matchedAt: Date = Date(),
        isFavorite: Bool = false,
        userNote: String? = nil,
        playCount: Int = 0,
        isAddedToShazamLibrary: Bool = false,
        latitude: Double? = nil,
        longitude: Double? = nil,
        locationName: String? = nil,
        isFromCustomCatalog: Bool = false,
        customCatalogName: String? = nil
    ) {
        self.id = id
        self.shazamID = shazamID
        self.isrc = isrc
        self.title = title
        self.subtitle = subtitle
        self.artist = artist
        self.albumTitle = albumTitle
        self.artworkURLString = artworkURL?.absoluteString
        self.appleMusicURLString = appleMusicURL?.absoluteString
        self.webURLString = webURL?.absoluteString
        self.videoURLString = videoURL?.absoluteString
        self.genres = genres
        self.isExplicitContent = isExplicitContent
        self.matchOffset = matchOffset
        self.frequencySkewStart = frequencySkewStart
        self.frequencySkewEnd = frequencySkewEnd
        self.matchConfidence = matchConfidence
        self.matchedAt = matchedAt
        self.lastPlayedAt = nil
        self.isFavorite = isFavorite
        self.userNote = userNote
        self.playCount = playCount
        self.isAddedToShazamLibrary = isAddedToShazamLibrary
        self.latitude = latitude
        self.longitude = longitude
        self.locationName = locationName
        self.isFromCustomCatalog = isFromCustomCatalog
        self.customCatalogName = customCatalogName
    }
}

// MARK: - SHMediaItem 변환
extension MatchedSongModel {
    /// SHMediaItem에서 모델 생성
    /// - Parameters:
    ///   - mediaItem: ShazamKit 미디어 아이템
    ///   - matchedMediaItem: 매칭된 미디어 아이템 (추가 정보 포함)
    convenience init(
        from mediaItem: SHMediaItem,
        matchedMediaItem: SHMatchedMediaItem? = nil
    ) {
        self.init(
            shazamID: mediaItem.shazamID,
            isrc: mediaItem.isrc,
            title: mediaItem.title ?? "알 수 없는 곡",
            subtitle: mediaItem.subtitle,
            artist: mediaItem.artist ?? "알 수 없는 아티스트",
            artworkURL: mediaItem.artworkURL,
            appleMusicURL: mediaItem.appleMusicURL,
            webURL: mediaItem.webURL,
            videoURL: mediaItem.videoURL,
            genres: mediaItem.genres,
            isExplicitContent: mediaItem.explicitContent
        )
        
        // SHMatchedMediaItem에서 추가 매칭 정보 추출
        if let matched = matchedMediaItem {
            self.matchOffset = matched.matchOffset
            
            // frequencySkew 범위 추출 (SHRange)
            if let skewRanges = matched.frequencySkewRanges.first {
                self.frequencySkewStart = skewRanges.lowerBound
                self.frequencySkewEnd = skewRanges.upperBound
            }
        }
    }
}

// MARK: - Hashable
extension MatchedSongModel: Hashable {
    static func == (lhs: MatchedSongModel, rhs: MatchedSongModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - 미리보기 데이터
extension MatchedSongModel {
    /// 미리보기용 샘플 데이터
    static var preview: MatchedSongModel {
        MatchedSongModel(
            shazamID: "sample-123",
            title: "Blinding Lights",
            subtitle: "From the album 'After Hours'",
            artist: "The Weeknd",
            albumTitle: "After Hours",
            artworkURL: URL(string: "https://example.com/artwork.jpg"),
            appleMusicURL: URL(string: "https://music.apple.com/album/123"),
            genres: ["Pop", "Synth-pop", "R&B"],
            isExplicitContent: false,
            matchOffset: 45.5,
            matchConfidence: 0.95,
            matchedAt: Date(),
            isFavorite: true,
            playCount: 5
        )
    }
    
    /// 미리보기용 목록
    static var previewList: [MatchedSongModel] {
        [
            MatchedSongModel(
                shazamID: "1",
                title: "Blinding Lights",
                artist: "The Weeknd",
                genres: ["Pop", "Synth-pop"],
                matchedAt: Date()
            ),
            MatchedSongModel(
                shazamID: "2",
                title: "Shape of You",
                artist: "Ed Sheeran",
                genres: ["Pop"],
                matchedAt: Date().addingTimeInterval(-3600)
            ),
            MatchedSongModel(
                shazamID: "3",
                title: "Dynamite",
                artist: "BTS",
                genres: ["K-Pop", "Dance"],
                matchedAt: Date().addingTimeInterval(-7200),
                isFavorite: true
            ),
            MatchedSongModel(
                shazamID: "4",
                title: "Bad Guy",
                artist: "Billie Eilish",
                genres: ["Electropop"],
                matchedAt: Date().addingTimeInterval(-86400),
                isExplicitContent: true
            )
        ]
    }
}

// MARK: - SHMediaItemProperty 확장 사용 예시
/// ShazamKit의 SHMediaItemProperty를 활용한 커스텀 속성 접근
extension SHMediaItem {
    /// 커스텀 프로퍼티 접근 헬퍼
    /// - Parameter property: 미디어 아이템 프로퍼티 키
    /// - Returns: 해당 프로퍼티 값
    func customValue<T>(for property: SHMediaItemProperty) -> T? {
        return self[property] as? T
    }
}
