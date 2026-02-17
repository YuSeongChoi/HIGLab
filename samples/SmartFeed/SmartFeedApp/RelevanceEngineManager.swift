// RelevanceEngineManager.swift
// SmartFeed - RelevanceKit 샘플
// RelevanceKit 엔진 관리 및 설정

import Foundation
import RelevanceKit
import CoreLocation
import Observation

// MARK: - RelevanceKit 엔진 매니저
/// RelevanceKit의 RKRelevanceEngine을 관리하고 설정하는 매니저
@available(iOS 26.0, *)
@MainActor
@Observable
final class RelevanceEngineManager: ObservableObject {
    // MARK: - 프로퍼티
    
    /// RelevanceKit 엔진 인스턴스
    private var engine: RKRelevanceEngine?
    
    /// 현재 사용자 컨텍스트
    private(set) var currentContext: UserContext?
    
    /// 엔진 초기화 상태
    private(set) var isInitialized = false
    
    /// 마지막 업데이트 시간
    private(set) var lastUpdated: Date?
    
    // MARK: - 설정 프로퍼티
    
    /// 위치 기반 추천 활성화
    var enableLocationRecommendations = true {
        didSet {
            Task { await updateEngineConfiguration() }
        }
    }
    
    /// 시간 기반 추천 활성화
    var enableTimeRecommendations = true {
        didSet {
            Task { await updateEngineConfiguration() }
        }
    }
    
    /// 행동 학습 활성화
    var enableBehaviorLearning = true {
        didSet {
            Task { await updateEngineConfiguration() }
        }
    }
    
    /// 선호 카테고리
    var preferredCategories: [FeedCategory] = [] {
        didSet {
            Task { await updateEngineConfiguration() }
        }
    }
    
    /// 선호 읽기 시간
    var preferredReadTime: PreferredReadTime = .medium {
        didSet {
            Task { await updateEngineConfiguration() }
        }
    }
    
    // MARK: - 캐시
    
    /// 관련성 점수 캐시 (아이템 ID -> 점수)
    private var scoreCache: [UUID: RelevanceScore] = [:]
    
    /// 캐시 유효 기간 (5분)
    private let cacheValidityDuration: TimeInterval = 300
    
    // MARK: - 초기화
    
    init() {
        // 저장된 설정 불러오기
        loadSavedPreferences()
    }
    
    // MARK: - 엔진 초기화
    
    /// RelevanceKit 엔진 초기화
    func initialize() async {
        guard !isInitialized else { return }
        
        do {
            // 엔진 설정 생성
            let configuration = createEngineConfiguration()
            
            // 엔진 초기화
            engine = try await RKRelevanceEngine(configuration: configuration)
            
            // 사용자 컨텍스트 초기화
            await updateUserContext()
            
            // 행동 학습 데이터 복원
            if enableBehaviorLearning {
                await restoreLearningData()
            }
            
            isInitialized = true
            lastUpdated = Date()
            
            print("✅ RelevanceKit 엔진 초기화 완료")
        } catch {
            print("❌ RelevanceKit 엔진 초기화 실패: \(error)")
        }
    }
    
    // MARK: - 설정 생성
    
    /// 엔진 설정 생성
    private func createEngineConfiguration() -> RKEngineConfiguration {
        var config = RKEngineConfiguration()
        
        // 관련성 계산 설정
        config.enableTemporalRelevance = enableTimeRecommendations
        config.enableSpatialRelevance = enableLocationRecommendations
        config.enableBehavioralLearning = enableBehaviorLearning
        
        // 점수 가중치 설정
        config.weights = RKRelevanceWeights(
            temporal: enableTimeRecommendations ? 1.0 : 0.0,
            spatial: enableLocationRecommendations ? 0.8 : 0.0,
            interest: 1.5,
            behavioral: enableBehaviorLearning ? 1.2 : 0.0,
            freshness: 1.0,
            engagement: 0.7,
            social: 0.5
        )
        
        // 선호 카테고리 설정
        config.preferredCategories = preferredCategories.map { $0.rawValue }
        
        // 콘텐츠 길이 선호 설정
        config.preferredContentLength = preferredReadTime.toRKContentLength()
        
        // 캐시 설정
        config.enableCaching = true
        config.cacheExpirationInterval = cacheValidityDuration
        
        // 개인정보 보호 설정
        config.privacyMode = .standard
        config.dataRetentionDays = 30
        
        return config
    }
    
    // MARK: - 설정 업데이트
    
    /// 엔진 설정 업데이트
    private func updateEngineConfiguration() async {
        guard let engine = engine else { return }
        
        let configuration = createEngineConfiguration()
        
        do {
            try await engine.updateConfiguration(configuration)
            
            // 캐시 무효화
            scoreCache.removeAll()
            
            // 설정 저장
            savePreferences()
            
            print("✅ RelevanceKit 설정 업데이트 완료")
        } catch {
            print("❌ RelevanceKit 설정 업데이트 실패: \(error)")
        }
    }
    
