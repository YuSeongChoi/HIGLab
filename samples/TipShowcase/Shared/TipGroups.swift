import Foundation
import TipKit

// MARK: - TipKit 팁 그룹화 및 우선순위 관리
// 팁들을 논리적인 그룹으로 분류하고 표시 우선순위를 관리합니다.
// TipGroup을 사용하여 관련 팁들을 함께 관리합니다.

// ============================================================================
// MARK: - 팁 카테고리 정의
// ============================================================================

/// 팁의 카테고리를 정의합니다.
/// 각 카테고리는 관련 팁들의 논리적 그룹을 나타냅니다.
enum TipCategory: String, CaseIterable, Identifiable {
    /// 온보딩 관련 팁
    case onboarding = "onboarding"
    
    /// 기능 발견 관련 팁
    case featureDiscovery = "feature_discovery"
    
    /// 이벤트 기반 팁
    case eventBased = "event_based"
    
    /// 조건부 팁
    case conditional = "conditional"
    
    /// 시간 기반 팁
    case timeBased = "time_based"
    
    /// 고급 기능 팁
    case advanced = "advanced"
    
    /// 프로모션 팁
    case promotional = "promotional"
    
    var id: String { rawValue }
    
    /// 카테고리 표시 이름
    var displayName: String {
        switch self {
        case .onboarding: return "온보딩"
        case .featureDiscovery: return "기능 발견"
        case .eventBased: return "이벤트 기반"
        case .conditional: return "조건부"
        case .timeBased: return "시간 기반"
        case .advanced: return "고급"
        case .promotional: return "프로모션"
        }
    }
    
    /// 카테고리 아이콘
    var iconName: String {
        switch self {
        case .onboarding: return "graduationcap.fill"
        case .featureDiscovery: return "sparkle.magnifyingglass"
        case .eventBased: return "bell.badge.fill"
        case .conditional: return "switch.2"
        case .timeBased: return "clock.fill"
        case .advanced: return "star.fill"
        case .promotional: return "tag.fill"
        }
    }
    
    /// 카테고리 설명
    var description: String {
        switch self {
        case .onboarding:
            return "앱 첫 사용 시 순차적으로 표시되는 안내 팁"
        case .featureDiscovery:
            return "새로운 기능을 발견할 수 있도록 도와주는 팁"
        case .eventBased:
            return "특정 이벤트 발생 후 표시되는 팁"
        case .conditional:
            return "사용자 설정이나 상태에 따라 표시되는 팁"
        case .timeBased:
            return "시간대나 사용 기간에 따라 표시되는 팁"
        case .advanced:
            return "고급 사용자를 위한 전문 기능 팁"
        case .promotional:
            return "프로모션 및 업데이트 안내 팁"
        }
    }
    
    /// 카테고리의 기본 우선순위 (낮을수록 높은 우선순위)
    var defaultPriority: Int {
        switch self {
        case .onboarding: return 1
        case .featureDiscovery: return 2
        case .eventBased: return 3
        case .conditional: return 4
        case .timeBased: return 5
        case .advanced: return 6
        case .promotional: return 7
        }
    }
}

// ============================================================================
// MARK: - 팁 우선순위 레벨
// ============================================================================

/// 팁의 우선순위 레벨
/// 여러 팁이 동시에 표시 가능할 때 어떤 팁을 먼저 보여줄지 결정합니다.
enum TipPriority: Int, CaseIterable, Comparable {
    /// 최고 우선순위 - 즉시 표시 필요
    case critical = 0
    
    /// 높은 우선순위 - 중요한 팁
    case high = 1
    
    /// 일반 우선순위 - 대부분의 팁
    case normal = 2
    
    /// 낮은 우선순위 - 보조 정보
    case low = 3
    
    /// 최저 우선순위 - 선택적 정보
    case minimal = 4
    
    /// 비교 연산자 구현
    static func < (lhs: TipPriority, rhs: TipPriority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    /// 우선순위 표시 이름
    var displayName: String {
        switch self {
        case .critical: return "최고"
        case .high: return "높음"
        case .normal: return "보통"
        case .low: return "낮음"
        case .minimal: return "최저"
        }
    }
}

// ============================================================================
// MARK: - 팁 그룹 정보
// ============================================================================

/// 팁 그룹 정보를 담는 구조체
/// 관련 팁들의 메타데이터를 관리합니다.
struct TipGroupInfo: Identifiable {
    let id: String
    let category: TipCategory
    let priority: TipPriority
    let tips: [any Tip.Type]
    let maxConcurrentTips: Int
    
    /// 그룹 내 팁 개수
    var tipCount: Int { tips.count }
    
    /// 그룹 표시 이름
    var displayName: String { category.displayName }
    
