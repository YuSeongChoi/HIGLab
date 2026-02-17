import SwiftUI
import TipKit

// MARK: - TipKit 팁 정의
// 앱 전체에서 사용되는 모든 팁을 정의합니다.
// 각 팁은 Tip 프로토콜을 준수하며, title, message, image, rules, actions를 포함할 수 있습니다.

// ============================================================================
// MARK: - 온보딩 팁 (Onboarding Tips)
// ============================================================================

/// 환영 팁 - 앱 첫 실행 시 표시
/// 사용자에게 앱을 처음 소개합니다.
struct WelcomeTip: Tip {
    
    var title: Text {
        Text("TipShowcase에 오신 것을 환영합니다! 👋")
    }
    
    var message: Text? {
        Text("이 앱에서 TipKit의 다양한 기능을 살펴보세요. 팁을 통해 새로운 기능을 발견할 수 있습니다.")
    }
    
    var image: Image? {
        Image(systemName: "hand.wave.fill")
    }
    
    // 온보딩 완료 전에만 표시
    var rules: [Rule] {
        #Rule(OnboardingParameters.$hasSeenWelcome) { $0 == false }
    }
    
    // 높은 우선순위로 다른 팁보다 먼저 표시
    var options: [TipOption] {
        MaxDisplayCount(1)
    }
}

/// 첫 번째 기능 소개 팁
/// 즐겨찾기 기능을 소개합니다.
struct FirstFeatureTip: Tip {
    
    var title: Text {
        Text("즐겨찾기 기능")
    }
    
    var message: Text? {
        Text("하트 아이콘을 탭하여 마음에 드는 항목을 즐겨찾기에 추가하세요.")
    }
    
    var image: Image? {
        Image(systemName: "heart.fill")
    }
    
    // 환영 팁을 본 후에만 표시
    var rules: [Rule] {
        #Rule(OnboardingParameters.$hasSeenWelcome) { $0 == true }
        #Rule(OnboardingParameters.$hasSeenFirstFeature) { $0 == false }
    }
    
    var actions: [Action] {
        Action(id: "try-now", title: "지금 해보기")
        Action(id: "later", title: "나중에")
    }
}

/// 두 번째 기능 소개 팁
/// 공유 기능을 소개합니다.
struct SecondFeatureTip: Tip {
    
    var title: Text {
        Text("공유 기능")
    }
    
    var message: Text? {
        Text("공유 버튼을 사용하여 친구들과 콘텐츠를 공유할 수 있어요.")
    }
    
    var image: Image? {
        Image(systemName: "square.and.arrow.up.fill")
    }
    
    var rules: [Rule] {
        #Rule(OnboardingParameters.$hasSeenFirstFeature) { $0 == true }
        #Rule(OnboardingParameters.$hasSeenSecondFeature) { $0 == false }
    }
}

/// 세 번째 기능 소개 팁
/// 검색 기능을 소개합니다.
struct ThirdFeatureTip: Tip {
    
    var title: Text {
        Text("강력한 검색")
    }
    
    var message: Text? {
        Text("검색창을 사용하여 원하는 콘텐츠를 빠르게 찾아보세요.")
    }
    
    var image: Image? {
        Image(systemName: "magnifyingglass")
    }
    
    var rules: [Rule] {
        #Rule(OnboardingParameters.$hasSeenSecondFeature) { $0 == true }
        #Rule(OnboardingParameters.$hasSeenThirdFeature) { $0 == false }
    }
}

/// 온보딩 완료 팁
/// 온보딩 시퀀스의 마지막 팁입니다.
struct OnboardingCompleteTip: Tip {
    
    var title: Text {
        Text("준비 완료! 🎉")
    }
    
    var message: Text? {
        Text("이제 모든 기본 기능을 알게 되었어요. 앱을 자유롭게 탐색해 보세요!")
    }
    
    var image: Image? {
        Image(systemName: "checkmark.circle.fill")
    }
    
    var rules: [Rule] {
        #Rule(OnboardingParameters.$hasSeenThirdFeature) { $0 == true }
        #Rule(OnboardingParameters.$hasCompletedOnboarding) { $0 == false }
    }
    
    var actions: [Action] {
        Action(id: "complete", title: "시작하기")
    }
}

// ============================================================================
// MARK: - 기능 발견 팁 (Feature Discovery Tips)
// ============================================================================

/// 즐겨찾기 팁 - 인라인 스타일
/// 즐겨찾기 버튼 근처에 표시됩니다.
struct FavoriteTip: Tip {
    
    var title: Text {
        Text("즐겨찾기에 추가")
    }
    