    // MARK: - 사용자 컨텍스트
    
    /// 사용자 컨텍스트 업데이트
    func updateUserContext() async {
        guard let engine = engine else { return }
        
        // 새 컨텍스트 생성
        let context = UserContext(
            timestamp: Date(),
            location: await getCurrentLocation(),
            preferences: createUserPreferences()
        )
        
        currentContext = context
        
        // RelevanceKit에 컨텍스트 전달
        do {
            try await engine.updateContext(context.toRelevanceContext())
            print("✅ 사용자 컨텍스트 업데이트 완료")
        } catch {
            print("❌ 사용자 컨텍스트 업데이트 실패: \(error)")
        }
    }
    
    /// 현재 위치 가져오기 (시뮬레이션)
    private func getCurrentLocation() async -> CLLocation? {
        // 실제 앱에서는 CLLocationManager 사용
        // 샘플에서는 시뮬레이션된 위치 반환
        return CLLocation(latitude: 37.5665, longitude: 126.9780) // 서울 시청
    }
    
    /// 사용자 선호도 생성
    private func createUserPreferences() -> UserPreferences {
        return UserPreferences(
            favoriteCategories: preferredCategories,
            blockedCategories: [],
            preferredReadTime: preferredReadTime,
            enableLocationRecommendations: enableLocationRecommendations,
            enableTimeBasedRecommendations: enableTimeRecommendations,
            enableBehaviorLearning: enableBehaviorLearning
        )
    }
    
    // MARK: - 관련성 점수 계산
    
    /// 단일 아이템의 관련성 점수 계산
    func calculateRelevance(for item: FeedItem) async -> RelevanceScore? {
        guard let engine = engine else { return nil }
        
        // 캐시 확인
        if let cached = scoreCache[item.id],
           Date().timeIntervalSince(cached.computedAt) < cacheValidityDuration {
            return cached
        }
        
        do {
            // RelevanceKit으로 관련성 계산
            let content = item.toRelevanceContent()
            let result = try await engine.calculateRelevance(for: content)
            
            // 점수 변환 및 캐시
            let score = RelevanceScore.from(result: result, for: item.id)
            scoreCache[item.id] = score
            
            return score
        } catch {
            print("❌ 관련성 계산 실패: \(error)")
            return nil
        }
    }
    
    /// 여러 아이템의 관련성 점수 일괄 계산
    func calculateRelevance(for items: [FeedItem]) async -> [UUID: RelevanceScore] {
        guard let engine = engine else { return [:] }
        
        var results: [UUID: RelevanceScore] = [:]
        
        // 캐시된 점수와 새로 계산할 아이템 분리
        var itemsToCalculate: [FeedItem] = []
        
        for item in items {
            if let cached = scoreCache[item.id],
               Date().timeIntervalSince(cached.computedAt) < cacheValidityDuration {
                results[item.id] = cached
            } else {
                itemsToCalculate.append(item)
            }
        }
        
        // 새로 계산이 필요한 아이템 처리
        if !itemsToCalculate.isEmpty {
            let contents = itemsToCalculate.map { $0.toRelevanceContent() }
            
            do {
                // 일괄 계산 API 사용
                let batchResults = try await engine.calculateRelevance(for: contents)
                
                for (index, result) in batchResults.enumerated() {
                    let item = itemsToCalculate[index]
                    let score = RelevanceScore.from(result: result, for: item.id)
                    results[item.id] = score
                    scoreCache[item.id] = score
                }
            } catch {
                print("❌ 일괄 관련성 계산 실패: \(error)")
            }
        }
        
        return results
    }
    
    /// 아이템 정렬 (관련성 순)
    func sortByRelevance(_ items: [FeedItem]) async -> [FeedItem] {
        let scores = await calculateRelevance(for: items)
        
        return items.sorted { item1, item2 in
            let score1 = scores[item1.id]?.overallScore ?? 0
            let score2 = scores[item2.id]?.overallScore ?? 0
            return score1 > score2
        }
    }
    
    // MARK: - 행동 학습
    
