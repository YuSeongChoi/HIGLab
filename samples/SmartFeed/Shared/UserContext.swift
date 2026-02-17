// UserContext.swift
// SmartFeed - RelevanceKit 샘플
// 사용자 컨텍스트 및 행동 모델

import Foundation
import CoreLocation
import RelevanceKit

// MARK: - 사용자 컨텍스트
/// 현재 사용자의 상황 정보를 담는 컨텍스트
@available(iOS 26.0, *)
struct UserContext {
    let timestamp: Date                     // 컨텍스트 생성 시간
    let location: CLLocation?               // 현재 위치
    let timeOfDay: TimeOfDay                // 시간대
    let dayOfWeek: DayOfWeek                // 요일
    let activityType: UserActivityType      // 현재 활동 유형
    let deviceState: DeviceState            // 기기 상태
    let preferences: UserPreferences        // 사용자 선호도
    let recentInteractions: [UserInteraction] // 최근 상호작용
    
    /// 기본 초기화
    init(
        timestamp: Date = Date(),
        location: CLLocation? = nil,
        timeOfDay: TimeOfDay? = nil,
        dayOfWeek: DayOfWeek? = nil,
        activityType: UserActivityType = .unknown,
        deviceState: DeviceState = DeviceState(),
        preferences: UserPreferences = UserPreferences(),
        recentInteractions: [UserInteraction] = []
    ) {
        self.timestamp = timestamp
        self.location = location
        self.timeOfDay = timeOfDay ?? TimeOfDay.current
        self.dayOfWeek = dayOfWeek ?? DayOfWeek.current
        self.activityType = activityType
        self.deviceState = deviceState
        self.preferences = preferences
        self.recentInteractions = recentInteractions
    }
    
    /// RelevanceKit RKUserContext로 변환
    func toRelevanceContext() -> RKUserContext {
        var context = RKUserContext()
        
        // 시간 컨텍스트 설정
        context.currentTime = timestamp
        context.timeOfDay = timeOfDay.toRKTimeOfDay()
        context.dayOfWeek = dayOfWeek.toRKDayOfWeek()
        
        // 위치 설정
        if let location = location {
            context.location = RKLocation(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
        }
        
        // 활동 유형 설정
        context.activityType = activityType.toRKActivityType()
        
        // 기기 상태 설정
        context.isLowPowerMode = deviceState.isLowPowerMode
        context.screenBrightness = deviceState.screenBrightness
        
        // 선호도 설정
        context.preferredCategories = preferences.favoriteCategories.map { $0.rawValue }
        context.preferredContentLength = preferences.preferredReadTime.toRKContentLength()
        
        return context
    }
}

// MARK: - 시간대
/// 하루 중 시간대 구분
enum TimeOfDay: String, Codable, CaseIterable {
    case earlyMorning = "early_morning"     // 새벽 (04:00 ~ 06:59)
    case morning = "morning"                 // 아침 (07:00 ~ 11:59)
    case afternoon = "afternoon"             // 오후 (12:00 ~ 17:59)
    case evening = "evening"                 // 저녁 (18:00 ~ 21:59)
    case night = "night"                     // 밤 (22:00 ~ 03:59)
    
    /// 현재 시간대 반환
    static var current: TimeOfDay {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 4..<7: return .earlyMorning
        case 7..<12: return .morning
        case 12..<18: return .afternoon
        case 18..<22: return .evening
        default: return .night
        }
    }
    
    var displayName: String {
        switch self {
        case .earlyMorning: return "새벽"
        case .morning: return "아침"
        case .afternoon: return "오후"
        case .evening: return "저녁"
        case .night: return "밤"
        }
    }
    
    /// RKTimeOfDay로 변환
    @available(iOS 26.0, *)
    func toRKTimeOfDay() -> RKTimeOfDay {
        switch self {
        case .earlyMorning: return .earlyMorning
        case .morning: return .morning
        case .afternoon: return .afternoon
        case .evening: return .evening
        case .night: return .night
        }
    }
}

// MARK: - 요일
/// 요일 구분
enum DayOfWeek: Int, Codable, CaseIterable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    
    /// 현재 요일 반환
    static var current: DayOfWeek {
        let weekday = Calendar.current.component(.weekday, from: Date())
        return DayOfWeek(rawValue: weekday) ?? .sunday
    }
    
    /// 주말 여부
    var isWeekend: Bool {
        return self == .saturday || self == .sunday
    }
    
    var displayName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.weekdaySymbols[rawValue - 1]
    }
    
    /// RKDayOfWeek로 변환
    @available(iOS 26.0, *)
    func toRKDayOfWeek() -> RKDayOfWeek {
        switch self {
        case .sunday: return .sunday
        case .monday: return .monday
        case .tuesday: return .tuesday
        case .wednesday: return .wednesday
        case .thursday: return .thursday
        case .friday: return .friday
        case .saturday: return .saturday
        }
    }
}

