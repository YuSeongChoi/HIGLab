// RelevanceDebugView.swift
// SmartFeed - RelevanceKit 샘플
// 관련성 엔진 디버그 및 분석 뷰

import SwiftUI
import Charts

// MARK: - 관련성 디버그 뷰
/// RelevanceKit 엔진의 상태와 점수를 분석하는 디버그 뷰
@available(iOS 26.0, *)
struct RelevanceDebugView: View {
    @EnvironmentObject var relevanceManager: RelevanceEngineManager
    @EnvironmentObject var feedViewModel: FeedViewModel
    
    @State private var selectedTab: DebugTab = .overview
    @State private var selectedItem: FeedItem?
    
    var body: some View {
        VStack(spacing: 0) {
            // 탭 선택
            Picker("디버그 탭", selection: $selectedTab) {
                ForEach(DebugTab.allCases) { tab in
                    Text(tab.displayName).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            // 탭별 콘텐츠
            TabView(selection: $selectedTab) {
                OverviewTab()
                    .tag(DebugTab.overview)
                
                ScoreDistributionTab()
                    .tag(DebugTab.scores)
                
                ComponentAnalysisTab()
                    .tag(DebugTab.components)
                
                ContextTab()
                    .tag(DebugTab.context)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }
}

// MARK: - 디버그 탭 열거형
enum DebugTab: String, CaseIterable, Identifiable {
    case overview = "overview"
    case scores = "scores"
    case components = "components"
    case context = "context"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .overview: return "개요"
        case .scores: return "점수 분포"
        case .components: return "구성요소"
        case .context: return "컨텍스트"
        }
    }
}

// MARK: - 개요 탭
@available(iOS 26.0, *)
struct OverviewTab: View {
    @EnvironmentObject var relevanceManager: RelevanceEngineManager
    @EnvironmentObject var feedViewModel: FeedViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 엔진 상태 카드
                EngineStatusCard()
                
                // 통계 요약
                StatisticsSummaryCard()
                
                // 활성화된 기능
                EnabledFeaturesCard()
            }
            .padding()
        }
    }
}

// MARK: - 엔진 상태 카드
@available(iOS 26.0, *)
struct EngineStatusCard: View {
    @EnvironmentObject var relevanceManager: RelevanceEngineManager
    
