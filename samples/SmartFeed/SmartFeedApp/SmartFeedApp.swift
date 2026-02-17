// SmartFeedApp.swift
// SmartFeed - RelevanceKit 샘플
// 앱 진입점 및 환경 설정

import SwiftUI
import RelevanceKit

// MARK: - 앱 진입점
@main
@available(iOS 26.0, *)
struct SmartFeedApp: App {
    // MARK: - 상태 객체
    @StateObject private var relevanceManager = RelevanceEngineManager()
    @StateObject private var feedViewModel = FeedViewModel()
    
    // MARK: - 앱 씬 설정
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(relevanceManager)
                .environmentObject(feedViewModel)
                .task {
                    // 앱 시작 시 RelevanceKit 엔진 초기화
                    await relevanceManager.initialize()
                    
                    // 피드 데이터 로드
                    await feedViewModel.loadFeed(using: relevanceManager)
                }
        }
    }
}

// MARK: - 메인 콘텐츠 뷰
@available(iOS 26.0, *)
struct ContentView: View {
    @EnvironmentObject var relevanceManager: RelevanceEngineManager
    @EnvironmentObject var feedViewModel: FeedViewModel
    
    @State private var selectedTab: TabSelection = .feed
    @State private var showDebugView = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 메인 피드 탭
            NavigationStack {
                FeedView()
                    .navigationTitle("SmartFeed")
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                showDebugView = true
                            } label: {
                                Image(systemName: "ant.fill")
                            }
                        }
                        
                        ToolbarItem(placement: .topBarTrailing) {
                            Menu {
                                ForEach(SortOption.allCases) { option in
                                    Button {
                                        Task {
                                            await feedViewModel.setSortOption(option)
                                        }
                                    } label: {
                                        if feedViewModel.currentSortOption == option {
                                            Label(option.displayName, systemImage: "checkmark")
                                        } else {
                                            Text(option.displayName)
                                        }
                                    }
                                }
                            } label: {
                                Image(systemName: "arrow.up.arrow.down")
                            }
                        }
                    }
            }
            .tag(TabSelection.feed)
            .tabItem {
                Label("피드", systemImage: "rectangle.stack.fill")
            }
            
            // 탐색 탭
            NavigationStack {
                ExploreView()
                    .navigationTitle("탐색")
            }
            .tag(TabSelection.explore)
            .tabItem {
                Label("탐색", systemImage: "magnifyingglass")
            }
            
            // 설정 탭
            NavigationStack {
                SettingsView()
                    .navigationTitle("설정")
            }
            .tag(TabSelection.settings)
            .tabItem {
                Label("설정", systemImage: "gearshape.fill")
            }
        }
        .sheet(isPresented: $showDebugView) {
            NavigationStack {
                RelevanceDebugView()
                    .navigationTitle("관련성 디버그")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("닫기") {
                                showDebugView = false
                            }
                        }
                    }
            }
        }
    }
}

// MARK: - 탭 선택
enum TabSelection: Hashable {
    case feed
    case explore
    case settings
}

// MARK: - 정렬 옵션
enum SortOption: String, CaseIterable, Identifiable {
    case relevance = "relevance"        // 관련성순
    case newest = "newest"              // 최신순
    case popular = "popular"            // 인기순
    case trending = "trending"          // 트렌딩
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .relevance: return "관련성순"
        case .newest: return "최신순"
        case .popular: return "인기순"
        case .trending: return "트렌딩"
        }
    }
}

// MARK: - 탐색 뷰
@available(iOS 26.0, *)
struct ExploreView: View {
    @EnvironmentObject var feedViewModel: FeedViewModel
    @State private var searchText = ""
    @State private var selectedCategory: FeedCategory?
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // 카테고리 선택
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(FeedCategory.allCases) { category in
                            CategoryChip(
                                category: category,
                                isSelected: selectedCategory == category
                            ) {
                                if selectedCategory == category {
                                    selectedCategory = nil
                                } else {
                                    selectedCategory = category
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // 카테고리별 콘텐츠
                if let category = selectedCategory {
                    let items = feedViewModel.items.filter { $0.category == category }
                    
                    ForEach(items) { item in
                        FeedItemView(
                            item: item,
                            score: feedViewModel.getScore(for: item.id)
                        )
                        .padding(.horizontal)
                    }
                } else {
                    // 모든 카테고리의 인기 콘텐츠
                    ForEach(FeedCategory.allCases) { category in
                        CategorySection(category: category)
                    }
                }
            }
            .padding(.vertical)
        }
        .searchable(text: $searchText, prompt: "콘텐츠 검색")
    }
}

