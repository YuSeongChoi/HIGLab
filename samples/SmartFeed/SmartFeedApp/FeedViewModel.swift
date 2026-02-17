// FeedViewModel.swift
// SmartFeed - RelevanceKit 샘플
// 피드 데이터 관리 및 비즈니스 로직

import Foundation
import SwiftUI
import Observation

// MARK: - 피드 뷰모델
/// 피드 데이터를 관리하고 UI에 제공하는 뷰모델
@available(iOS 26.0, *)
@MainActor
@Observable
final class FeedViewModel: ObservableObject {
    // MARK: - 프로퍼티
    
    /// 피드 아이템 목록
    private(set) var items: [FeedItem] = []
    
    /// 관련성 점수 맵 (아이템 ID -> 점수)
    private(set) var scores: [UUID: RelevanceScore] = [:]
    
    /// 현재 정렬 옵션
    private(set) var currentSortOption: SortOption = .relevance
    
    /// 로딩 상태
    private(set) var isLoading = false
    
    /// 새로고침 중 상태
    private(set) var isRefreshing = false
    
    /// 에러 메시지
    private(set) var errorMessage: String?
    
    /// 마지막 새로고침 시간
    private(set) var lastRefreshed: Date?
    
    // MARK: - 의존성
    
    private var relevanceManager: RelevanceEngineManager?
    
    // MARK: - 피드 로드
    
    /// 피드 데이터 로드
    func loadFeed(using manager: RelevanceEngineManager) async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        relevanceManager = manager
        