    init(
        id: String,
        category: TipCategory,
        priority: TipPriority = .normal,
        tips: [any Tip.Type],
        maxConcurrentTips: Int = 1
    ) {
        self.id = id
        self.category = category
        self.priority = priority
        self.tips = tips
        self.maxConcurrentTips = maxConcurrentTips
    }
}

// ============================================================================
// MARK: - 팁 그룹 관리자
// ============================================================================

/// 모든 팁 그룹을 관리하는 싱글톤 클래스
/// 팁의 표시 순서, 그룹화, 우선순위를 총괄합니다.
@MainActor
final class TipGroupManager: ObservableObject {
    
    // MARK: - 싱글톤
    
    static let shared = TipGroupManager()
    
    // MARK: - Published 프로퍼티
    
    /// 현재 활성화된 팁 그룹
    @Published private(set) var activeGroup: TipGroupInfo?
    
    /// 현재 표시 중인 팁 카테고리
    @Published private(set) var currentCategory: TipCategory = .onboarding
    
    // MARK: - 팁 그룹 정의
    
    /// 온보딩 팁 그룹
    let onboardingGroup = TipGroupInfo(
        id: "onboarding",
        category: .onboarding,
        priority: .critical,
        tips: [
            WelcomeTip.self,
            FirstFeatureTip.self,
            SecondFeatureTip.self,
            ThirdFeatureTip.self,
            OnboardingCompleteTip.self
        ],
        maxConcurrentTips: 1  // 온보딩은 한 번에 하나씩
    )
    
    /// 기능 발견 팁 그룹
    let featureDiscoveryGroup = TipGroupInfo(
        id: "feature_discovery",
        category: .featureDiscovery,
        priority: .high,
        tips: [
            FavoriteTip.self,
            ShareTip.self,
            SearchTip.self,
            FilterTip.self,
            SortingTip.self
        ],
        maxConcurrentTips: 2  // 기능 발견은 최대 2개 동시 표시
    )
    
    /// 이벤트 기반 팁 그룹
    let eventBasedGroup = TipGroupInfo(
        id: "event_based",
        category: .eventBased,
        priority: .normal,
        tips: [
            ProFeatureTip.self,
            PowerUserTip.self,
            MasterUserTip.self,
            ShareExpertTip.self,
            AdvancedSearchTip.self
        ],
        maxConcurrentTips: 1
    )
    
    /// 조건부 팁 그룹
    let conditionalGroup = TipGroupInfo(
        id: "conditional",
        category: .conditional,
        priority: .normal,
        tips: [
            ProUserExclusiveTip.self,
            BeginnerTip.self,
            ReturningUserTip.self,
            DarkModeTip.self,
            NotificationTip.self
        ],
        maxConcurrentTips: 1
    )
    
    /// 시간 기반 팁 그룹
    let timeBasedGroup = TipGroupInfo(
        id: "time_based",
        category: .timeBased,
        priority: .low,
        tips: [
            MorningTip.self,
            EveningTip.self,
            WeekendTip.self,
            LoyalUserTip.self
        ],
        maxConcurrentTips: 1
    )
    
    /// 고급 기능 팁 그룹
    let advancedGroup = TipGroupInfo(
        id: "advanced",
        category: .advanced,
        priority: .low,
        tips: [
            ShortcutsTip.self,
            SyncTip.self,
            BackupTip.self,
            GestureTip.self
        ],
        maxConcurrentTips: 1
    )
    
    /// 프로모션 팁 그룹
    let promotionalGroup = TipGroupInfo(
        id: "promotional",
        category: .promotional,
        priority: .minimal,
        tips: [
            FeedbackTip.self,
            UpdateTip.self,
            WidgetTip.self
        ],
        maxConcurrentTips: 1
    )
    
    // MARK: - 모든 그룹 목록
    
    /// 모든 팁 그룹을 우선순위 순으로 반환
    var allGroups: [TipGroupInfo] {
        [
            onboardingGroup,
            featureDiscoveryGroup,
            eventBasedGroup,
            conditionalGroup,
            timeBasedGroup,
            advancedGroup,
            promotionalGroup
        ].sorted { $0.priority < $1.priority }
    }
    
    /// 카테고리별 그룹 조회
    func group(for category: TipCategory) -> TipGroupInfo? {
        allGroups.first { $0.category == category }
    }
    
    // MARK: - 초기화
    
    private init() {
        activeGroup = onboardingGroup
    }
    
    // MARK: - 그룹 전환
    
    /// 다음 팁 그룹으로 전환
    func advanceToNextGroup() {
        guard let current = activeGroup,
              let currentIndex = allGroups.firstIndex(where: { $0.id == current.id }),
              currentIndex < allGroups.count - 1 else {
            return
        }
        
        activeGroup = allGroups[currentIndex + 1]
        currentCategory = activeGroup?.category ?? .onboarding
        print("📋 팁 그룹 전환: \(activeGroup?.displayName ?? "없음")")
    }
    