// MARK: - 카테고리 칩
struct CategoryChip: View {
    let category: FeedCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.iconName)
                Text(category.displayName)
            }
            .font(.subheadline)
            .fontWeight(isSelected ? .semibold : .regular)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor : Color(.systemGray6))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
    }
}

// MARK: - 카테고리 섹션
@available(iOS 26.0, *)
struct CategorySection: View {
    @EnvironmentObject var feedViewModel: FeedViewModel
    let category: FeedCategory
    
    var items: [FeedItem] {
        feedViewModel.items
            .filter { $0.category == category }
            .prefix(3)
            .map { $0 }
    }
    
    var body: some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: category.iconName)
                    Text(category.displayName)
                        .font(.headline)
                    Spacer()
                    Button("더보기") {}
                        .font(.subheadline)
                }
                .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(items) { item in
                            CompactFeedItemView(item: item)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

// MARK: - 설정 뷰
@available(iOS 26.0, *)
struct SettingsView: View {
    @EnvironmentObject var relevanceManager: RelevanceEngineManager
    @EnvironmentObject var feedViewModel: FeedViewModel
    
    var body: some View {
        List {
            Section("관련성 엔진") {
                Toggle("위치 기반 추천", isOn: $relevanceManager.enableLocationRecommendations)
                Toggle("시간 기반 추천", isOn: $relevanceManager.enableTimeRecommendations)
                Toggle("행동 학습", isOn: $relevanceManager.enableBehaviorLearning)
            }
            
            Section("콘텐츠 선호도") {
                NavigationLink("관심 카테고리") {
                    CategoryPreferenceView()
                }
                
                NavigationLink("콘텐츠 길이 선호") {
                    ContentLengthPreferenceView()
                }
            }
            
            Section("데이터") {
                Button("학습 데이터 초기화") {
                    Task {
                        await relevanceManager.resetLearningData()
                    }
                }
                .foregroundStyle(.red)
                
                Button("캐시 지우기") {
                    Task {
                        await feedViewModel.clearCache()
                    }
                }
            }
            
            Section("정보") {
                LabeledContent("앱 버전", value: "1.0.0")
                LabeledContent("RelevanceKit", value: "iOS 26")
            }
        }
    }
}

// MARK: - 카테고리 선호도 뷰
@available(iOS 26.0, *)
struct CategoryPreferenceView: View {
    @EnvironmentObject var relevanceManager: RelevanceEngineManager
    
    var body: some View {
        List {
            ForEach(FeedCategory.allCases) { category in
                HStack {
                    Image(systemName: category.iconName)
                    Text(category.displayName)
                    Spacer()
                    if relevanceManager.preferredCategories.contains(category) {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.accent)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    relevanceManager.toggleCategory(category)
                }
            }
        }
        .navigationTitle("관심 카테고리")
    }
}

// MARK: - 콘텐츠 길이 선호도 뷰
@available(iOS 26.0, *)
struct ContentLengthPreferenceView: View {
    @EnvironmentObject var relevanceManager: RelevanceEngineManager
    
    var body: some View {
        List {
            ForEach(PreferredReadTime.allCases, id: \.self) { readTime in
                HStack {
                    Text(readTime.displayName)
                    Spacer()
                    if relevanceManager.preferredReadTime == readTime {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.accent)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    relevanceManager.preferredReadTime = readTime
                }
            }
        }
        .navigationTitle("콘텐츠 길이")
    }
}

// MARK: - 간략한 피드 아이템 뷰
struct CompactFeedItemView: View {
    let item: FeedItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 썸네일
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray5))
                .frame(width: 160, height: 100)
                .overlay {
                    Image(systemName: item.contentType.iconName)
                        .font(.title)
                        .foregroundStyle(.secondary)
                }
            
            // 제목
            Text(item.title)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(2)
            
            // 메타 정보
            HStack {
                Text(item.author)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text(item.timeAgo)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 160)
    }
}
