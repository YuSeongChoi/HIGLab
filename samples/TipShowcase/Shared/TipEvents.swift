import Foundation
import TipKit

// MARK: - TipKit 이벤트 정의
// Tips.Event를 사용하여 사용자 행동을 추적합니다.
// 이벤트는 donate()를 통해 기록되며, #Rule에서 조건으로 사용됩니다.

// ============================================================================
// MARK: - 앱 생명주기 이벤트
// ============================================================================

/// 앱 생명주기 관련 이벤트
/// 앱 시작, 종료, 백그라운드 전환 등을 추적합니다.
enum AppLifecycleEvents {
    
    /// 앱이 시작될 때 발생하는 이벤트
    /// ProTip 등에서 "앱을 n번 사용 후" 조건에 활용
    static let appLaunched = Tips.Event(id: "com.tipshowcase.event.appLaunched")
    
    /// 앱이 포그라운드로 돌아올 때 발생하는 이벤트
    static let appBecameActive = Tips.Event(id: "com.tipshowcase.event.appBecameActive")
    
    /// 앱이 백그라운드로 갈 때 발생하는 이벤트
    static let appResignedActive = Tips.Event(id: "com.tipshowcase.event.appResignedActive")
    
    /// 세션이 시작될 때 발생하는 이벤트
    static let sessionStarted = Tips.Event(id: "com.tipshowcase.event.sessionStarted")
    
    /// 세션이 종료될 때 발생하는 이벤트
    static let sessionEnded = Tips.Event(id: "com.tipshowcase.event.sessionEnded")
}

// ============================================================================
// MARK: - 화면 탐색 이벤트
// ============================================================================

/// 화면 탐색 관련 이벤트
/// 사용자가 특정 화면을 방문할 때 발생합니다.
enum ScreenNavigationEvents {
    
    /// 메인 화면 방문
    static let mainScreenViewed = Tips.Event(id: "com.tipshowcase.event.mainScreenViewed")
    
    /// 설정 화면 방문
    static let settingsScreenViewed = Tips.Event(id: "com.tipshowcase.event.settingsScreenViewed")
    
    /// 프로필 화면 방문
    static let profileScreenViewed = Tips.Event(id: "com.tipshowcase.event.profileScreenViewed")
    
    /// 상세 화면 방문
    static let detailScreenViewed = Tips.Event(id: "com.tipshowcase.event.detailScreenViewed")
    
    /// 검색 화면 방문
    static let searchScreenViewed = Tips.Event(id: "com.tipshowcase.event.searchScreenViewed")
    
    /// 온보딩 화면 방문
    static let onboardingScreenViewed = Tips.Event(id: "com.tipshowcase.event.onboardingScreenViewed")
    
    /// 도움말 화면 방문
    static let helpScreenViewed = Tips.Event(id: "com.tipshowcase.event.helpScreenViewed")
}

// ============================================================================
// MARK: - 기능 사용 이벤트
// ============================================================================

/// 기능 사용 관련 이벤트
/// 사용자가 특정 기능을 사용할 때 발생합니다.
enum FeatureUsageEvents {
    
    /// 즐겨찾기 추가/제거
    static let favoriteToggled = Tips.Event(id: "com.tipshowcase.event.favoriteToggled")
    
    /// 콘텐츠 공유
    static let contentShared = Tips.Event(id: "com.tipshowcase.event.contentShared")
    
    /// 검색 실행
    static let searchPerformed = Tips.Event(id: "com.tipshowcase.event.searchPerformed")
    
    /// 필터 적용
    static let filterApplied = Tips.Event(id: "com.tipshowcase.event.filterApplied")
    
    /// 정렬 변경
    static let sortingChanged = Tips.Event(id: "com.tipshowcase.event.sortingChanged")
    
    /// 아이템 생성
    static let itemCreated = Tips.Event(id: "com.tipshowcase.event.itemCreated")
    
    /// 아이템 삭제
    static let itemDeleted = Tips.Event(id: "com.tipshowcase.event.itemDeleted")
    
    /// 아이템 편집
    static let itemEdited = Tips.Event(id: "com.tipshowcase.event.itemEdited")
    
    /// 다운로드 시작
    static let downloadStarted = Tips.Event(id: "com.tipshowcase.event.downloadStarted")
    
    /// 업로드 완료
    static let uploadCompleted = Tips.Event(id: "com.tipshowcase.event.uploadCompleted")
}

// ============================================================================
// MARK: - 사용자 상호작용 이벤트
// ============================================================================

/// 사용자 상호작용 관련 이벤트
/// 버튼 탭, 스와이프 등의 상호작용을 추적합니다.
enum UserInteractionEvents {
    
    /// 버튼 탭
    static let buttonTapped = Tips.Event(id: "com.tipshowcase.event.buttonTapped")
    
    /// 스와이프 제스처
    static let swipePerformed = Tips.Event(id: "com.tipshowcase.event.swipePerformed")
    