    /// 특정 카테고리의 그룹으로 전환
    func switchToCategory(_ category: TipCategory) {
        if let group = group(for: category) {
            activeGroup = group
            currentCategory = category
            print("📋 팁 카테고리 전환: \(category.displayName)")
        }
    }
    
    /// 온보딩 완료 후 기능 발견 그룹으로 전환
    func completeOnboarding() {
        switchToCategory(.featureDiscovery)
    }
}

// ============================================================================
// MARK: - 팁 표시 순서 관리
// ============================================================================

/// 팁의 표시 순서를 관리하는 스케줄러
@MainActor
final class TipScheduler: ObservableObject {
    
    // MARK: - 싱글톤
    
    static let shared = TipScheduler()
    
    // MARK: - 프로퍼티
    
    /// 표시 대기 중인 팁 큐
    @Published private(set) var pendingTips: [any Tip] = []
    
    /// 현재 표시 중인 팁
    @Published private(set) var currentTip: (any Tip)?
    
    /// 최근 표시된 팁 기록 (중복 방지용)
    private var recentlyShownTipIds: Set<String> = []
    
    /// 최대 보관할 최근 표시 기록 수
    private let maxRecentHistory = 10
    
    // MARK: - 초기화
    
    private init() {}
    
    // MARK: - 팁 스케줄링
    
    /// 팁을 대기열에 추가
    func scheduleTip<T: Tip>(_ tip: T, priority: TipPriority = .normal) {
        let tipId = String(describing: type(of: tip))
        
        // 중복 체크
        guard !recentlyShownTipIds.contains(tipId) else {
            print("⚠️ 최근 표시된 팁 스킵: \(tipId)")
            return
        }
        
        pendingTips.append(tip)
        
        // 우선순위에 따라 정렬 (현재는 추가 순서 유지)
        sortPendingTips()
        
        print("📥 팁 스케줄됨: \(tipId)")
    }
    
    /// 대기열의 다음 팁 표시
    func showNextTip() -> (any Tip)? {
        guard !pendingTips.isEmpty else { return nil }
        
        let tip = pendingTips.removeFirst()
        currentTip = tip
        
        let tipId = String(describing: type(of: tip))
        recordTipShown(tipId)
        
        print("📤 팁 표시: \(tipId)")
        return tip
    }
    
    /// 현재 팁 닫기
    func dismissCurrentTip() {
        currentTip = nil
    }
    
    /// 대기열 정렬 (우선순위 기반)
    private func sortPendingTips() {
        // 현재는 추가 순서 유지
        // 필요 시 우선순위 기반 정렬 로직 추가
    }
    
    /// 팁 표시 기록
    private func recordTipShown(_ tipId: String) {
        recentlyShownTipIds.insert(tipId)
        
        // 최대 기록 수 초과 시 오래된 것 제거
        while recentlyShownTipIds.count > maxRecentHistory {
            // Set은 순서가 없으므로 임의 제거 (실제로는 시간 기반 관리 필요)
            recentlyShownTipIds.removeFirst()
        }
    }
    
    /// 기록 초기화
    func clearHistory() {
        recentlyShownTipIds.removeAll()
        pendingTips.removeAll()
        currentTip = nil
        print("🗑️ 팁 스케줄러 초기화")
    }
}

// ============================================================================
// MARK: - 팁 통계
// ============================================================================

/// 팁 표시 통계를 관리합니다.
@MainActor
final class TipStatistics: ObservableObject {
    
    static let shared = TipStatistics()
    
    /// 카테고리별 표시 횟수
    @Published var categoryShowCounts: [TipCategory: Int] = [:]
    
    /// 총 표시 횟수
    @Published var totalShowCount: Int = 0
    
    /// 액션 클릭 횟수
    @Published var actionClickCount: Int = 0
    
    /// 닫기 횟수
    @Published var dismissCount: Int = 0
    
    private init() {
        // 각 카테고리 초기화
        for category in TipCategory.allCases {
            categoryShowCounts[category] = 0
        }
    }
    
    /// 팁 표시 기록
    func recordTipShown(category: TipCategory) {
        categoryShowCounts[category, default: 0] += 1
        totalShowCount += 1
    }
    
    /// 액션 클릭 기록
    func recordActionClick() {
        actionClickCount += 1
    }
    
    /// 닫기 기록
    func recordDismiss() {
        dismissCount += 1
    }
    
    /// 통계 요약
    var summary: String {
        """
        === 팁 통계 ===
        총 표시: \(totalShowCount)회
        액션 클릭: \(actionClickCount)회
        닫기: \(dismissCount)회
        
        카테고리별:
        \(categoryShowCounts.map { "- \($0.key.displayName): \($0.value)회" }.joined(separator: "\n"))
        """
    }
    
    /// 통계 초기화
    func reset() {
        for category in TipCategory.allCases {
            categoryShowCounts[category] = 0
        }
        totalShowCount = 0
        actionClickCount = 0
        dismissCount = 0
    }
}
