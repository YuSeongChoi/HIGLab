// RecommendationReasonView.swift
// SmartFeed - RelevanceKit 샘플
// 추천 이유 상세 표시 뷰

import SwiftUI
import Charts

// MARK: - 추천 이유 뷰
/// 특정 콘텐츠가 추천된 이유를 상세하게 표시하는 뷰
@available(iOS 26.0, *)
struct RecommendationReasonView: View {
    let item: FeedItem
    let score: RelevanceScore
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 아이템 요약
                    ItemSummarySection(item: item)
                    
                    // 종합 점수
                    OverallScoreSection(score: score)
                    
                    // 점수 구성요소 차트
                    ScoreComponentsChart(components: score.components)
                    
                    // 추천 이유 상세
                    RecommendationReasonsSection(reasons: score.reasons)
                    
                    // 신뢰도 정보
                    ConfidenceSection(confidence: score.confidence, computedAt: score.computedAt)
                }
                .padding()
            }
            .navigationTitle("추천 이유")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - 아이템 요약 섹션
struct ItemSummarySection: View {
    let item: FeedItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 카테고리 배지
            HStack(spacing: 8) {
                Image(systemName: item.category.iconName)
                Text(item.category.displayName)
            }
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.accentColor)
            .clipShape(Capsule())
            
            // 제목
            Text(item.title)
                .font(.headline)
            
            // 작성자 및 시간
            HStack {
                Text(item.author)
                Text("·")
                Text(item.timeAgo)
                Text("·")
                HStack(spacing: 2) {
                    Image(systemName: "clock")
                    Text(item.readTimeDisplay)
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - 종합 점수 섹션
@available(iOS 26.0, *)
struct OverallScoreSection: View {
    let score: RelevanceScore
    
    var body: some View {
        VStack(spacing: 16) {
            Text("관련성 점수")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            // 큰 점수 표시
            ZStack {
                Circle()
                    .stroke(Color(.systemGray4), lineWidth: 12)
                
                Circle()
                    .trim(from: 0, to: score.overallScore)
                    .stroke(scoreColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 4) {
                    Text(score.percentageString)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                    
                    Text(score.grade.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 140, height: 140)
            .animation(.easeInOut, value: score.overallScore)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var scoreColor: Color {
        switch score.grade {
        case .excellent: return .green
        case .good: return .blue
        case .average: return .orange
        case .low: return .gray
        case .veryLow: return .red
        }
    }
}

// MARK: - 점수 구성요소 차트
struct ScoreComponentsChart: View {
    let components: ScoreComponents
    
    var chartData: [ComponentChartData] {
        [
            ComponentChartData(name: "시간 관련성", value: components.timeRelevance, color: .blue),
            ComponentChartData(name: "위치 관련성", value: components.locationRelevance, color: .green),
            ComponentChartData(name: "관심사 일치", value: components.interestMatch, color: .purple),
            ComponentChartData(name: "행동 패턴", value: components.behaviorMatch, color: .orange),
            ComponentChartData(name: "신선도", value: components.freshness, color: .cyan),
            ComponentChartData(name: "참여도", value: components.engagement, color: .pink),
            ComponentChartData(name: "소셜 시그널", value: components.socialSignal, color: .indigo)
        ]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("점수 구성요소")
                .font(.headline)
            
            // 레이더 차트 스타일의 바 차트
            VStack(spacing: 12) {
                ForEach(chartData.sorted(by: { $0.value > $1.value })) { data in
                    ComponentBar(data: data)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - 차트 데이터 모델
struct ComponentChartData: Identifiable {
    let name: String
    let value: Double
    let color: Color
    
    var id: String { name }
}

// MARK: - 구성요소 바
struct ComponentBar: View {
    let data: ComponentChartData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(data.name)
                    .font(.subheadline)
                
                Spacer()
                
                Text(String(format: "%.0f%%", data.value * 100))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(data.color)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray4))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(data.color)
                        .frame(width: geo.size.width * data.value)
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - 추천 이유 섹션
struct RecommendationReasonsSection: View {
    let reasons: [RecommendationReason]
    
    var sortedReasons: [RecommendationReason] {
        reasons.sorted { $0.impact > $1.impact }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("추천 이유")
                .font(.headline)
            
            if reasons.isEmpty {
                EmptyReasonsView()
            } else {
                ForEach(sortedReasons) { reason in
                    ReasonCard(reason: reason)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - 빈 이유 뷰
struct EmptyReasonsView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.title)
                .foregroundStyle(.secondary)
            
            Text("추천 이유 정보가 없습니다")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text("관련성 점수는 여러 요소를 종합하여 계산됩니다")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

// MARK: - 이유 카드
struct ReasonCard: View {
    let reason: RecommendationReason
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // 아이콘
            ZStack {
                Circle()
                    .fill(iconBackgroundColor)
                    .frame(width: 40, height: 40)
                
                Image(systemName: reason.type.iconName)
                    .foregroundStyle(.white)
            }
            
            // 내용
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(reason.type.displayName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    // 영향도 배지
                    ImpactBadge(impact: reason.impact)
                }
                
                Text(reason.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                if let details = reason.details {
                    Text(details)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .padding(.top, 2)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var iconBackgroundColor: Color {
        switch reason.type {
        case .timeOfDay: return .blue
        case .location: return .green
        case .interest: return .purple
        case .behavior: return .orange
        case .trending: return .red
        case .similar: return .cyan
        case .social: return .pink
        case .personalized: return .indigo
        }
    }
}

// MARK: - 영향도 배지
struct ImpactBadge: View {
    let impact: Double
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: impactIcon)
            Text(String(format: "%.0f%%", impact * 100))
        }
        .font(.caption)
        .fontWeight(.medium)
        .foregroundStyle(impactColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(impactColor.opacity(0.15))
        .clipShape(Capsule())
    }
    
    private var impactIcon: String {
        switch impact {
        case 0.7...1.0: return "arrow.up.circle.fill"
        case 0.4..<0.7: return "equal.circle.fill"
        default: return "arrow.down.circle.fill"
        }
    }
    
    private var impactColor: Color {
        switch impact {
        case 0.7...1.0: return .green
        case 0.4..<0.7: return .orange
        default: return .gray
        }
    }
}

// MARK: - 신뢰도 섹션
struct ConfidenceSection: View {
    let confidence: Double
    let computedAt: Date
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                // 신뢰도
                VStack(alignment: .leading, spacing: 4) {
                    Text("신뢰도")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: confidenceIcon)
                        Text(String(format: "%.0f%%", confidence * 100))
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(confidenceColor)
                }
                
                Spacer()
                
                // 계산 시간
                VStack(alignment: .trailing, spacing: 4) {
                    Text("계산 시간")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(computedAt.formatted(date: .omitted, time: .shortened))
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
            
            // 신뢰도 설명
            Text(confidenceDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var confidenceIcon: String {
        switch confidence {
        case 0.8...1.0: return "checkmark.shield.fill"
        case 0.5..<0.8: return "shield.fill"
        default: return "exclamationmark.shield.fill"
        }
    }
    
    private var confidenceColor: Color {
        switch confidence {
        case 0.8...1.0: return .green
        case 0.5..<0.8: return .orange
        default: return .red
        }
    }
    
    private var confidenceDescription: String {
        switch confidence {
        case 0.8...1.0:
            return "충분한 사용자 데이터를 기반으로 높은 신뢰도의 추천입니다."
        case 0.5..<0.8:
            return "일부 데이터를 기반으로 한 추천입니다. 더 많은 상호작용으로 정확도가 향상됩니다."
        default:
            return "데이터가 부족하여 일반적인 추천을 제공합니다. 앱을 더 사용하시면 개인화됩니다."
        }
    }
}

// MARK: - 미리보기
@available(iOS 26.0, *)
#Preview {
    let sampleItem = FeedItem(
        title: "iOS 26의 RelevanceKit으로 스마트 피드 만들기",
        summary: "Apple의 새로운 RelevanceKit 프레임워크를 활용하여 사용자 맞춤형 콘텐츠 피드를 구현하는 방법을 알아봅니다.",
        category: .technology,
        contentType: .article,
        author: "Tech Weekly",
        publishedAt: Date(),
        contentURL: URL(string: "https://example.com")!,
        readTimeMinutes: 8,
        tags: ["iOS", "Swift", "RelevanceKit"]
    )
    
    let sampleScore = RelevanceScore(
        itemId: sampleItem.id,
        overallScore: 0.85,
        components: ScoreComponents(
            timeRelevance: 0.9,
            locationRelevance: 0.7,
            interestMatch: 0.95,
            behaviorMatch: 0.8,
            freshness: 0.85,
            engagement: 0.6,
            socialSignal: 0.5
        ),
        reasons: [
            RecommendationReason(
                type: .interest,
                description: "관심 카테고리 '기술'과 일치합니다",
                impact: 0.9,
                details: "최근 기술 관련 콘텐츠를 자주 읽으셨습니다"
            ),
            RecommendationReason(
                type: .timeOfDay,
                description: "아침 시간대에 자주 읽는 유형의 콘텐츠입니다",
                impact: 0.7
            ),
            RecommendationReason(
                type: .behavior,
                description: "유사한 주제의 콘텐츠를 북마크하셨습니다",
                impact: 0.65
            )
        ],
        confidence: 0.88
    )
    
    return RecommendationReasonView(item: sampleItem, score: sampleScore)
}