    /// 롱프레스 제스처
    static let longPressPerformed = Tips.Event(id: "com.tipshowcase.event.longPressPerformed")
    
    /// 더블 탭 제스처
    static let doubleTapPerformed = Tips.Event(id: "com.tipshowcase.event.doubleTapPerformed")
    
    /// 핀치 줌 제스처
    static let pinchZoomPerformed = Tips.Event(id: "com.tipshowcase.event.pinchZoomPerformed")
    
    /// 풀투리프레시
    static let pullToRefreshTriggered = Tips.Event(id: "com.tipshowcase.event.pullToRefreshTriggered")
    
    /// 스크롤 완료 (끝까지 스크롤)
    static let scrolledToEnd = Tips.Event(id: "com.tipshowcase.event.scrolledToEnd")
    
    /// 탭 전환
    static let tabSwitched = Tips.Event(id: "com.tipshowcase.event.tabSwitched")
}

// ============================================================================
// MARK: - 성취 및 마일스톤 이벤트
// ============================================================================

/// 성취 및 마일스톤 관련 이벤트
/// 특정 목표 달성 시 발생합니다.
enum AchievementEvents {
    
    /// 첫 번째 아이템 생성
    static let firstItemCreated = Tips.Event(id: "com.tipshowcase.event.firstItemCreated")
    
    /// 10개 아이템 생성
    static let tenItemsCreated = Tips.Event(id: "com.tipshowcase.event.tenItemsCreated")
    
    /// 첫 번째 공유
    static let firstShare = Tips.Event(id: "com.tipshowcase.event.firstShare")
    
    /// 프로필 완성
    static let profileCompleted = Tips.Event(id: "com.tipshowcase.event.profileCompleted")
    
    /// 일주일 연속 사용
    static let weekStreak = Tips.Event(id: "com.tipshowcase.event.weekStreak")
    
    /// 한 달 연속 사용
    static let monthStreak = Tips.Event(id: "com.tipshowcase.event.monthStreak")
    
    /// 모든 기능 발견
    static let allFeaturesDiscovered = Tips.Event(id: "com.tipshowcase.event.allFeaturesDiscovered")
}

// ============================================================================
// MARK: - 온보딩 이벤트
// ============================================================================

/// 온보딩 관련 이벤트
/// 온보딩 시퀀스 진행을 추적합니다.
enum OnboardingEvents {
    
    /// 온보딩 시작
    static let onboardingStarted = Tips.Event(id: "com.tipshowcase.event.onboardingStarted")
    
    /// 온보딩 1단계 완료
    static let onboardingStep1Completed = Tips.Event(id: "com.tipshowcase.event.onboardingStep1Completed")
    
    /// 온보딩 2단계 완료
    static let onboardingStep2Completed = Tips.Event(id: "com.tipshowcase.event.onboardingStep2Completed")
    
    /// 온보딩 3단계 완료
    static let onboardingStep3Completed = Tips.Event(id: "com.tipshowcase.event.onboardingStep3Completed")
    
    /// 온보딩 스킵
    static let onboardingSkipped = Tips.Event(id: "com.tipshowcase.event.onboardingSkipped")
    
    /// 온보딩 완료
    static let onboardingCompleted = Tips.Event(id: "com.tipshowcase.event.onboardingCompleted")
}

// ============================================================================
// MARK: - 이벤트 기록 헬퍼
// ============================================================================

/// 이벤트 기록을 위한 통합 헬퍼
/// async/await 패턴으로 이벤트를 기록합니다.
@MainActor
enum TipEventRecorder {
    
    // MARK: - 앱 생명주기 이벤트 기록
    
    /// 앱 시작 이벤트 기록
    static func recordAppLaunched() async {
        await AppLifecycleEvents.appLaunched.donate()
        print("📱 이벤트 기록: 앱 시작")
    }
    
    /// 앱 활성화 이벤트 기록
    static func recordAppBecameActive() async {
        await AppLifecycleEvents.appBecameActive.donate()
        print("📱 이벤트 기록: 앱 활성화")
    }
    
    /// 세션 시작 이벤트 기록
    static func recordSessionStarted() async {
        await AppLifecycleEvents.sessionStarted.donate()
        print("📱 이벤트 기록: 세션 시작")
    }
    
    // MARK: - 화면 탐색 이벤트 기록
    
    /// 메인 화면 방문 기록
    static func recordMainScreenViewed() async {
        await ScreenNavigationEvents.mainScreenViewed.donate()
        print("👁️ 이벤트 기록: 메인 화면 방문")
    }
    
    /// 설정 화면 방문 기록
    static func recordSettingsScreenViewed() async {
        await ScreenNavigationEvents.settingsScreenViewed.donate()
        print("👁️ 이벤트 기록: 설정 화면 방문")
    }
    