// MARK: - 사용자 활동 유형
/// 사용자의 현재 활동 상태
enum UserActivityType: String, Codable {
    case stationary = "stationary"      // 정지
    case walking = "walking"            // 걷기
    case running = "running"            // 달리기
    case cycling = "cycling"            // 자전거
    case driving = "driving"            // 운전
    case commuting = "commuting"        // 출퇴근
    case working = "working"            // 업무 중
    case relaxing = "relaxing"          // 휴식
    case unknown = "unknown"            // 알 수 없음
    
    var displayName: String {
        switch self {
        case .stationary: return "정지"
        case .walking: return "걷는 중"
        case .running: return "달리는 중"
        case .cycling: return "자전거 타는 중"
        case .driving: return "운전 중"
        case .commuting: return "출퇴근 중"
        case .working: return "업무 중"
        case .relaxing: return "휴식 중"
        case .unknown: return "알 수 없음"
        }
    }
    
    /// 이 활동에 적합한 콘텐츠 길이
    var preferredContentLength: PreferredReadTime {
        switch self {
        case .commuting, .walking: return .short
        case .driving: return .veryShort
        case .relaxing: return .long
        case .working: return .medium
        default: return .medium
        }
    }
    
    /// RKActivityType으로 변환
    @available(iOS 26.0, *)
    func toRKActivityType() -> RKActivityType {
        switch self {
        case .stationary: return .stationary
        case .walking: return .walking
        case .running: return .running
        case .cycling: return .cycling
        case .driving: return .automotive
        case .commuting: return .commuting
        case .working: return .working
        case .relaxing: return .leisure
        case .unknown: return .unknown
        }
    }
}

// MARK: - 기기 상태
/// 현재 기기의 상태 정보
struct DeviceState: Codable {
    var isLowPowerMode: Bool        // 저전력 모드 여부
    var batteryLevel: Float         // 배터리 잔량 (0.0 ~ 1.0)
    var screenBrightness: Float     // 화면 밝기 (0.0 ~ 1.0)
    var isConnectedToWiFi: Bool     // WiFi 연결 여부
    var isCellularDataEnabled: Bool // 셀룰러 데이터 사용 여부
    
    init(
        isLowPowerMode: Bool = false,
        batteryLevel: Float = 1.0,
        screenBrightness: Float = 0.5,
        isConnectedToWiFi: Bool = true,
        isCellularDataEnabled: Bool = true
    ) {
        self.isLowPowerMode = isLowPowerMode
        self.batteryLevel = batteryLevel
        self.screenBrightness = screenBrightness
        self.isConnectedToWiFi = isConnectedToWiFi
        self.isCellularDataEnabled = isCellularDataEnabled
    }
    
    /// 데이터 절약 모드 권장 여부
    var shouldConserveData: Bool {
        return isLowPowerMode || (!isConnectedToWiFi && batteryLevel < 0.3)
    }
}

// MARK: - 선호 읽기 시간
/// 사용자가 선호하는 콘텐츠 길이
enum PreferredReadTime: String, Codable, CaseIterable {
    case veryShort = "very_short"   // 1분 이하
    case short = "short"            // 1~3분
    case medium = "medium"          // 3~7분
    case long = "long"              // 7~15분
    case veryLong = "very_long"     // 15분 이상
    
    var displayName: String {
        switch self {
        case .veryShort: return "1분 이하"
        case .short: return "1~3분"
        case .medium: return "3~7분"
        case .long: return "7~15분"
        case .veryLong: return "15분 이상"
        }
    }
    
    var maxMinutes: Int {
        switch self {
        case .veryShort: return 1
        case .short: return 3
        case .medium: return 7
        case .long: return 15
        case .veryLong: return Int.max
        }
    }
    
    /// RKContentLength로 변환
    @available(iOS 26.0, *)
    func toRKContentLength() -> RKContentLength {
        switch self {
        case .veryShort: return .brief
        case .short: return .short
        case .medium: return .medium
        case .long: return .long
        case .veryLong: return .extended
        }
    }
}

// MARK: - 사용자 선호도
/// 사용자의 콘텐츠 선호도 설정
struct UserPreferences: Codable {
    var favoriteCategories: [FeedCategory]      // 선호 카테고리
    var blockedCategories: [FeedCategory]       // 차단 카테고리
    var preferredReadTime: PreferredReadTime    // 선호 읽기 시간
    var preferredContentTypes: [ContentType]    // 선호 콘텐츠 타입
    var enableLocationRecommendations: Bool     // 위치 기반 추천 활성화
    var enableTimeBasedRecommendations: Bool    // 시간 기반 추천 활성화
    var enableBehaviorLearning: Bool            // 행동 학습 활성화
    
