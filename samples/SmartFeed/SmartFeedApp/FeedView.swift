// FeedView.swift
// SmartFeed - RelevanceKit 샘플
// 메인 피드 UI

import SwiftUI

// MARK: - 피드 뷰
/// 관련성 기반으로 정렬된 피드를 표시하는 메인 뷰
@available(iOS 26.0, *)
struct FeedView: View {
    @EnvironmentObject var feedViewModel: FeedViewModel
    @EnvironmentObject var relevanceManager: RelevanceEngineManager
    
    @State private var selectedItem: FeedItem?
    @State private var showReasonSheet = false
    @State private var selectedScore: RelevanceScore?
    
    var body: some View {
        Group {
            if feedViewModel.isLoading {
                LoadingView()
            } else if let error = feedViewModel.errorMessage {
                ErrorView(message: error) {
                    Task {
                        await feedViewModel.refreshFeed()
                    }
                }
            } else {
                feedContent
            }
        }
        .sheet(isPresented: $showReasonSheet) {
            if let score = selectedScore, let item = selectedItem {
                RecommendationReasonView(item: item, score: score)
                    .presentationDetents([.medium, .large])
            }
        }
    }
    
    // MARK: - 피드 콘텐츠
    
    private var feedContent: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // 피드 헤더
                FeedHeaderView(
                    lastRefreshed: feedViewModel.lastRefreshed,
                    sortOption: feedViewModel.currentSortOption
                )
                .padding(.horizontal)
                
                // 피드 아이템
                ForEach(Array(feedViewModel.items.enumerated()), id: \.element.id) { index, item in
                    let score = feedViewModel.getScore(for: item.id)
                    
                    FeedItemView(item: item, score: score)
                        .padding(.horizontal)
                        .onAppear {
                            // 아이템 노출 기록
                            Task {
                                await feedViewModel.recordView(for: item, at: index)
                            }
                        }
                        .onTapGesture {
                            // 클릭 기록 및 상세 보기
                            Task {
                                await feedViewModel.recordClick(for: item)
                            }
                            selectedItem = item
                        }
                        .contextMenu {
                            itemContextMenu(for: item, score: score)
                        }
                }
                
                // 로드 중 표시
                if feedViewModel.isRefreshing {
                    ProgressView()
                        .padding()
                }
            }
            .padding(.vertical)
        }
        .refreshable {
            await feedViewModel.refreshFeed()
        }
    }
    
    // MARK: - 컨텍스트 메뉴
    
    @ViewBuilder
    private func itemContextMenu(for item: FeedItem, score: RelevanceScore?) -> some View {
        Button {
            Task { await feedViewModel.toggleLike(for: item) }
        } label: {
            Label("좋아요", systemImage: "heart")
        }
        
        Button {
            Task { await feedViewModel.toggleBookmark(for: item) }
        } label: {
            Label("북마크", systemImage: "bookmark")
        }
        
        Button {
            Task { await feedViewModel.recordShare(for: item) }
        } label: {
            Label("공유", systemImage: "square.and.arrow.up")
        }
        
        Divider()
        
        if let score = score {
            Button {
                selectedItem = item
                selectedScore = score
                showReasonSheet = true
            } label: {
                Label("추천 이유 보기", systemImage: "questionmark.circle")
            }
        }
        
        Button(role: .destructive) {
            Task { await feedViewModel.hideItem(item) }
        } label: {
            Label("숨기기", systemImage: "eye.slash")
        }
    }
}

// MARK: - 피드 헤더 뷰
@available(iOS 26.0, *)
struct FeedHeaderView: View {
    let lastRefreshed: Date?
    let sortOption: SortOption
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("맞춤 피드")
                    .font(.title2)
                    .fontWeight(.bold)
                