    /// 상세 화면 방문 기록
    static func recordDetailScreenViewed() async {
        await ScreenNavigationEvents.detailScreenViewed.donate()
        print("👁️ 이벤트 기록: 상세 화면 방문")
    }
    
    // MARK: - 기능 사용 이벤트 기록
    
    /// 즐겨찾기 토글 기록
    static func recordFavoriteToggled() async {
        await FeatureUsageEvents.favoriteToggled.donate()
        print("⭐ 이벤트 기록: 즐겨찾기 토글")
    }
    
    /// 콘텐츠 공유 기록
    static func recordContentShared() async {
        await FeatureUsageEvents.contentShared.donate()
        print("📤 이벤트 기록: 콘텐츠 공유")
    }
    
    /// 검색 실행 기록
    static func recordSearchPerformed() async {
        await FeatureUsageEvents.searchPerformed.donate()
        print("🔍 이벤트 기록: 검색 실행")
    }
    
    /// 필터 적용 기록
    static func recordFilterApplied() async {
        await FeatureUsageEvents.filterApplied.donate()
        print("🎚️ 이벤트 기록: 필터 적용")
    }
    
    /// 아이템 생성 기록
    static func recordItemCreated() async {
        await FeatureUsageEvents.itemCreated.donate()
        print("➕ 이벤트 기록: 아이템 생성")
    }
    
    // MARK: - 사용자 상호작용 이벤트 기록
    
    /// 스와이프 제스처 기록
    static func recordSwipePerformed() async {
        await UserInteractionEvents.swipePerformed.donate()
        print("👆 이벤트 기록: 스와이프")
    }
    
    /// 롱프레스 기록
    static func recordLongPressPerformed() async {
        await UserInteractionEvents.longPressPerformed.donate()
        print("👆 이벤트 기록: 롱프레스")
    }
    
    /// 탭 전환 기록
    static func recordTabSwitched() async {
        await UserInteractionEvents.tabSwitched.donate()
        print("🔄 이벤트 기록: 탭 전환")
    }
    
    // MARK: - 온보딩 이벤트 기록
    
    /// 온보딩 시작 기록
    static func recordOnboardingStarted() async {
        await OnboardingEvents.onboardingStarted.donate()
        print("🎓 이벤트 기록: 온보딩 시작")
    }
    
    /// 온보딩 단계 완료 기록
    static func recordOnboardingStepCompleted(step: Int) async {
        switch step {
        case 1:
            await OnboardingEvents.onboardingStep1Completed.donate()
        case 2:
            await OnboardingEvents.onboardingStep2Completed.donate()
        case 3:
            await OnboardingEvents.onboardingStep3Completed.donate()
        default:
            break
        }
        print("🎓 이벤트 기록: 온보딩 \(step)단계 완료")
    }
    
    /// 온보딩 완료 기록
    static func recordOnboardingCompleted() async {
        await OnboardingEvents.onboardingCompleted.donate()
        print("🎓 이벤트 기록: 온보딩 완료")
    }
    
    // MARK: - 성취 이벤트 기록
    
    /// 첫 아이템 생성 기록
    static func recordFirstItemCreated() async {
        await AchievementEvents.firstItemCreated.donate()
        print("🏆 이벤트 기록: 첫 아이템 생성")
    }
    
    /// 첫 공유 기록
    static func recordFirstShare() async {
        await AchievementEvents.firstShare.donate()
        print("🏆 이벤트 기록: 첫 공유")
    }
}

// ============================================================================
// MARK: - 이벤트 통계
// ============================================================================

/// 이벤트 통계 및 분석을 위한 유틸리티
enum TipEventAnalytics {
    
    /// 모든 이벤트 ID 목록
    static var allEventIds: [String] {
        [
            // 앱 생명주기
            "com.tipshowcase.event.appLaunched",
            "com.tipshowcase.event.appBecameActive",
            "com.tipshowcase.event.sessionStarted",
            
            // 화면 탐색
            "com.tipshowcase.event.mainScreenViewed",
            "com.tipshowcase.event.settingsScreenViewed",
            "com.tipshowcase.event.detailScreenViewed",
            
            // 기능 사용
            "com.tipshowcase.event.favoriteToggled",
            "com.tipshowcase.event.contentShared",
            "com.tipshowcase.event.searchPerformed",
            
            // 온보딩
            "com.tipshowcase.event.onboardingStarted",
            "com.tipshowcase.event.onboardingCompleted"
        ]
    }
    
    /// 이벤트 카테고리별 그룹화
    static var eventCategories: [String: [String]] {
        [
            "앱 생명주기": [
                "appLaunched",
                "appBecameActive",
                "sessionStarted"
            ],
            "화면 탐색": [
                "mainScreenViewed",
                "settingsScreenViewed",
                "detailScreenViewed"
            ],
            "기능 사용": [
                "favoriteToggled",
                "contentShared",
                "searchPerformed"
            ],
            "온보딩": [
                "onboardingStarted",
                "onboardingCompleted"
            ]
        ]
    }
}