    var engineStatus: EngineStatus {
        relevanceManager.getEngineStatus()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("엔진 상태")
                .font(.headline)
            
            HStack {
                StatusIndicator(
                    isActive: engineStatus.isInitialized,
                    label: "초기화됨"
                )
                
                Spacer()
                
                if let lastUpdated = engineStatus.lastUpdated {
                    Text("업데이트: \(lastUpdated.formatted(date: .omitted, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Divider()
            
            // 캐시 정보
            HStack {
                Label("캐시된 점수", systemImage: "memorychip")
                Spacer()
                Text("\(engineStatus.cacheSize)개")
                    .foregroundStyle(.secondary)
            }
            .font(.subheadline)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 상태 인디케이터
struct StatusIndicator: View {
    let isActive: Bool
    let label: String
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(isActive ? Color.green : Color.red)
                .frame(width: 8, height: 8)
            
            Text(label)
                .font(.subheadline)
        }
    }
}

// MARK: - 통계 요약 카드
@available(iOS 26.0, *)
struct StatisticsSummaryCard: View {
    @EnvironmentObject var feedViewModel: FeedViewModel
    
    var averageScore: Double {
        let scores = feedViewModel.scores.values.map { $0.overallScore }
        guard !scores.isEmpty else { return 0 }
        return scores.reduce(0, +) / Double(scores.count)
    }
    
    var highScoreCount: Int {
        feedViewModel.scores.values.filter { $0.overallScore >= 0.7 }.count
    }
    
    var lowScoreCount: Int {
        feedViewModel.scores.values.filter { $0.overallScore < 0.3 }.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("점수 통계")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatBox(
                    title: "평균 점수",
                    value: String(format: "%.1f%%", averageScore * 100),
                    color: .blue
                )
                
                StatBox(
                    title: "높은 관련성",
                    value: "\(highScoreCount)개",
                    color: .green
                )
                
                StatBox(
                    title: "낮은 관련성",
                    value: "\(lowScoreCount)개",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 통계 박스
struct StatBox: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(color)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - 활성화된 기능 카드
@available(iOS 26.0, *)
struct EnabledFeaturesCard: View {
    @EnvironmentObject var relevanceManager: RelevanceEngineManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("활성화된 기능")
                .font(.headline)
            
            VStack(spacing: 8) {
                FeatureRow(
                    icon: "location.fill",
                    name: "위치 기반 추천",
                    isEnabled: relevanceManager.enableLocationRecommendations
                )
                
                FeatureRow(
                    icon: "clock.fill",
                    name: "시간 기반 추천",
                    isEnabled: relevanceManager.enableTimeRecommendations
                )
                
                FeatureRow(
                    icon: "brain.head.profile",
                    name: "행동 학습",
                    isEnabled: relevanceManager.enableBehaviorLearning
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 기능 행
struct FeatureRow: View {
    let icon: String
    let name: String
    let isEnabled: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(isEnabled ? .blue : .gray)
                .frame(width: 24)
            
            Text(name)
                .font(.subheadline)
            
            Spacer()
            
            Image(systemName: isEnabled ? "checkmark.circle.fill" : "xmark.circle")
                .foregroundStyle(isEnabled ? .green : .gray)
        }
    }
}

// MARK: - 점수 분포 탭
@available(iOS 26.0, *)
struct ScoreDistributionTab: View {
    @EnvironmentObject var feedViewModel: FeedViewModel
    
    var scoreDistribution: [ScoreRange: Int] {
        var distribution: [ScoreRange: Int] = [:]
        for range in ScoreRange.allCases {
            distribution[range] = 0
        }
        
        for score in feedViewModel.scores.values {
            let range = ScoreRange.from(score: score.overallScore)
            distribution[range, default: 0] += 1
        }
        
        return distribution
    }
    
    var chartData: [ScoreChartData] {
        ScoreRange.allCases.map { range in
            ScoreChartData(range: range, count: scoreDistribution[range] ?? 0)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 분포 차트
                VStack(alignment: .leading, spacing: 12) {
                    Text("점수 분포")
                        .font(.headline)
                    
                    Chart(chartData) { data in
                        BarMark(
                            x: .value("범위", data.range.displayName),
                            y: .value("개수", data.count)
                        )
                        .foregroundStyle(data.range.color)
                        .cornerRadius(4)
                    }
                    .frame(height: 200)
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // 점수별 아이템 목록
                VStack(alignment: .leading, spacing: 12) {
                    Text("아이템별 점수")
                        .font(.headline)
                    
                    ForEach(feedViewModel.items.prefix(10)) { item in
                        if let score = feedViewModel.getScore(for: item.id) {
                            ItemScoreRow(item: item, score: score)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
    }
}

// MARK: - 점수 범위
enum ScoreRange: String, CaseIterable {
    case veryHigh = "90-100"
    case high = "70-89"
    case medium = "50-69"
    case low = "30-49"
    case veryLow = "0-29"
    
    var displayName: String { rawValue }
    
    var color: Color {
        switch self {
        case .veryHigh: return .green
        case .high: return .blue
        case .medium: return .orange
        case .low: return .gray
        case .veryLow: return .red
        }
    }
    
    static func from(score: Double) -> ScoreRange {
        switch score {
        case 0.9...1.0: return .veryHigh
        case 0.7..<0.9: return .high
        case 0.5..<0.7: return .medium
        case 0.3..<0.5: return .low
        default: return .veryLow
        }
    }
}

// MARK: - 차트 데이터
struct ScoreChartData: Identifiable {
    let range: ScoreRange
    let count: Int
    
    var id: String { range.rawValue }
}

// MARK: - 아이템 점수 행
@available(iOS 26.0, *)
struct ItemScoreRow: View {
    let item: FeedItem
    let score: RelevanceScore
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.subheadline)
                    .lineLimit(1)
                
                Text(item.category.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // 점수 게이지
            ScoreGauge(score: score.overallScore)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 점수 게이지
struct ScoreGauge: View {
    let score: Double
    
    var body: some View {
        HStack(spacing: 4) {
            // 미니 프로그레스 바
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(.systemGray4))
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(gaugeColor)
                        .frame(width: geo.size.width * score)
                }
            }
            .frame(width: 40, height: 6)
            
            Text(String(format: "%.0f%%", score * 100))
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(gaugeColor)
                .frame(width: 36, alignment: .trailing)
        }
    }
    
    private var gaugeColor: Color {
        switch score {
        case 0.7...1.0: return .green
        case 0.4..<0.7: return .orange
        default: return .red
        }
    }
}

// MARK: - 구성요소 분석 탭
@available(iOS 26.0, *)
struct ComponentAnalysisTab: View {
    @EnvironmentObject var feedViewModel: FeedViewModel
    @State private var selectedItemId: UUID?
    
    var selectedScore: RelevanceScore? {
        guard let id = selectedItemId else { return nil }
        return feedViewModel.getScore(for: id)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 아이템 선택
                VStack(alignment: .leading, spacing: 8) {
                    Text("분석할 아이템 선택")
                        .font(.headline)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(feedViewModel.items.prefix(8)) { item in
                                ItemChip(
                                    item: item,
                                    isSelected: selectedItemId == item.id
                                ) {
                                    selectedItemId = item.id
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // 구성요소 분석
                if let score = selectedScore {
                    ComponentBreakdownCard(components: score.components)
                    
                    ReasonsList(reasons: score.reasons)
                } else {
                    ContentUnavailableView(
                        "아이템을 선택하세요",
                        systemImage: "hand.tap",
                        description: Text("위에서 분석할 아이템을 선택해주세요")
                    )
                }
            }
            .padding()
        }
    }
}

// MARK: - 아이템 칩
struct ItemChip: View {
    let item: FeedItem
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(item.title)
                .font(.caption)
                .lineLimit(1)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color(.systemGray5))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .frame(maxWidth: 150)
    }
}

// MARK: - 구성요소 분해 카드
struct ComponentBreakdownCard: View {
    let components: ScoreComponents
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("점수 구성요소")
                .font(.headline)
            
            ForEach(Array(components.asDictionary.sorted(by: { $0.value > $1.value })), id: \.key) { key, value in
                ComponentRow(name: key, value: value)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 구성요소 행
struct ComponentRow: View {
    let name: String
    let value: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(name)
                    .font(.subheadline)
                
                Spacer()
                
                Text(String(format: "%.1f%%", value * 100))
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray4))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(barColor)
                        .frame(width: geo.size.width * value)
                }
            }
            .frame(height: 8)
        }
    }
    
    private var barColor: Color {
        switch value {
        case 0.7...1.0: return .green
        case 0.4..<0.7: return .blue
        default: return .orange
        }
    }
}

// MARK: - 추천 이유 목록
struct ReasonsList: View {
    let reasons: [RecommendationReason]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("추천 이유")
                .font(.headline)
            
            if reasons.isEmpty {
                Text("추천 이유 정보가 없습니다")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(reasons) { reason in
                    ReasonRow(reason: reason)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 추천 이유 행
struct ReasonRow: View {
    let reason: RecommendationReason
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: reason.type.iconName)
                .foregroundStyle(.accent)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(reason.description)
                    .font(.subheadline)
                
                if let details = reason.details {
                    Text(details)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Text(String(format: "%.0f%%", reason.impact * 100))
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 컨텍스트 탭
@available(iOS 26.0, *)
struct ContextTab: View {
    @EnvironmentObject var relevanceManager: RelevanceEngineManager
    
    var context: UserContext? {
        relevanceManager.currentContext
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let context = context {
                    // 시간 컨텍스트
                    ContextCard(title: "시간 컨텍스트") {
                        ContextRow(label: "시간대", value: context.timeOfDay.displayName)
                        ContextRow(label: "요일", value: context.dayOfWeek.displayName)
                        ContextRow(label: "주말 여부", value: context.dayOfWeek.isWeekend ? "예" : "아니오")
                    }
                    
                    // 위치 컨텍스트
                    ContextCard(title: "위치 컨텍스트") {
                        if let location = context.location {
                            ContextRow(label: "위도", value: String(format: "%.4f", location.coordinate.latitude))
                            ContextRow(label: "경도", value: String(format: "%.4f", location.coordinate.longitude))
                        } else {
                            Text("위치 정보 없음")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    // 활동 컨텍스트
                    ContextCard(title: "활동 컨텍스트") {
                        ContextRow(label: "활동 유형", value: context.activityType.displayName)
                    }
                    
                    // 기기 상태
                    ContextCard(title: "기기 상태") {
                        ContextRow(label: "저전력 모드", value: context.deviceState.isLowPowerMode ? "활성" : "비활성")
                        ContextRow(label: "WiFi 연결", value: context.deviceState.isConnectedToWiFi ? "연결됨" : "연결 안됨")
                        ContextRow(label: "배터리", value: String(format: "%.0f%%", context.deviceState.batteryLevel * 100))
                    }
                } else {
                    ContentUnavailableView(
                        "컨텍스트 없음",
                        systemImage: "exclamationmark.triangle",
                        description: Text("사용자 컨텍스트가 아직 로드되지 않았습니다")
                    )
                }
            }
            .padding()
        }
    }
}

// MARK: - 컨텍스트 카드
struct ContextCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            
            content()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 컨텍스트 행
struct ContextRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}