    var message: Text? {
        Text("하트 버튼을 눌러 즐겨찾기에 추가하세요. 나중에 쉽게 찾을 수 있어요.")
    }
    
    var image: Image? {
        Image(systemName: "heart.fill")
    }
    
    // 즐겨찾기를 사용한 적이 없을 때만 표시
    var rules: [Rule] {
        #Rule(FeatureDiscoveryParameters.$hasUsedFavorites) { $0 == false }
        #Rule(OnboardingParameters.$hasCompletedOnboarding) { $0 == true }
    }
}

/// 공유 팁 - 팝오버 스타일
/// 공유 버튼에 연결됩니다.
struct ShareTip: Tip {
    
    var title: Text {
        Text("공유하기")
    }
    
    var message: Text? {
        Text("이 버튼으로 친구에게 공유할 수 있어요. 메시지, 메일, SNS 등 다양한 방법을 지원합니다.")
    }
    
    var image: Image? {
        Image(systemName: "square.and.arrow.up")
    }
    
    var rules: [Rule] {
        #Rule(FeatureDiscoveryParameters.$hasUsedSharing) { $0 == false }
        #Rule(OnboardingParameters.$hasCompletedOnboarding) { $0 == true }
    }
}

/// 검색 팁
/// 검색 기능을 아직 사용하지 않은 사용자에게 표시됩니다.
struct SearchTip: Tip {
    
    var title: Text {
        Text("검색 기능 발견!")
    }
    
    var message: Text? {
        Text("화면 상단의 검색창을 사용하여 콘텐츠를 빠르게 찾아보세요.")
    }
    
    var image: Image? {
        Image(systemName: "magnifyingglass")
    }
    
    var rules: [Rule] {
        #Rule(FeatureDiscoveryParameters.$hasUsedSearch) { $0 == false }
    }
}

/// 필터 팁
/// 필터 기능을 소개합니다.
struct FilterTip: Tip {
    
    var title: Text {
        Text("필터로 정리하기")
    }
    
    var message: Text? {
        Text("필터를 사용하여 원하는 항목만 표시할 수 있어요. 카테고리, 날짜, 상태별로 필터링 가능합니다.")
    }
    
    var image: Image? {
        Image(systemName: "line.3.horizontal.decrease.circle.fill")
    }
    
    var rules: [Rule] {
        #Rule(FeatureDiscoveryParameters.$hasUsedFilters) { $0 == false }
        // 검색을 사용한 후에 필터 팁 표시
        #Rule(FeatureDiscoveryParameters.$hasUsedSearch) { $0 == true }
    }
}

/// 정렬 팁
/// 정렬 옵션을 소개합니다.
struct SortingTip: Tip {
    
    var title: Text {
        Text("정렬 순서 변경")
    }
    
    var message: Text? {
        Text("정렬 버튼을 눌러 목록의 순서를 변경할 수 있어요. 이름순, 날짜순, 인기순 등을 선택하세요.")
    }
    
    var image: Image? {
        Image(systemName: "arrow.up.arrow.down.circle.fill")
    }
    
    var rules: [Rule] {
        #Rule(FeatureDiscoveryParameters.$hasUsedSorting) { $0 == false }
    }
}

// ============================================================================
// MARK: - 이벤트 기반 팁 (Event-Based Tips)
// ============================================================================

/// 프로 기능 팁 - 3회 사용 후 표시
/// 앱을 여러 번 사용한 사용자에게 고급 기능을 소개합니다.
struct ProFeatureTip: Tip {
    
    // 이벤트 정의: 앱 실행 이벤트
    static let appLaunchedEvent = AppLifecycleEvents.appLaunched
    
    var title: Text {
        Text("프로 기능 발견! ⭐")
    }
    
    var message: Text? {
        Text("앱을 여러 번 사용하셨네요! 고급 기능을 확인해보세요. 더 효율적으로 작업할 수 있어요.")
    }
    
    var image: Image? {
        Image(systemName: "star.fill")
    }
    
    // 이벤트 기반 규칙: 앱 실행 3회 이상
    var rules: [Rule] {
        #Rule(Self.appLaunchedEvent) { event in
            event.donations.count >= 3
        }
    }
    
    var actions: [Action] {
        Action(id: "explore", title: "살펴보기")
        Action(id: "not-now", title: "나중에")
    }
}

/// 파워 유저 팁 - 10회 사용 후 표시
/// 적극적인 사용자에게 고급 단축키를 소개합니다.
struct PowerUserTip: Tip {
    
    static let usageEvent = AppLifecycleEvents.appLaunched
    