                if let lastRefreshed = lastRefreshed {
                    Text("업데이트: \(lastRefreshed.formatted(date: .omitted, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // 현재 정렬 옵션 표시
            HStack(spacing: 4) {
                Image(systemName: sortOptionIcon)
                Text(sortOption.displayName)
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(.systemGray6))
            .clipShape(Capsule())
        }
    }
    
    private var sortOptionIcon: String {
        switch sortOption {
        case .relevance: return "sparkles"
        case .newest: return "clock"
        case .popular: return "flame"
        case .trending: return "chart.line.uptrend.xyaxis"
        }
    }
}

// MARK: - 로딩 뷰
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("피드 로딩 중...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - 에러 뷰
struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange)
            
            Text("오류 발생")
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("다시 시도") {
                retryAction()
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - 피드 아이템 뷰
@available(iOS 26.0, *)
struct FeedItemView: View {
    let item: FeedItem
    let score: RelevanceScore?
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 상단 메타 정보
            HStack(spacing: 8) {
                // 카테고리 배지
                HStack(spacing: 4) {
                    Image(systemName: item.category.iconName)
                    Text(item.category.displayName)
                }
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(categoryColor)
                .clipShape(Capsule())
                
                // 콘텐츠 타입 아이콘
                Image(systemName: item.contentType.iconName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                // 관련성 점수 배지
                if let score = score {
                    RelevanceScoreBadge(score: score)
                }
            }
            
            // 썸네일 (있는 경우)
            if item.imageURL != nil {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray5))
                    .frame(height: 180)
                    .overlay {
                        Image(systemName: item.contentType.iconName)
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                    }
            }
            
            // 제목
            Text(item.title)
                .font(.headline)
                .lineLimit(isExpanded ? nil : 2)
            
            // 요약
            Text(item.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(isExpanded ? nil : 3)
            
            // 태그
            if !item.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(item.tags.prefix(4), id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption)
                                .foregroundStyle(.accent)
                        }
                    }
                }
            }
            
            // 하단 메타 정보
            HStack {
                // 작성자
                Text(item.author)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text("·")
                    .foregroundStyle(.secondary)
                
                // 발행 시간
                Text(item.timeAgo)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text("·")
                    .foregroundStyle(.secondary)
                
                // 읽기 시간
                HStack(spacing: 2) {
                    Image(systemName: "clock")
                    Text(item.readTimeDisplay)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                
                Spacer()
                
                // 참여 지표
                EngagementIndicators(engagement: item.engagement)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
    
    private var categoryColor: Color {
        switch item.category {
        case .news: return .red
        case .entertainment: return .purple
        case .sports: return .green
        case .technology: return .blue
        case .lifestyle: return .pink
        case .food: return .orange
        case .travel: return .cyan
        case .finance: return .indigo
        }
    }
}

// MARK: - 관련성 점수 배지
@available(iOS 26.0, *)
struct RelevanceScoreBadge: View {
    let score: RelevanceScore
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "sparkles")
            Text(score.percentageString)
        }
        .font(.caption)
        .fontWeight(.semibold)
        .foregroundStyle(badgeColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(badgeColor.opacity(0.15))
        .clipShape(Capsule())
    }
    
    private var badgeColor: Color {
        switch score.grade {
        case .excellent: return .green
        case .good: return .blue
        case .average: return .orange
        case .low: return .gray
        case .veryLow: return .red
        }
    }
}

// MARK: - 참여 지표 표시
struct EngagementIndicators: View {
    let engagement: EngagementMetrics
    
    var body: some View {
        HStack(spacing: 12) {
            EngagementItem(icon: "heart.fill", count: engagement.likes)
            EngagementItem(icon: "bubble.right.fill", count: engagement.comments)
        }
    }
}

// MARK: - 참여 지표 아이템
struct EngagementItem: View {
    let icon: String
    let count: Int
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: icon)
            Text(formattedCount)
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }
    
    private var formattedCount: String {
        if count >= 1000 {
            return String(format: "%.1fK", Double(count) / 1000)
        }
        return "\(count)"
    }
}
