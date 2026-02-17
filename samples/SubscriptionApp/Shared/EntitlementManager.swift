import SwiftUI

// MARK: - 자격 관리자
// 사용자의 구독 자격(Entitlement)을 관리하는 클래스

/// 구독 기반 기능 접근 권한을 관리하는 ObservableObject
@MainActor
final class EntitlementManager: ObservableObject {
    
    // MARK: - 싱글톤
    
    /// 공유 인스턴스
    static let shared = EntitlementManager()
    
    // MARK: - Published 프로퍼티
    
    /// 현재 구독 티어
    @Published private(set) var currentTier: SubscriptionTier = .none
    
    /// 각 기능별 잠금 해제 상태
    @Published private(set) var unlockedFeatures: Set<Feature> = []
    
    // MARK: - 초기화
    
    private init() {
        // 저장된 자격 상태 복원 (옵션)
        loadSavedEntitlements()
    }
    
    // MARK: - 자격 업데이트
    
    /// 구독 티어에 따라 자격을 업데이트합니다.
    /// - Parameter tier: 새로운 구독 티어
    func updateEntitlement(for tier: SubscriptionTier) {
        currentTier = tier
        updateUnlockedFeatures()
        saveEntitlements()
        
        print("🔓 자격 업데이트: \(tier.displayName)")
    }
    
    /// 티어에 따른 기능 잠금 해제 상태 업데이트
    private func updateUnlockedFeatures() {
        var features: Set<Feature> = []
        
        switch currentTier {
        case .none:
            // 무료 사용자: 기본 기능만
            features = [.basicContent]
            
        case .basic:
            // 기본 구독자: 기본 + 광고 제거 + 일부 프리미엄
            features = [.basicContent, .adFree, .cloudSync, .basicAnalytics]
            
        case .premium:
            // 프리미엄 구독자: 모든 기능
            features = Set(Feature.allCases)
        }
        
        unlockedFeatures = features
    }
    
    // MARK: - 기능 접근 확인
    
    /// 특정 기능에 접근할 수 있는지 확인합니다.
    /// - Parameter feature: 확인할 기능
    /// - Returns: 접근 가능 여부
    func hasAccess(to feature: Feature) -> Bool {
        unlockedFeatures.contains(feature)
    }
    
    /// 특정 티어 이상인지 확인합니다.
    /// - Parameter tier: 필요한 최소 티어
    /// - Returns: 해당 티어 이상 여부
    func hasTier(_ tier: SubscriptionTier) -> Bool {
        currentTier >= tier
    }
    
    /// 프리미엄 기능 접근 가능 여부
    var isPremium: Bool {
        currentTier == .premium
    }
    
    /// 유료 구독자 여부 (기본 또는 프리미엄)
    var isSubscribed: Bool {
        currentTier >= .basic
    }
    
    // MARK: - 로컬 저장/복원
    
    private let entitlementKey = "com.higlab.subscription.entitlement"
    
    /// 자격 상태를 UserDefaults에 저장합니다.
    /// 주의: 서버 검증이 필요한 경우 이 방식만으로는 불충분합니다.
    private func saveEntitlements() {
        UserDefaults.standard.set(currentTier.rawValue, forKey: entitlementKey)
    }
    
    /// 저장된 자격 상태를 복원합니다.
    /// 앱 시작 시 빠른 UI 표시를 위해 사용하며, 이후 서버/StoreKit에서 재검증합니다.
    private func loadSavedEntitlements() {
        let savedValue = UserDefaults.standard.integer(forKey: entitlementKey)
        if let tier = SubscriptionTier(rawValue: savedValue) {
            currentTier = tier
            updateUnlockedFeatures()
        }
    }
}

// MARK: - 기능 정의

/// 앱에서 제공하는 기능 목록
enum Feature: String, CaseIterable, Identifiable {
    // MARK: - 무료 기능
    case basicContent = "기본 콘텐츠"
    
    // MARK: - 기본 구독 기능
    case adFree = "광고 제거"
    case cloudSync = "클라우드 동기화"
    case basicAnalytics = "기본 분석"
    