    var title: Text {
        Text("파워 유저가 되어보세요! 💪")
    }
    
    var message: Text? {
        Text("자주 사용하시네요! 키보드 단축키를 사용하면 더 빠르게 작업할 수 있어요.")
    }
    
    var image: Image? {
        Image(systemName: "keyboard.fill")
    }
    
    var rules: [Rule] {
        #Rule(Self.usageEvent) { event in
            event.donations.count >= 10
        }
    }
}

/// 마스터 유저 팁 - 20회 사용 후 표시
struct MasterUserTip: Tip {
    
    static let usageEvent = AppLifecycleEvents.appLaunched
    
    var title: Text {
        Text("마스터 레벨 달성! 🏆")
    }
    
    var message: Text? {
        Text("앱을 능숙하게 사용하고 계시네요! 숨겨진 고급 설정을 확인해보세요.")
    }
    
    var image: Image? {
        Image(systemName: "crown.fill")
    }
    
    var rules: [Rule] {
        #Rule(Self.usageEvent) { event in
            event.donations.count >= 20
        }
    }
}

/// 공유 이벤트 기반 팁
/// 공유를 여러 번 한 사용자에게 표시됩니다.
struct ShareExpertTip: Tip {
    
    static let shareEvent = FeatureUsageEvents.contentShared
    
    var title: Text {
        Text("공유 전문가! 📤")
    }
    
    var message: Text? {
        Text("공유를 자주 하시네요! 빠른 공유 템플릿을 설정해보세요.")
    }
    
    var image: Image? {
        Image(systemName: "person.3.fill")
    }
    
    var rules: [Rule] {
        #Rule(Self.shareEvent) { event in
            event.donations.count >= 5
        }
    }
}

/// 검색 사용 팁 - 검색 5회 후 고급 검색 소개
struct AdvancedSearchTip: Tip {
    
    static let searchEvent = FeatureUsageEvents.searchPerformed
    
    var title: Text {
        Text("고급 검색 기능")
    }
    
    var message: Text? {
        Text("검색을 자주 사용하시네요! 고급 검색 연산자를 사용해보세요. \"AND\", \"OR\", 따옴표 등을 활용할 수 있어요.")
    }
    
    var image: Image? {
        Image(systemName: "doc.text.magnifyingglass")
    }
    
    var rules: [Rule] {
        #Rule(Self.searchEvent) { event in
            event.donations.count >= 5
        }
    }
}

// ============================================================================
// MARK: - 조건부 팁 (Conditional Tips)
// ============================================================================

/// 프로 사용자 전용 팁
/// 프로 버전 구매 사용자에게만 표시됩니다.
struct ProUserExclusiveTip: Tip {
    
    var title: Text {
        Text("프로 전용 기능 🎁")
    }
    
    var message: Text? {
        Text("프로 사용자 전용 고급 분석 기능을 사용해보세요. 통계, 리포트, 내보내기가 가능합니다.")
    }
    
    var image: Image? {
        Image(systemName: "chart.bar.xaxis")
    }
    
    // 프로 사용자이고 고급 기능을 활성화한 경우에만 표시
    var rules: [Rule] {
        #Rule(UserSettingsParameters.$isProUser) { $0 == true }
        #Rule(UserSettingsParameters.$advancedFeaturesEnabled) { $0 == true }
    }
}

/// 초보 사용자 팁
/// 앱 실행 횟수가 적은 사용자에게 표시됩니다.
struct BeginnerTip: Tip {
    
    var title: Text {
        Text("시작이 반입니다! 📚")
    }
    
    var message: Text? {
        Text("앱이 처음이시군요! 튜토리얼을 통해 기본 사용법을 익혀보세요.")
    }
    
    var image: Image? {
        Image(systemName: "book.fill")
    }
    
    var rules: [Rule] {
        #Rule(UserSettingsParameters.$appLaunchCount) { $0 < 5 }
        #Rule(UserSettingsParameters.$userExperienceLevel) { $0 == 0 }
    }
    
    var actions: [Action] {
        Action(id: "start-tutorial", title: "튜토리얼 시작")
        Action(id: "skip", title: "건너뛰기")
    }
}

/// 복귀 사용자 팁
/// 오랜만에 앱을 사용하는 사용자에게 표시됩니다.
struct ReturningUserTip: Tip {
    
    var title: Text {
        Text("다시 만나서 반가워요! 👋")
    }
    
    var message: Text? {
        Text("오랜만이에요! 새로 추가된 기능들을 확인해보세요.")
    }
    
    var image: Image? {
        Image(systemName: "sparkles")
    }
    
