// RelevanceScore.swift
// SmartFeed - RelevanceKit 샘플
// 관련성 점수 및 추천 이유 모델

import Foundation
import RelevanceKit

// MARK: - 관련성 점수
/// RelevanceKit에서 계산된 콘텐츠 관련성 점수
@available(iOS 26.0, *)
struct RelevanceScore: Identifiable, Hashable {
    let id: UUID
    let itemId: UUID                    // 연관된 피드 아이템 ID
    let overallScore: Double            // 종합 점수 (0.0 ~ 1.0)
    let components: ScoreComponents     // 세부 점수 구성요소
    let reasons: [RecommendationReason] // 추천 이유 목록
    let computedAt: Date                // 점수 계산 시점
    let confidence: Double              // 신뢰도 (0.0 ~ 1.0)
    
    init(
        id: UUID = UUID(),
        itemId: UUID,
        overallScore: Double,
        components: ScoreComponents,
        reasons: [RecommendationReason],
        computedAt: Date = Date(),
        confidence: Double = 1.0
    ) {
        self.id = id
        self.itemId = itemId
        self.overallScore = max(0, min(1, overallScore))
        self.components = components
        self.reasons = reasons
        self.computedAt = computedAt
        self.confidence = max(0, min(1, confidence))
    }
    
    /// 점수를 백분율 문자열로 반환
    var percentageString: String {
        return "\(Int(overallScore * 100))%"
    }
    
    /// 점수 등급 반환
    var grade: ScoreGrade {
        switch overallScore {
        case 0.9...1.0: return .excellent
        case 0.7..<0.9: return .good
        case 0.5..<0.7: return .average
        case 0.3..<0.5: return .low
        default: return .veryLow
        }
    }
}

// MARK: - 점수 등급
/// 관련성 점수의 등급
enum ScoreGrade {
    case excellent  // 매우 높음
    case good       // 높음
    case average    // 보통
    case low        // 낮음
    case veryLow    // 매우 낮음
    
    var displayName: String {
        switch self {
        case .excellent: return "매우 관련 높음"
        case .good: return "관련 높음"
        case .average: return "보통"
        case .low: return "관련 낮음"
        case .veryLow: return "매우 관련 낮음"
        }
    }
    
    var color: String {
        switch self {
        case .excellent: return "green"
        case .good: return "blue"
        case .average: return "orange"
        case .low: return "gray"
        case .veryLow: return "red"
        }
    }
}

// MARK: - 점수 구성요소
/// 관련성 점수를 구성하는 세부 요소
struct ScoreComponents: Hashable {
    let timeRelevance: Double       // 시간 관련성 (0.0 ~ 1.0)
    let locationRelevance: Double   // 위치 관련성 (0.0 ~ 1.0)
    let interestMatch: Double       // 관심사 일치도 (0.0 ~ 1.0)
    let behaviorMatch: Double       // 행동 패턴 일치도 (0.0 ~ 1.0)
    let freshness: Double           // 콘텐츠 신선도 (0.0 ~ 1.0)
    let engagement: Double          // 참여도 점수 (0.0 ~ 1.0)
    let socialSignal: Double        // 소셜 시그널 (0.0 ~ 1.0)
    
    /// 기본 초기화
    init(
        timeRelevance: Double = 0.0,
        locationRelevance: Double = 0.0,
        interestMatch: Double = 0.0,
        behaviorMatch: Double = 0.0,
        freshness: Double = 0.0,
        engagement: Double = 0.0,
        socialSignal: Double = 0.0
    ) {
        self.timeRelevance = max(0, min(1, timeRelevance))
        self.locationRelevance = max(0, min(1, locationRelevance))
        self.interestMatch = max(0, min(1, interestMatch))
        self.behaviorMatch = max(0, min(1, behaviorMatch))
        self.freshness = max(0, min(1, freshness))
        self.engagement = max(0, min(1, engagement))
        self.socialSignal = max(0, min(1, socialSignal))
    }
    
    /// 가중치가 적용된 종합 점수 계산
    func calculateWeightedScore(weights: ScoreWeights = .default) -> Double {
        let total = timeRelevance * weights.time +
                    locationRelevance * weights.location +
                    interestMatch * weights.interest +
                    behaviorMatch * weights.behavior +
                    freshness * weights.freshness +
                    engagement * weights.engagement +
                    socialSignal * weights.social
        
        let weightSum = weights.time + weights.location + weights.interest +
                        weights.behavior + weights.freshness + weights.engagement +
                        weights.social
        
        return total / weightSum
    }
    
    /// 모든 구성요소를 딕셔너리로 반환
    var asDictionary: [String: Double] {
        return [
            "시간 관련성": timeRelevance,
            "위치 관련성": locationRelevance,
            "관심사 일치": interestMatch,
            "행동 패턴": behaviorMatch,
            "신선도": freshness,
            "참여도": engagement,
            "소셜 시그널": socialSignal
        ]
    }
}

