import Foundation
import TipKit

// MARK: - TipKit 파라미터 정의
// @Parameter 속성 래퍼를 사용하여 팁의 표시 조건을 동적으로 제어합니다.
// 파라미터 값이 변경되면 관련 팁의 규칙이 자동으로 재평가됩니다.

// ============================================================================
// MARK: - 사용자 상태 파라미터
// ============================================================================

/// 사용자의 온보딩 완료 상태
/// 온보딩 시퀀스의 각 단계 완료 여부를 추적합니다.
struct OnboardingParameters {
    
    /// 환영 화면 확인 여부
    @Parameter
    static var hasSeenWelcome: Bool = false
    
    /// 첫 번째 기능 소개 확인 여부
    @Parameter
    static var hasSeenFirstFeature: Bool = false
    
    /// 두 번째 기능 소개 확인 여부
    @Parameter
    static var hasSeenSecondFeature: Bool = false
    
    /// 세 번째 기능 소개 확인 여부
    @Parameter
    static var hasSeenThirdFeature: Bool = false
    
    /// 온보딩 완료 여부
    @Parameter
    static var hasCompletedOnboarding: Bool = false
    
    /// 현재 온보딩 단계 (0-4)
    static var currentStep: Int {
        var step = 0
        if hasSeenWelcome { step += 1 }
        if hasSeenFirstFeature { step += 1 }
        if hasSeenSecondFeature { step += 1 }
        if hasSeenThirdFeature { step += 1 }
        if hasCompletedOnboarding { step += 1 }
        return step
    }
    
    /// 모든 온보딩 파라미터 초기화
    static func reset() {
        hasSeenWelcome = false
        hasSeenFirstFeature = false
        hasSeenSecondFeature = false
        hasSeenThirdFeature = false
        hasCompletedOnboarding = false
    }
    
    /// 온보딩 진행률 (0.0 ~ 1.0)
    static var progress: Double {
        Double(currentStep) / 5.0
    }
}

// ============================================================================
// MARK: - 기능 발견 파라미터
// ============================================================================

/// 사용자가 발견한 기능들을 추적합니다.
/// 각 기능의 발견 여부에 따라 관련 팁의 표시가 결정됩니다.
struct FeatureDiscoveryParameters {
    
    /// 즐겨찾기 기능 사용 여부
    @Parameter
    static var hasUsedFavorites: Bool = false
    
    /// 공유 기능 사용 여부
    @Parameter
    static var hasUsedSharing: Bool = false
    
    /// 검색 기능 사용 여부
    @Parameter
    static var hasUsedSearch: Bool = false
    
    /// 필터 기능 사용 여부
    @Parameter
    static var hasUsedFilters: Bool = false
    
    /// 정렬 기능 사용 여부
    @Parameter
    static var hasUsedSorting: Bool = false
    
    /// 다크 모드 토글 여부
    @Parameter
    static var hasToggledDarkMode: Bool = false
    
    /// 알림 설정 변경 여부
    @Parameter
    static var hasConfiguredNotifications: Bool = false
    
    /// 프로필 편집 여부
    @Parameter
    static var hasEditedProfile: Bool = false
    
    /// 발견한 기능 개수
    static var discoveredFeaturesCount: Int {
        var count = 0
        if hasUsedFavorites { count += 1 }
        if hasUsedSharing { count += 1 }
        if hasUsedSearch { count += 1 }
        if hasUsedFilters { count += 1 }
        if hasUsedSorting { count += 1 }
        if hasToggledDarkMode { count += 1 }
        if hasConfiguredNotifications { count += 1 }
        if hasEditedProfile { count += 1 }
        return count
    }
    
    /// 모든 기능 발견 파라미터 초기화
    static func reset() {
        hasUsedFavorites = false
        hasUsedSharing = false
        hasUsedSearch = false
        hasUsedFilters = false
        hasUsedSorting = false
        hasToggledDarkMode = false
        hasConfiguredNotifications = false
        hasEditedProfile = false
    }
    
    /// 기능 발견 진행률
    static var progress: Double {
        Double(discoveredFeaturesCount) / 8.0
    }
}

// ============================================================================
// MARK: - 사용자 설정 파라미터
// ============================================================================

/// 사용자의 앱 설정 상태
/// 설정에 따라 조건부로 팁을 표시합니다.
struct UserSettingsParameters {
    
    /// 프로 사용자 여부
    @Parameter
    static var isProUser: Bool = false
    
    /// 팁 표시 활성화 여부
    @Parameter
    static var tipsEnabled: Bool = true
    
    /// 상세 팁 표시 여부 (더 자세한 설명 포함)
    @Parameter
    static var showDetailedTips: Bool = true
    
    /// 고급 기능 활성화 여부
    @Parameter
    static var advancedFeaturesEnabled: Bool = false
    
    /// 사용자 경험 수준 (0: 초보, 1: 중급, 2: 고급)
    @Parameter
    static var userExperienceLevel: Int = 0
    
    /// 마지막 앱 사용일 (Unix timestamp)
    @Parameter
    static var lastAppUsageTimestamp: Double = 0
    
    /// 앱 실행 횟수
    @Parameter
    static var appLaunchCount: Int = 0
    
    /// 사용자 경험 레벨 설명
    static var experienceLevelDescription: String {
        switch userExperienceLevel {
        case 0: return "초보"
        case 1: return "중급"
        case 2: return "고급"
        default: return "알 수 없음"
        }
    }
    
    /// 새로운 사용자 여부 (실행 횟수 5회 미만)
    static var isNewUser: Bool {
        appLaunchCount < 5
    }
    