    // 7일 이상 미사용 후 복귀한 경우
    var rules: [Rule] {
        #Rule(TimeBasedParameters.$daysSinceInstall) { $0 > 7 }
    }
    
    var actions: [Action] {
        Action(id: "whats-new", title: "새 기능 보기")
        Action(id: "continue", title: "계속하기")
    }
}

/// 다크 모드 팁
/// 다크 모드를 아직 사용하지 않은 사용자에게 표시됩니다.
struct DarkModeTip: Tip {
    
    var title: Text {
        Text("다크 모드 지원")
    }
    
    var message: Text? {
        Text("눈의 피로를 줄이려면 다크 모드를 사용해보세요. 설정에서 변경할 수 있어요.")
    }
    
    var image: Image? {
        Image(systemName: "moon.fill")
    }
    
    var rules: [Rule] {
        #Rule(FeatureDiscoveryParameters.$hasToggledDarkMode) { $0 == false }
    }
}

/// 알림 설정 팁
/// 알림을 아직 설정하지 않은 사용자에게 표시됩니다.
struct NotificationTip: Tip {
    
    var title: Text {
        Text("알림 설정하기")
    }
    
    var message: Text? {
        Text("중요한 업데이트를 놓치지 않도록 알림을 설정해보세요.")
    }
    
    var image: Image? {
        Image(systemName: "bell.badge.fill")
    }
    
    var rules: [Rule] {
        #Rule(FeatureDiscoveryParameters.$hasConfiguredNotifications) { $0 == false }
        #Rule(UserSettingsParameters.$appLaunchCount) { $0 >= 3 }
    }
    
    var actions: [Action] {
        Action(id: "enable", title: "알림 켜기")
        Action(id: "not-now", title: "나중에")
    }
}

// ============================================================================
// MARK: - 시간 기반 팁 (Time-Based Tips)
// ============================================================================

/// 아침 인사 팁
/// 아침 시간대에 앱을 사용하는 사용자에게 표시됩니다.
struct MorningTip: Tip {
    
    var title: Text {
        Text("좋은 아침이에요! ☀️")
    }
    
    var message: Text? {
        Text("오늘 하루도 생산적인 하루 되세요! 오늘의 할 일을 확인해보세요.")
    }
    
    var image: Image? {
        Image(systemName: "sunrise.fill")
    }
    
    var rules: [Rule] {
        #Rule(TimeBasedParameters.$currentHour) { hour in
            hour >= 6 && hour < 12
        }
    }
    
    var options: [TipOption] {
        MaxDisplayCount(1)
    }
}

/// 저녁 리마인더 팁
/// 저녁 시간대에 표시됩니다.
struct EveningTip: Tip {
    
    var title: Text {
        Text("오늘 하루 정리하기 🌙")
    }
    
    var message: Text? {
        Text("오늘 완료한 작업을 확인하고 내일 계획을 세워보세요.")
    }
    
    var image: Image? {
        Image(systemName: "moon.stars.fill")
    }
    
    var rules: [Rule] {
        #Rule(TimeBasedParameters.$currentHour) { hour in
            hour >= 18 && hour < 22
        }
    }
    
    var options: [TipOption] {
        MaxDisplayCount(1)
    }
}

/// 주말 특별 팁
/// 주말에만 표시되는 팁입니다.
struct WeekendTip: Tip {
    
    var title: Text {
        Text("주말 특별 기능 🎉")
    }
    
    var message: Text? {
        Text("주말에는 특별한 테마를 사용할 수 있어요! 설정에서 확인해보세요.")
    }
    
    var image: Image? {
        Image(systemName: "party.popper.fill")
    }
    
    var rules: [Rule] {
        #Rule(TimeBasedParameters.$isWeekday) { $0 == false }
    }
}

/// 장기 사용자 감사 팁
/// 30일 이상 사용한 사용자에게 표시됩니다.
struct LoyalUserTip: Tip {
    
    var title: Text {
        Text("감사합니다! ❤️")
    }
    
    var message: Text? {
        Text("한 달 넘게 저희 앱을 사용해주셨어요! 감사의 의미로 특별 테마를 드려요.")
    }
    
    var image: Image? {
        Image(systemName: "gift.fill")
    }
    
    var rules: [Rule] {
        #Rule(TimeBasedParameters.$daysSinceInstall) { $0 >= 30 }
    }
    
    var actions: [Action] {
        Action(id: "claim", title: "테마 받기")
    }
}

// ============================================================================
// MARK: - 액션 팁 (Action Tips)
// ============================================================================

/// 피드백 요청 팁
/// 사용자에게 피드백을 요청합니다.
struct FeedbackTip: Tip {
    