        do {
            // 피드 데이터 가져오기 (시뮬레이션)
            items = await fetchFeedItems()
            
            // 관련성 점수 계산
            scores = await manager.calculateRelevance(for: items)
            
            // 기본 정렬 (관련성순)
            await applySorting()
            
            lastRefreshed = Date()
            isLoading = false
            
            print("✅ 피드 로드 완료: \(items.count)개 아이템")
        } catch {
            isLoading = false
            errorMessage = "피드를 불러올 수 없습니다: \(error.localizedDescription)"
            print("❌ 피드 로드 실패: \(error)")
        }
    }
    
    /// 피드 새로고침
    func refreshFeed() async {
        guard let manager = relevanceManager, !isRefreshing else { return }
        
        isRefreshing = true
        
        // 컨텍스트 업데이트
        await manager.updateUserContext()
        
        // 피드 다시 로드
        items = await fetchFeedItems()
        
        // 관련성 점수 재계산
        scores = await manager.calculateRelevance(for: items)
        
        // 정렬 적용
        await applySorting()
        
        lastRefreshed = Date()
        isRefreshing = false
    }
    
    // MARK: - 정렬
    
    /// 정렬 옵션 설정
    func setSortOption(_ option: SortOption) async {
        currentSortOption = option
        await applySorting()
    }
    
    /// 정렬 적용
    private func applySorting() async {
        switch currentSortOption {
        case .relevance:
            // 관련성 점수 기준 정렬
            items.sort { item1, item2 in
                let score1 = scores[item1.id]?.overallScore ?? 0
                let score2 = scores[item2.id]?.overallScore ?? 0
                return score1 > score2
            }
            
        case .newest:
            // 발행일 기준 정렬 (최신순)
            items.sort { $0.publishedAt > $1.publishedAt }
            
        case .popular:
            // 참여도 기준 정렬
            items.sort { $0.engagement.engagementScore > $1.engagement.engagementScore }
            
        case .trending:
            // 트렌딩 점수 (최근 참여도 + 신선도)
            items.sort { item1, item2 in
                let trending1 = calculateTrendingScore(for: item1)
                let trending2 = calculateTrendingScore(for: item2)
                return trending1 > trending2
            }
        }
    }
    
    /// 트렌딩 점수 계산
    private func calculateTrendingScore(for item: FeedItem) -> Double {
        let engagementScore = item.engagement.engagementScore
        
        // 신선도 계수 (24시간 기준 감쇠)
        let hoursSincePublished = Date().timeIntervalSince(item.publishedAt) / 3600
        let freshnessDecay = max(0, 1 - (hoursSincePublished / 24))
        
        return engagementScore * (1 + freshnessDecay)
    }
    
    // MARK: - 점수 조회
    
    /// 특정 아이템의 관련성 점수 조회
    func getScore(for itemId: UUID) -> RelevanceScore? {
        return scores[itemId]
    }
    
    // MARK: - 상호작용 기록
    
    /// 아이템 조회 기록
    func recordView(for item: FeedItem, at position: Int) async {
        guard let manager = relevanceManager else { return }
        
        let interaction = UserInteraction(
            itemId: item.id,
            type: .view,
            context: InteractionContext(scrollPosition: position)
        )
        
        await manager.recordInteraction(interaction, for: item)
    }
    
    /// 아이템 클릭 기록
    func recordClick(for item: FeedItem) async {
        guard let manager = relevanceManager else { return }
        
        let interaction = UserInteraction(
            itemId: item.id,
            type: .click
        )
        
        await manager.recordInteraction(interaction, for: item)
    }
    
    /// 아이템 읽기 완료 기록
    func recordRead(for item: FeedItem, duration: TimeInterval) async {
        guard let manager = relevanceManager else { return }
        
        let interaction = UserInteraction(
            itemId: item.id,
            type: .read,
            duration: duration
        )
        
        await manager.recordInteraction(interaction, for: item)
        
        // 점수 재계산
        if let newScore = await manager.calculateRelevance(for: item) {
            scores[item.id] = newScore
        }
    }
    
    /// 좋아요 토글
    func toggleLike(for item: FeedItem) async {
        guard let manager = relevanceManager else { return }
        
        // 좋아요 상태 확인 (실제 앱에서는 서버와 동기화)
        let isLiked = false // 샘플에서는 항상 새 좋아요로 처리
        
        let interaction = UserInteraction(
            itemId: item.id,
            type: isLiked ? .unlike : .like
        )
        
        await manager.recordInteraction(interaction, for: item)
    }
    
    /// 북마크 토글
    func toggleBookmark(for item: FeedItem) async {
        guard let manager = relevanceManager else { return }
        
        let isBookmarked = false // 샘플에서는 항상 새 북마크로 처리
        
        let interaction = UserInteraction(
            itemId: item.id,
            type: isBookmarked ? .unbookmark : .bookmark
        )
        
        await manager.recordInteraction(interaction, for: item)
    }
    
    /// 공유 기록
    func recordShare(for item: FeedItem) async {
        guard let manager = relevanceManager else { return }
        
        let interaction = UserInteraction(
            itemId: item.id,
            type: .share
        )
        
        await manager.recordInteraction(interaction, for: item)
    }
    
    /// 숨기기 기록
    func hideItem(_ item: FeedItem) async {
        guard let manager = relevanceManager else { return }
        
        let interaction = UserInteraction(
            itemId: item.id,
            type: .hide
        )
        
        await manager.recordInteraction(interaction, for: item)
        
        // UI에서 제거
        items.removeAll { $0.id == item.id }
        scores.removeValue(forKey: item.id)
    }
    
    // MARK: - 캐시 관리
    
    /// 캐시 지우기
    func clearCache() async {
        scores.removeAll()
        
        // 관련성 점수 재계산
        if let manager = relevanceManager {
            scores = await manager.calculateRelevance(for: items)
        }
    }
    
    // MARK: - 샘플 데이터 생성
    
    /// 피드 아이템 가져오기 (시뮬레이션)
    private func fetchFeedItems() async -> [FeedItem] {
        // 실제 앱에서는 서버에서 가져옴
        // 샘플에서는 목업 데이터 생성
        return createSampleFeedItems()
    }
    
    /// 샘플 피드 아이템 생성
    private func createSampleFeedItems() -> [FeedItem] {
        let now = Date()
        let calendar = Calendar.current
        
        return [
            // 기술 카테고리
            FeedItem(
                title: "iOS 26의 RelevanceKit으로 스마트 피드 만들기",
                summary: "Apple의 새로운 RelevanceKit 프레임워크를 활용하여 사용자 맞춤형 콘텐츠 피드를 구현하는 방법을 알아봅니다.",
                category: .technology,
                contentType: .article,
                author: "Tech Weekly",
                publishedAt: calendar.date(byAdding: .hour, value: -2, to: now)!,
                contentURL: URL(string: "https://example.com/ios26-relevancekit")!,
                readTimeMinutes: 8,
                tags: ["iOS", "Swift", "RelevanceKit", "AI"],
                engagement: EngagementMetrics(views: 1250, likes: 342, shares: 89, comments: 45, bookmarks: 128)
            ),
            
            FeedItem(
                title: "SwiftUI 7의 새로운 애니메이션 시스템 분석",
                summary: "SwiftUI 7에서 도입된 물리 기반 애니메이션과 새로운 전환 효과를 심층 분석합니다.",
                category: .technology,
                contentType: .video,
                author: "Swift Dev",
                publishedAt: calendar.date(byAdding: .hour, value: -5, to: now)!,
                contentURL: URL(string: "https://example.com/swiftui7-animations")!,
                readTimeMinutes: 15,
                tags: ["SwiftUI", "Animation", "iOS"],
                engagement: EngagementMetrics(views: 890, likes: 201, shares: 56, comments: 32, bookmarks: 94)
            ),
            
            // 뉴스 카테고리
            FeedItem(
                title: "Apple, WWDC 2026에서 새로운 AI 기능 발표",
                summary: "Apple이 WWDC 2026에서 발표한 Apple Intelligence 2.0의 주요 기능을 정리했습니다.",
                category: .news,
                contentType: .article,
                author: "Tech News Korea",
                publishedAt: calendar.date(byAdding: .minute, value: -30, to: now)!,
                contentURL: URL(string: "https://example.com/wwdc2026-ai")!,
                readTimeMinutes: 5,
                tags: ["Apple", "WWDC", "AI", "속보"],
                engagement: EngagementMetrics(views: 5420, likes: 892, shares: 345, comments: 156, bookmarks: 234)
            ),
            
            FeedItem(
                title: "글로벌 테크 기업들의 2026년 전망",
                summary: "주요 테크 기업들의 2026년 사업 계획과 시장 전망을 분석합니다.",
                category: .news,
                contentType: .article,
                author: "Business Insight",
                publishedAt: calendar.date(byAdding: .hour, value: -8, to: now)!,
                contentURL: URL(string: "https://example.com/tech-outlook-2026")!,
                readTimeMinutes: 12,
                tags: ["테크", "경제", "전망"],
                engagement: EngagementMetrics(views: 2340, likes: 456, shares: 123, comments: 67, bookmarks: 189)
            ),
            
            // 스포츠 카테고리
            FeedItem(
                title: "K리그 2026 시즌 개막, 주요 이적 소식",
                summary: "2026 K리그 시즌 개막을 앞두고 각 구단의 주요 영입과 이적 소식을 정리했습니다.",
                category: .sports,
                contentType: .article,
                author: "Sports Korea",
                publishedAt: calendar.date(byAdding: .hour, value: -3, to: now)!,
                contentURL: URL(string: "https://example.com/kleague-2026")!,
                readTimeMinutes: 6,
                tags: ["K리그", "축구", "이적"],
                location: FeedLocation(latitude: 37.5683, longitude: 127.0093, name: "서울월드컵경기장", radius: 5000),
                engagement: EngagementMetrics(views: 3210, likes: 567, shares: 145, comments: 234, bookmarks: 89)
            ),
            
            // 음식 카테고리
            FeedItem(
                title: "서울 핫플레이스 브런치 맛집 10선",
                summary: "주말 브런치로 인기 있는 서울의 숨은 맛집들을 소개합니다.",
                category: .food,
                contentType: .article,
                author: "Food Guide",
                publishedAt: calendar.date(byAdding: .hour, value: -6, to: now)!,
                contentURL: URL(string: "https://example.com/seoul-brunch")!,
                readTimeMinutes: 7,
                tags: ["맛집", "브런치", "서울", "주말"],
                location: FeedLocation(latitude: 37.5172, longitude: 127.0473, name: "압구정로데오", radius: 3000),
                engagement: EngagementMetrics(views: 4560, likes: 890, shares: 234, comments: 123, bookmarks: 456)
            ),
            
            FeedItem(
                title: "집에서 만드는 정통 이탈리안 파스타",
                summary: "셰프가 알려주는 정통 이탈리안 파스타 레시피와 팁을 공개합니다.",
                category: .food,
                contentType: .video,
                author: "Chef's Kitchen",
                publishedAt: calendar.date(byAdding: .day, value: -1, to: now)!,
                contentURL: URL(string: "https://example.com/italian-pasta")!,
                readTimeMinutes: 20,
                tags: ["요리", "파스타", "레시피"],
                engagement: EngagementMetrics(views: 7890, likes: 1234, shares: 567, comments: 345, bookmarks: 890)
            ),
            
            // 여행 카테고리
            FeedItem(
                title: "2026년 꼭 가봐야 할 여행지 TOP 5",
                summary: "올해 가장 주목받는 국내외 여행지를 선정했습니다.",
                category: .travel,
                contentType: .article,
                author: "Travel Magazine",
                publishedAt: calendar.date(byAdding: .hour, value: -12, to: now)!,
                contentURL: URL(string: "https://example.com/travel-2026")!,
                readTimeMinutes: 10,
                tags: ["여행", "휴가", "추천"],
                engagement: EngagementMetrics(views: 6780, likes: 1456, shares: 678, comments: 234, bookmarks: 567)
            ),
            
            // 금융 카테고리
            FeedItem(
                title: "2026년 투자 전략: 전문가들의 조언",
                summary: "금융 전문가들이 제안하는 2026년 투자 포트폴리오 구성 전략입니다.",
                category: .finance,
                contentType: .article,
                author: "Finance Today",
                publishedAt: calendar.date(byAdding: .hour, value: -4, to: now)!,
                contentURL: URL(string: "https://example.com/investment-2026")!,
                readTimeMinutes: 15,
                tags: ["투자", "금융", "전략"],
                engagement: EngagementMetrics(views: 3450, likes: 678, shares: 234, comments: 156, bookmarks: 345)
            ),
            
            // 엔터테인먼트 카테고리
            FeedItem(
                title: "넷플릭스 2월 신작 드라마 프리뷰",
                summary: "이번 달 넷플릭스에서 공개되는 화제의 신작 드라마들을 미리 만나보세요.",
                category: .entertainment,
                contentType: .article,
                author: "Entertainment Weekly",
                publishedAt: calendar.date(byAdding: .hour, value: -1, to: now)!,
                contentURL: URL(string: "https://example.com/netflix-feb")!,
                readTimeMinutes: 8,
                tags: ["넷플릭스", "드라마", "신작"],
                engagement: EngagementMetrics(views: 8920, likes: 2345, shares: 890, comments: 567, bookmarks: 678)
            ),
            
            FeedItem(
                title: "K-POP 아이돌 컴백 일정 정리",
                summary: "2월 K-POP 그룹들의 컴백 일정과 앨범 정보를 한눈에 확인하세요.",
                category: .entertainment,
                contentType: .article,
                author: "Music Station",
                publishedAt: calendar.date(byAdding: .hour, value: -7, to: now)!,
                contentURL: URL(string: "https://example.com/kpop-comeback")!,
                readTimeMinutes: 5,
                tags: ["K-POP", "컴백", "아이돌"],
                engagement: EngagementMetrics(views: 12340, likes: 4567, shares: 1234, comments: 890, bookmarks: 1234)
            ),
            
            // 라이프스타일 카테고리
            FeedItem(
                title: "미니멀 라이프를 위한 정리 수납 팁",
                summary: "공간을 효율적으로 활용하는 미니멀리스트의 정리 비법을 공개합니다.",
                category: .lifestyle,
                contentType: .video,
                author: "Life Style Lab",
                publishedAt: calendar.date(byAdding: .day, value: -2, to: now)!,
                contentURL: URL(string: "https://example.com/minimal-life")!,
                readTimeMinutes: 12,
                tags: ["미니멀", "정리", "라이프스타일"],
                engagement: EngagementMetrics(views: 5670, likes: 1234, shares: 456, comments: 234, bookmarks: 567)
            )
        ]
    }
}