    /// 복귀 사용자 여부 (7일 이상 미사용 후 복귀)
    static var isReturningUser: Bool {
        guard lastAppUsageTimestamp > 0 else { return false }
        let lastUsage = Date(timeIntervalSince1970: lastAppUsageTimestamp)
        let daysSinceLastUsage = Calendar.current.dateComponents(
            [.day],
            from: lastUsage,
            to: Date()
        ).day ?? 0
        return daysSinceLastUsage >= 7
    }
    
    /// 현재 시간으로 마지막 사용일 업데이트
    static func updateLastUsage() {
        lastAppUsageTimestamp = Date().timeIntervalSince1970
    }
    
    /// 앱 실행 횟수 증가
    static func incrementLaunchCount() {
        appLaunchCount += 1
    }
    
    /// 모든 사용자 설정 파라미터 초기화
    static func reset() {
        isProUser = false
        tipsEnabled = true
        showDetailedTips = true
        advancedFeaturesEnabled = false
        userExperienceLevel = 0
        lastAppUsageTimestamp = 0
        appLaunchCount = 0
    }
}

// ============================================================================
// MARK: - 시간 기반 파라미터
// ============================================================================

/// 시간과 날짜에 기반한 팁 조건을 관리합니다.
struct TimeBasedParameters {
    
    /// 앱 설치 후 경과 일수
    @Parameter
    static var daysSinceInstall: Int = 0
    
    /// 이번 주 앱 사용 일수
    @Parameter
    static var daysUsedThisWeek: Int = 0
    
    /// 연속 사용 일수 (스트릭)
    @Parameter
    static var consecutiveUsageDays: Int = 0
    
    /// 현재 시간대 (0-23)
    @Parameter
    static var currentHour: Int = 0
    
    /// 주중 여부 (평일: true, 주말: false)
    @Parameter
    static var isWeekday: Bool = true
    
    /// 아침 시간대 여부 (6-12시)
    static var isMorning: Bool {
        currentHour >= 6 && currentHour < 12
    }
    
    /// 오후 시간대 여부 (12-18시)
    static var isAfternoon: Bool {
        currentHour >= 12 && currentHour < 18
    }
    
    /// 저녁 시간대 여부 (18-22시)
    static var isEvening: Bool {
        currentHour >= 18 && currentHour < 22
    }
    
    /// 밤 시간대 여부 (22-6시)
    static var isNight: Bool {
        currentHour >= 22 || currentHour < 6
    }
    
    /// 장기 사용자 여부 (30일 이상 사용)
    static var isLongTermUser: Bool {
        daysSinceInstall >= 30
    }
    
    /// 열성 사용자 여부 (일주일에 5일 이상 사용)
    static var isActiveUser: Bool {
        daysUsedThisWeek >= 5
    }
    
    /// 현재 시간 정보로 파라미터 업데이트
    static func updateCurrentTime() {
        let now = Calendar.current.component(.hour, from: Date())
        currentHour = now
        
        let weekday = Calendar.current.component(.weekday, from: Date())
        isWeekday = weekday >= 2 && weekday <= 6  // 월요일(2) ~ 금요일(6)
    }
    
    /// 모든 시간 기반 파라미터 초기화
    static func reset() {
        daysSinceInstall = 0
        daysUsedThisWeek = 0
        consecutiveUsageDays = 0
        currentHour = 0
        isWeekday = true
    }
}

// ============================================================================
// MARK: - 통합 파라미터 관리자
// ============================================================================

/// 모든 팁 파라미터를 통합 관리하는 유틸리티
enum TipParametersManager {
    
    /// 모든 파라미터 초기화
    static func resetAll() {
        OnboardingParameters.reset()
        FeatureDiscoveryParameters.reset()
        UserSettingsParameters.reset()
        TimeBasedParameters.reset()
        print("✅ 모든 팁 파라미터가 초기화되었습니다.")
    }
    
    /// 앱 시작 시 필요한 파라미터 업데이트
    static func updateOnAppLaunch() {
        // 시간 정보 업데이트
        TimeBasedParameters.updateCurrentTime()
        
        // 앱 실행 횟수 증가
        UserSettingsParameters.incrementLaunchCount()
        
        // 마지막 사용일 업데이트
        UserSettingsParameters.updateLastUsage()
        
        print("📊 앱 실행 파라미터 업데이트 완료")
    }
    
    /// 현재 파라미터 상태 요약
    static var statusSummary: String {
        """
        === 팁 파라미터 상태 ===
        
        [온보딩]
        - 진행률: \(Int(OnboardingParameters.progress * 100))%
        - 현재 단계: \(OnboardingParameters.currentStep)/5
        
        [기능 발견]
        - 발견 개수: \(FeatureDiscoveryParameters.discoveredFeaturesCount)/8
        - 진행률: \(Int(FeatureDiscoveryParameters.progress * 100))%
        
        [사용자 설정]
        - 프로 사용자: \(UserSettingsParameters.isProUser)
        - 경험 수준: \(UserSettingsParameters.experienceLevelDescription)
        - 앱 실행 횟수: \(UserSettingsParameters.appLaunchCount)
        
        [시간 기반]
        - 설치 후 일수: \(TimeBasedParameters.daysSinceInstall)
        - 연속 사용일: \(TimeBasedParameters.consecutiveUsageDays)
        - 현재 시간대: \(TimeBasedParameters.currentHour)시
        """
    }
    
    /// 디버그 정보 출력
    static func printDebugInfo() {
        print(statusSummary)
    }
}