    var title: Text {
        Text("의견을 들려주세요")
    }
    
    var message: Text? {
        Text("앱 사용 경험은 어떠신가요? 여러분의 소중한 의견이 앱 개선에 큰 도움이 됩니다.")
    }
    
    var image: Image? {
        Image(systemName: "envelope.fill")
    }
    
    var rules: [Rule] {
        #Rule(UserSettingsParameters.$appLaunchCount) { $0 >= 10 }
    }
    
    var actions: [Action] {
        Action(id: "rate", title: "별점 남기기")
        Action(id: "feedback", title: "피드백 보내기")
        Action(id: "later", title: "나중에")
    }
}

/// 업데이트 안내 팁
/// 새 버전 출시 시 표시됩니다.
struct UpdateTip: Tip {
    
    var title: Text {
        Text("새 버전이 출시되었어요! 🚀")
    }
    
    var message: Text? {
        Text("새로운 기능과 개선 사항이 포함되어 있어요. 지금 업데이트하세요!")
    }
    
    var image: Image? {
        Image(systemName: "arrow.down.circle.fill")
    }
    
    var actions: [Action] {
        Action(id: "update", title: "업데이트")
        Action(id: "release-notes", title: "변경 사항 보기")
        Action(id: "later", title: "나중에")
    }
}

/// 위젯 설정 팁
/// 위젯 사용을 권장합니다.
struct WidgetTip: Tip {
    
    var title: Text {
        Text("위젯으로 더 빠르게!")
    }
    
    var message: Text? {
        Text("홈 화면에 위젯을 추가하면 앱을 열지 않고도 빠르게 확인할 수 있어요.")
    }
    
    var image: Image? {
        Image(systemName: "square.grid.2x2.fill")
    }
    
    var rules: [Rule] {
        #Rule(UserSettingsParameters.$appLaunchCount) { $0 >= 5 }
    }
    
    var actions: [Action] {
        Action(id: "add-widget", title: "위젯 추가 방법")
        Action(id: "dismiss", title: "알겠어요")
    }
}

// ============================================================================
// MARK: - 고급 팁 (Advanced Tips)
// ============================================================================

/// 단축어 팁
/// 시리 단축어 통합을 소개합니다.
struct ShortcutsTip: Tip {
    
    var title: Text {
        Text("시리 단축어 지원")
    }
    
    var message: Text? {
        Text("\"헤이 시리\"로 앱 기능을 빠르게 실행할 수 있어요. 단축어를 설정해보세요!")
    }
    
    var image: Image? {
        Image(systemName: "waveform.circle.fill")
    }
    
    var rules: [Rule] {
        #Rule(UserSettingsParameters.$isProUser) { $0 == true }
    }
}

/// 동기화 팁
/// iCloud 동기화를 소개합니다.
struct SyncTip: Tip {
    
    var title: Text {
        Text("모든 기기에서 동기화")
    }
    
    var message: Text? {
        Text("iCloud로 데이터를 동기화하면 iPhone, iPad, Mac 어디서든 접근할 수 있어요.")
    }
    
    var image: Image? {
        Image(systemName: "icloud.fill")
    }
    
    var rules: [Rule] {
        #Rule(OnboardingParameters.$hasCompletedOnboarding) { $0 == true }
    }
    
    var actions: [Action] {
        Action(id: "enable-sync", title: "동기화 켜기")
        Action(id: "learn-more", title: "자세히 알아보기")
    }
}

/// 백업 팁
/// 데이터 백업을 권장합니다.
struct BackupTip: Tip {
    
    var title: Text {
        Text("데이터 백업하기")
    }
    
    var message: Text? {
        Text("소중한 데이터를 잃지 않도록 정기적으로 백업하세요. 내보내기 기능을 사용할 수 있어요.")
    }
    
    var image: Image? {
        Image(systemName: "externaldrive.fill.badge.checkmark")
    }
    
    var rules: [Rule] {
        #Rule(TimeBasedParameters.$daysSinceInstall) { $0 >= 14 }
    }
}

/// 제스처 팁
/// 고급 제스처를 소개합니다.
struct GestureTip: Tip {
    
    var title: Text {
        Text("제스처로 빠르게!")
    }
    
    var message: Text? {
        Text("스와이프, 핀치, 롱프레스 등 다양한 제스처를 사용해보세요. 더 빠르게 작업할 수 있어요!")
    }
    
    var image: Image? {
        Image(systemName: "hand.draw.fill")
    }
    
    var rules: [Rule] {
        #Rule(UserSettingsParameters.$userExperienceLevel) { $0 >= 1 }
    }
}