    // MARK: - 프리미엄 기능
    case advancedAnalytics = "고급 분석"
    case prioritySupport = "우선 지원"
    case exclusiveContent = "독점 콘텐츠"
    case customThemes = "맞춤 테마"
    case offlineMode = "오프라인 모드"
    case exportData = "데이터 내보내기"
    
    var id: String { rawValue }
    
    /// 기능 아이콘
    var icon: String {
        switch self {
        case .basicContent:
            return "doc.text"
        case .adFree:
            return "eye.slash"
        case .cloudSync:
            return "icloud"
        case .basicAnalytics:
            return "chart.bar"
        case .advancedAnalytics:
            return "chart.line.uptrend.xyaxis"
        case .prioritySupport:
            return "person.crop.circle.badge.checkmark"
        case .exclusiveContent:
            return "star.fill"
        case .customThemes:
            return "paintpalette"
        case .offlineMode:
            return "wifi.slash"
        case .exportData:
            return "square.and.arrow.up"
        }
    }
    
    /// 기능 설명
    var description: String {
        switch self {
        case .basicContent:
            return "앱의 기본 콘텐츠에 접근합니다."
        case .adFree:
            return "모든 광고를 제거합니다."
        case .cloudSync:
            return "데이터를 클라우드에 자동 동기화합니다."
        case .basicAnalytics:
            return "기본적인 사용 통계를 확인합니다."
        case .advancedAnalytics:
            return "상세한 분석 및 인사이트를 제공합니다."
        case .prioritySupport:
            return "우선 고객 지원을 받습니다."
        case .exclusiveContent:
            return "프리미엄 전용 콘텐츠에 접근합니다."
        case .customThemes:
            return "앱 테마를 자유롭게 변경합니다."
        case .offlineMode:
            return "오프라인에서도 콘텐츠를 이용합니다."
        case .exportData:
            return "데이터를 다양한 형식으로 내보냅니다."
        }
    }
    
    /// 필요한 최소 티어
    var requiredTier: SubscriptionTier {
        switch self {
        case .basicContent:
            return .none
        case .adFree, .cloudSync, .basicAnalytics:
            return .basic
        case .advancedAnalytics, .prioritySupport, .exclusiveContent,
             .customThemes, .offlineMode, .exportData:
            return .premium
        }
    }
}

// MARK: - SwiftUI 환경 확장

/// 환경에서 자격 관리자에 접근하기 위한 키
private struct EntitlementManagerKey: EnvironmentKey {
    static let defaultValue = EntitlementManager.shared
}

extension EnvironmentValues {
    /// 자격 관리자 환경 값
    var entitlementManager: EntitlementManager {
        get { self[EntitlementManagerKey.self] }
        set { self[EntitlementManagerKey.self] = newValue }
    }
}

// MARK: - 뷰 수정자

/// 특정 기능이 잠겨있을 때 오버레이를 표시하는 뷰 수정자
struct FeatureLockedModifier: ViewModifier {
    let feature: Feature
    @ObservedObject var entitlementManager: EntitlementManager
    
    var isLocked: Bool {
        !entitlementManager.hasAccess(to: feature)
    }
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if isLocked {
                    LockedOverlay(requiredTier: feature.requiredTier)
                }
            }
            .disabled(isLocked)
    }
}

/// 잠금 오버레이 뷰
struct LockedOverlay: View {
    let requiredTier: SubscriptionTier
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
            
            VStack(spacing: 12) {
                Image(systemName: "lock.fill")
                    .font(.largeTitle)
                
                Text("\(requiredTier.displayName) 구독 필요")
                    .font(.headline)
            }
            .foregroundColor(.white)
        }
    }
}

extension View {
    /// 특정 기능이 필요한 뷰에 잠금 오버레이를 추가합니다.
    /// - Parameter feature: 필요한 기능
    /// - Returns: 수정된 뷰
    func requiresFeature(_ feature: Feature) -> some View {
        modifier(FeatureLockedModifier(
            feature: feature,
            entitlementManager: EntitlementManager.shared
        ))
    }
}