// MARK: - 점수 가중치
/// 각 점수 구성요소의 가중치
struct ScoreWeights {
    var time: Double        // 시간 가중치
    var location: Double    // 위치 가중치
    var interest: Double    // 관심사 가중치
    var behavior: Double    // 행동 가중치
    var freshness: Double   // 신선도 가중치
    var engagement: Double  // 참여도 가중치
    var social: Double      // 소셜 가중치
    
    /// 기본 가중치
    static let `default` = ScoreWeights(
        time: 1.0,
        location: 0.8,
        interest: 1.5,
        behavior: 1.2,
        freshness: 1.0,
        engagement: 0.7,
        social: 0.5
    )
    
    /// 출퇴근 시간대 가중치 (속보/뉴스 중심)
    static let commute = ScoreWeights(
        time: 1.5,
        location: 1.2,
        interest: 1.0,
        behavior: 0.8,
        freshness: 1.8,
        engagement: 0.5,
        social: 0.3
    )
    
    /// 여가 시간대 가중치 (관심사 중심)
    static let leisure = ScoreWeights(
        time: 0.5,
        location: 0.5,
        interest: 2.0,
        behavior: 1.5,
        freshness: 0.7,
        engagement: 1.0,
        social: 1.0
    )
}

// MARK: - 추천 이유
/// 콘텐츠가 추천된 이유
struct RecommendationReason: Identifiable, Hashable {
    let id: UUID
    let type: ReasonType        // 이유 타입
    let description: String     // 설명
    let impact: Double          // 영향도 (0.0 ~ 1.0)
    let details: String?        // 상세 정보
    
    init(
        id: UUID = UUID(),
        type: ReasonType,
        description: String,
        impact: Double,
        details: String? = nil
    ) {
        self.id = id
        self.type = type
        self.description = description
        self.impact = max(0, min(1, impact))
        self.details = details
    }
}

// MARK: - 추천 이유 타입
/// 추천 이유의 카테고리
enum ReasonType: String, CaseIterable {
    case timeOfDay = "time_of_day"          // 시간대 기반
    case location = "location"               // 위치 기반
    case interest = "interest"               // 관심사 기반
    case behavior = "behavior"               // 행동 패턴 기반
    case trending = "trending"               // 인기/트렌딩
    case similar = "similar"                 // 유사 콘텐츠
    case social = "social"                   // 소셜 추천
    case personalized = "personalized"       // 개인화
    
    var iconName: String {
        switch self {
        case .timeOfDay: return "clock.fill"
        case .location: return "location.fill"
        case .interest: return "heart.fill"
        case .behavior: return "chart.line.uptrend.xyaxis"
        case .trending: return "flame.fill"
        case .similar: return "square.on.square"
        case .social: return "person.2.fill"
        case .personalized: return "person.crop.circle.fill"
        }
    }
    
    var displayName: String {
        switch self {
        case .timeOfDay: return "시간대 기반"
        case .location: return "위치 기반"
        case .interest: return "관심사 기반"
        case .behavior: return "행동 패턴"
        case .trending: return "인기 콘텐츠"
        case .similar: return "유사 콘텐츠"
        case .social: return "소셜 추천"
        case .personalized: return "개인화 추천"
        }
    }
}

// MARK: - RKRelevanceResult 변환 확장
@available(iOS 26.0, *)
extension RelevanceScore {
    /// RKRelevanceResult에서 RelevanceScore로 변환
    static func from(
        result: RKRelevanceResult,
        for itemId: UUID
    ) -> RelevanceScore {
        // 세부 점수 추출
        let components = ScoreComponents(
            timeRelevance: result.temporalRelevance,
            locationRelevance: result.spatialRelevance,
            interestMatch: result.interestRelevance,
            behaviorMatch: result.behavioralRelevance,
            freshness: result.freshnessScore,
            engagement: result.engagementScore,
            socialSignal: result.socialScore
        )
        
        // 추천 이유 변환
        let reasons = result.explanations.map { explanation in
            RecommendationReason(
                type: mapExplanationType(explanation.type),
                description: explanation.localizedDescription,
                impact: explanation.contributionWeight,
                details: explanation.additionalContext
            )
        }
        
        return RelevanceScore(
            itemId: itemId,
            overallScore: result.overallScore,
            components: components,
            reasons: reasons,
            computedAt: Date(),
            confidence: result.confidence
        )
    }
    
    /// RKExplanationType을 ReasonType으로 변환
    private static func mapExplanationType(_ type: RKExplanationType) -> ReasonType {
        switch type {
        case .temporal: return .timeOfDay
        case .spatial: return .location
        case .interest: return .interest
        case .behavioral: return .behavior
        case .trending: return .trending
        case .contentSimilarity: return .similar
        case .social: return .social
        case .personalized: return .personalized
        @unknown default: return .personalized
        }
    }
}
