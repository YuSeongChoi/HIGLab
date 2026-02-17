// FeedItem.swift
// SmartFeed - RelevanceKit 샘플
// 피드 아이템 모델 정의

import Foundation
import RelevanceKit

// MARK: - 피드 아이템 카테고리
/// 피드 콘텐츠의 카테고리를 정의합니다
enum FeedCategory: String, Codable, CaseIterable, Identifiable {
    case news = "news"              // 뉴스
    case entertainment = "entertainment"  // 엔터테인먼트
    case sports = "sports"          // 스포츠
    case technology = "technology"  // 기술
    case lifestyle = "lifestyle"    // 라이프스타일
    case food = "food"              // 음식
    case travel = "travel"          // 여행
    case finance = "finance"        // 금융
    
    var id: String { rawValue }
    
    /// 카테고리 표시 이름
    var displayName: String {
        switch self {
        case .news: return "뉴스"
        case .entertainment: return "엔터테인먼트"
        case .sports: return "스포츠"
        case .technology: return "기술"
        case .lifestyle: return "라이프스타일"
        case .food: return "음식"
        case .travel: return "여행"
        case .finance: return "금융"
        }
    }
    
    /// 카테고리 아이콘
    var iconName: String {
        switch self {
        case .news: return "newspaper.fill"
        case .entertainment: return "film.fill"
        case .sports: return "sportscourt.fill"
        case .technology: return "cpu.fill"
        case .lifestyle: return "heart.fill"
        case .food: return "fork.knife"
        case .travel: return "airplane"
        case .finance: return "chart.line.uptrend.xyaxis"
        }
    }
}

// MARK: - 콘텐츠 타입
/// 피드 콘텐츠의 미디어 타입
enum ContentType: String, Codable {
    case article = "article"        // 기사
    case video = "video"            // 비디오
    case image = "image"            // 이미지
    case podcast = "podcast"        // 팟캐스트
    case liveStream = "live_stream" // 라이브 스트림
    
    /// 타입별 아이콘
    var iconName: String {
        switch self {
        case .article: return "doc.text.fill"
        case .video: return "play.rectangle.fill"
        case .image: return "photo.fill"
        case .podcast: return "waveform"
        case .liveStream: return "antenna.radiowaves.left.and.right"
        }
    }
}

// MARK: - 피드 아이템
/// 피드에 표시되는 개별 콘텐츠 아이템
struct FeedItem: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String               // 제목
    let summary: String             // 요약
    let category: FeedCategory      // 카테고리
    let contentType: ContentType    // 콘텐츠 타입
    let author: String              // 작성자
    let publishedAt: Date           // 발행 시간
    let imageURL: URL?              // 썸네일 URL
    let contentURL: URL             // 콘텐츠 URL
    let readTimeMinutes: Int        // 예상 읽기 시간 (분)
    let tags: [String]              // 태그 목록
    let location: FeedLocation?     // 관련 위치 (있는 경우)
    let engagement: EngagementMetrics // 참여 지표
    
    // MARK: - 초기화
    init(
        id: UUID = UUID(),
        title: String,
        summary: String,
        category: FeedCategory,
        contentType: ContentType,
        author: String,
        publishedAt: Date,
        imageURL: URL? = nil,
        contentURL: URL,
        readTimeMinutes: Int,
        tags: [String] = [],
        location: FeedLocation? = nil,
        engagement: EngagementMetrics = EngagementMetrics()
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.category = category
        self.contentType = contentType
        self.author = author
        self.publishedAt = publishedAt
        self.imageURL = imageURL
        self.contentURL = contentURL
        self.readTimeMinutes = readTimeMinutes
        self.tags = tags
        self.location = location
        self.engagement = engagement
    }
    
    /// 발행 후 경과 시간을 사람이 읽기 쉬운 형태로 반환
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: publishedAt, relativeTo: Date())
    }
    
    /// 읽기 시간 표시 문자열
    var readTimeDisplay: String {
        if readTimeMinutes < 1 {
            return "1분 미만"
        } else {
            return "\(readTimeMinutes)분"
        }
    }
}

// MARK: - 피드 위치 정보
/// 피드 콘텐츠와 관련된 위치 정보
struct FeedLocation: Codable, Hashable {
    let latitude: Double    // 위도
    let longitude: Double   // 경도
    let name: String        // 장소 이름
    let radius: Double      // 관련 반경 (미터)
    
    /// 두 위치 간 거리 계산 (미터 단위)
    func distance(from other: FeedLocation) -> Double {
        let earthRadius = 6371000.0 // 지구 반경 (미터)
        
        let lat1 = latitude * .pi / 180
        let lat2 = other.latitude * .pi / 180
        let deltaLat = (other.latitude - latitude) * .pi / 180
        let deltaLon = (other.longitude - longitude) * .pi / 180
        
        let a = sin(deltaLat / 2) * sin(deltaLat / 2) +
                cos(lat1) * cos(lat2) *
                sin(deltaLon / 2) * sin(deltaLon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        
        return earthRadius * c
    }
}

// MARK: - 참여 지표
/// 콘텐츠의 사용자 참여 지표
struct EngagementMetrics: Codable, Hashable {
    var views: Int          // 조회수
    var likes: Int          // 좋아요 수
    var shares: Int         // 공유 수
    var comments: Int       // 댓글 수
    var bookmarks: Int      // 북마크 수
    
    init(
        views: Int = 0,
        likes: Int = 0,
        shares: Int = 0,
        comments: Int = 0,
        bookmarks: Int = 0
    ) {
        self.views = views
        self.likes = likes
        self.shares = shares
        self.comments = comments
        self.bookmarks = bookmarks
    }
    
    /// 전체 참여도 점수 (가중치 적용)
    var engagementScore: Double {
        let viewWeight = 0.1
        let likeWeight = 1.0
        let shareWeight = 2.0
        let commentWeight = 1.5
        let bookmarkWeight = 1.5
        
        return Double(views) * viewWeight +
               Double(likes) * likeWeight +
               Double(shares) * shareWeight +
               Double(comments) * commentWeight +
               Double(bookmarks) * bookmarkWeight
    }
}

// MARK: - RelevanceKit 호환 확장
extension FeedItem {
    /// RelevanceKit RKContent로 변환
    @available(iOS 26.0, *)
    func toRelevanceContent() -> RKContent {
        var content = RKContent(
            identifier: id.uuidString,
            contentType: .article
        )
        
        // 메타데이터 설정
        content.title = title
        content.summary = summary
        content.category = category.rawValue
        content.tags = tags
        content.publishDate = publishedAt
        
        // 위치 정보 설정
        if let location = location {
            content.location = RKLocation(
                latitude: location.latitude,
                longitude: location.longitude
            )
            content.locationRelevanceRadius = location.radius
        }
        
        // 참여도 메트릭 설정
        content.engagementMetrics = RKEngagementMetrics(
            views: engagement.views,
            interactions: engagement.likes + engagement.comments,
            shares: engagement.shares
        )
        
        return content
    }
}
