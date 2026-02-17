import Foundation

// MARK: - 비디오 모델
// SharePlay에서 공유할 비디오 정보를 담는 모델

/// 비디오 콘텐츠를 나타내는 구조체
/// Codable을 준수하여 GroupActivity에서 전송 가능
struct Video: Identifiable, Codable, Hashable, Sendable {
    /// 비디오 고유 식별자
    let id: UUID
    
    /// 비디오 제목
    let title: String
    
    /// 비디오 설명
    let description: String
    
    /// 비디오 URL (스트리밍 또는 로컬)
    let url: URL
    
    /// 비디오 썸네일 이미지 이름
    let thumbnailName: String
    
    /// 비디오 길이 (초 단위)
    let duration: TimeInterval
    
    /// 카테고리
    let category: VideoCategory
    
    /// 기본 생성자
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        url: URL,
        thumbnailName: String,
        duration: TimeInterval,
        category: VideoCategory = .movie
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.url = url
        self.thumbnailName = thumbnailName
        self.duration = duration
        self.category = category
    }
}

// MARK: - 비디오 카테고리
/// 비디오 분류를 위한 열거형
enum VideoCategory: String, Codable, CaseIterable, Sendable {
    case movie = "영화"
    case tvShow = "TV 프로그램"
    case documentary = "다큐멘터리"
    case music = "뮤직비디오"
    case sports = "스포츠"
    case education = "교육"
    
    /// 카테고리 아이콘
    var iconName: String {
        switch self {
        case .movie: return "film"
        case .tvShow: return "tv"
        case .documentary: return "doc.text.image"
        case .music: return "music.note"
        case .sports: return "sportscourt"
        case .education: return "book"
        }
    }
}

// MARK: - 샘플 비디오 데이터
extension Video {
    /// 데모용 샘플 비디오 목록
    static let samples: [Video] = [
        Video(
            title: "우주의 신비",
            description: "광활한 우주를 탐험하는 다큐멘터리",
            url: URL(string: "https://example.com/videos/space.mp4")!,
            thumbnailName: "space_thumbnail",
            duration: 3600,
            category: .documentary
        ),
        Video(
            title: "자연의 경이로움",
            description: "지구의 아름다운 자연을 담은 영상",
            url: URL(string: "https://example.com/videos/nature.mp4")!,
            thumbnailName: "nature_thumbnail",
            duration: 2700,
            category: .documentary
        ),
        Video(
            title: "미래 도시",
            description: "2050년의 도시 생활을 상상하는 SF 영화",
            url: URL(string: "https://example.com/videos/future.mp4")!,
            thumbnailName: "future_thumbnail",
            duration: 7200,
            category: .movie
        ),
        Video(
            title: "코딩 마스터",
            description: "Swift 프로그래밍 입문 강좌",
            url: URL(string: "https://example.com/videos/coding.mp4")!,
            thumbnailName: "coding_thumbnail",
            duration: 1800,
            category: .education
        ),
        Video(
            title: "월드컵 하이라이트",
            description: "2024 월드컵 최고의 순간들",
            url: URL(string: "https://example.com/videos/worldcup.mp4")!,
            thumbnailName: "worldcup_thumbnail",
            duration: 900,
            category: .sports
        ),
        Video(
            title: "K-POP 뮤직비디오",
            description: "최신 K-POP 히트곡 모음",
            url: URL(string: "https://example.com/videos/kpop.mp4")!,
            thumbnailName: "kpop_thumbnail",
            duration: 240,
            category: .music
        )
    ]
}