    init(
        favoriteCategories: [FeedCategory] = [],
        blockedCategories: [FeedCategory] = [],
        preferredReadTime: PreferredReadTime = .medium,
        preferredContentTypes: [ContentType] = [.article, .video],
        enableLocationRecommendations: Bool = true,
        enableTimeBasedRecommendations: Bool = true,
        enableBehaviorLearning: Bool = true
    ) {
        self.favoriteCategories = favoriteCategories
        self.blockedCategories = blockedCategories
        self.preferredReadTime = preferredReadTime
        self.preferredContentTypes = preferredContentTypes
        self.enableLocationRecommendations = enableLocationRecommendations
        self.enableTimeBasedRecommendations = enableTimeBasedRecommendations
        self.enableBehaviorLearning = enableBehaviorLearning
    }
}

// MARK: - 사용자 상호작용
/// 사용자의 콘텐츠 상호작용 기록
struct UserInteraction: Identifiable, Codable {
    let id: UUID
    let itemId: UUID                // 상호작용한 피드 아이템 ID
    let type: InteractionType       // 상호작용 유형
    let timestamp: Date             // 상호작용 시간
    let duration: TimeInterval?     // 소요 시간 (읽기/시청의 경우)
    let context: InteractionContext // 상호작용 컨텍스트
    
    init(
        id: UUID = UUID(),
        itemId: UUID,
        type: InteractionType,
        timestamp: Date = Date(),
        duration: TimeInterval? = nil,
        context: InteractionContext = InteractionContext()
    ) {
        self.id = id
        self.itemId = itemId
        self.type = type
        self.timestamp = timestamp
        self.duration = duration
        self.context = context
    }
}

// MARK: - 상호작용 유형
/// 사용자가 콘텐츠와 할 수 있는 상호작용 유형
enum InteractionType: String, Codable {
    case view = "view"              // 조회
    case click = "click"            // 클릭
    case read = "read"              // 읽기 (일정 시간 이상 체류)
    case like = "like"              // 좋아요
    case unlike = "unlike"          // 좋아요 취소
    case share = "share"            // 공유
    case bookmark = "bookmark"      // 북마크
    case unbookmark = "unbookmark"  // 북마크 취소
    case comment = "comment"        // 댓글
    case hide = "hide"              // 숨기기
    case report = "report"          // 신고
    
    /// 긍정적 상호작용 여부
    var isPositive: Bool {
        switch self {
        case .read, .like, .share, .bookmark, .comment:
            return true
        default:
            return false
        }
    }
    
    /// 부정적 상호작용 여부
    var isNegative: Bool {
        switch self {
        case .hide, .report, .unlike, .unbookmark:
            return true
        default:
            return false
        }
    }
    
    /// 상호작용 가중치 (행동 학습용)
    var weight: Double {
        switch self {
        case .read: return 1.0
        case .like: return 1.5
        case .share: return 2.0
        case .bookmark: return 1.5
        case .comment: return 2.0
        case .hide: return -2.0
        case .report: return -3.0
        case .unlike: return -1.0
        case .unbookmark: return -0.5
        case .view: return 0.1
        case .click: return 0.3
        }
    }
}

// MARK: - 상호작용 컨텍스트
/// 상호작용이 발생한 상황 정보
struct InteractionContext: Codable {
    let timeOfDay: TimeOfDay        // 상호작용 시간대
    let dayOfWeek: DayOfWeek        // 상호작용 요일
    let source: InteractionSource   // 상호작용 출처
    let scrollPosition: Int?        // 피드 내 위치 (몇 번째 아이템)
    
    init(
        timeOfDay: TimeOfDay = .current,
        dayOfWeek: DayOfWeek = .current,
        source: InteractionSource = .feed,
        scrollPosition: Int? = nil
    ) {
        self.timeOfDay = timeOfDay
        self.dayOfWeek = dayOfWeek
        self.source = source
        self.scrollPosition = scrollPosition
    }
}

// MARK: - 상호작용 출처
/// 상호작용이 시작된 출처
enum InteractionSource: String, Codable {
    case feed = "feed"                  // 메인 피드
    case search = "search"              // 검색 결과
    case recommendation = "recommendation" // 추천 섹션
    case notification = "notification"  // 알림
    case deepLink = "deep_link"         // 딥링크
    case widget = "widget"              // 위젯
}