    /// 사용자 상호작용 기록
    func recordInteraction(_ interaction: UserInteraction, for item: FeedItem) async {
        guard let engine = engine, enableBehaviorLearning else { return }
        
        do {
            // RelevanceKit에 상호작용 기록
            let rkInteraction = RKUserInteraction(
                contentIdentifier: item.id.uuidString,
                interactionType: mapInteractionType(interaction.type),
                timestamp: interaction.timestamp,
                duration: interaction.duration,
                context: RKInteractionContext(
                    timeOfDay: interaction.context.timeOfDay.toRKTimeOfDay(),
                    dayOfWeek: interaction.context.dayOfWeek.toRKDayOfWeek(),
                    source: mapInteractionSource(interaction.context.source)
                )
            )
            
            try await engine.recordInteraction(rkInteraction)
            
            // 캐시 무효화 (새 상호작용으로 점수가 변경될 수 있음)
            scoreCache.removeValue(forKey: item.id)
            
            print("✅ 상호작용 기록 완료: \(interaction.type)")
        } catch {
            print("❌ 상호작용 기록 실패: \(error)")
        }
    }
    
    /// 상호작용 타입 변환
    private func mapInteractionType(_ type: InteractionType) -> RKInteractionType {
        switch type {
        case .view: return .view
        case .click: return .click
        case .read: return .read
        case .like: return .like
        case .unlike: return .unlike
        case .share: return .share
        case .bookmark: return .bookmark
        case .unbookmark: return .unbookmark
        case .comment: return .comment
        case .hide: return .hide
        case .report: return .report
        }
    }
    
    /// 상호작용 소스 변환
    private func mapInteractionSource(_ source: InteractionSource) -> RKInteractionSource {
        switch source {
        case .feed: return .feed
        case .search: return .search
        case .recommendation: return .recommendation
        case .notification: return .notification
        case .deepLink: return .deepLink
        case .widget: return .widget
        }
    }
    
    // MARK: - 학습 데이터 관리
    
    /// 학습 데이터 복원
    private func restoreLearningData() async {
        guard let engine = engine else { return }
        
        do {
            try await engine.restoreLearningData()
            print("✅ 학습 데이터 복원 완료")
        } catch {
            print("⚠️ 학습 데이터 복원 실패: \(error)")
        }
    }
    
    /// 학습 데이터 초기화
    func resetLearningData() async {
        guard let engine = engine else { return }
        
        do {
            try await engine.resetLearningData()
            scoreCache.removeAll()
            print("✅ 학습 데이터 초기화 완료")
        } catch {
            print("❌ 학습 데이터 초기화 실패: \(error)")
        }
    }
    
    // MARK: - 디버그 정보
    
    /// 현재 엔진 상태 정보
    func getEngineStatus() -> EngineStatus {
        return EngineStatus(
            isInitialized: isInitialized,
            lastUpdated: lastUpdated,
            cacheSize: scoreCache.count,
            enabledFeatures: getEnabledFeatures()
        )
    }
    
    /// 활성화된 기능 목록
    private func getEnabledFeatures() -> [String] {
        var features: [String] = []
        if enableLocationRecommendations { features.append("위치 기반 추천") }
        if enableTimeRecommendations { features.append("시간 기반 추천") }
        if enableBehaviorLearning { features.append("행동 학습") }
        return features
    }
    
    // MARK: - 선호도 저장/불러오기
    
    private let preferencesKey = "SmartFeed.RelevancePreferences"
    
    /// 설정 저장
    private func savePreferences() {
        let preferences = SavedPreferences(
            enableLocationRecommendations: enableLocationRecommendations,
            enableTimeRecommendations: enableTimeRecommendations,
            enableBehaviorLearning: enableBehaviorLearning,
            preferredCategories: preferredCategories.map { $0.rawValue },
            preferredReadTime: preferredReadTime.rawValue
        )
        
        if let data = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(data, forKey: preferencesKey)
        }
    }
    
    /// 설정 불러오기
    private func loadSavedPreferences() {
        guard let data = UserDefaults.standard.data(forKey: preferencesKey),
              let preferences = try? JSONDecoder().decode(SavedPreferences.self, from: data) else {
            return
        }
        
        enableLocationRecommendations = preferences.enableLocationRecommendations
        enableTimeRecommendations = preferences.enableTimeRecommendations
        enableBehaviorLearning = preferences.enableBehaviorLearning
        preferredCategories = preferences.preferredCategories.compactMap { FeedCategory(rawValue: $0) }
        preferredReadTime = PreferredReadTime(rawValue: preferences.preferredReadTime) ?? .medium
    }
    
    /// 카테고리 토글
    func toggleCategory(_ category: FeedCategory) {
        if let index = preferredCategories.firstIndex(of: category) {
            preferredCategories.remove(at: index)
        } else {
            preferredCategories.append(category)
        }
    }
}

// MARK: - 엔진 상태
struct EngineStatus {
    let isInitialized: Bool
    let lastUpdated: Date?
    let cacheSize: Int
    let enabledFeatures: [String]
}

// MARK: - 저장용 설정
private struct SavedPreferences: Codable {
    let enableLocationRecommendations: Bool
    let enableTimeRecommendations: Bool
    let enableBehaviorLearning: Bool
    let preferredCategories: [String]
    let preferredReadTime: String
}
