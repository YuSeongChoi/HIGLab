import Foundation
import UserNotifications

// MARK: - 알림 카테고리
// 알림을 분류하고 카테고리별 액션 버튼을 정의합니다.
// UNNotificationCategory를 통해 알림 센터에서 직접 상호작용 가능한 버튼을 추가할 수 있습니다.

/// 앱 내 알림 카테고리 종류
enum NotificationCategory: String, CaseIterable, Codable {
    case reminder = "REMINDER"
    case health = "HEALTH"
    case work = "WORK"
    case social = "SOCIAL"
    case location = "LOCATION"
    
    // MARK: - 표시 정보
    
    /// 카테고리 한글 이름
    var displayName: String {
        switch self {
        case .reminder: "리마인더"
        case .health: "건강"
        case .work: "업무"
        case .social: "소셜"
        case .location: "위치 기반"
        }
    }
    
    /// 카테고리 아이콘 (SF Symbol)
    var symbol: String {
        switch self {
        case .reminder: "bell.fill"
        case .health: "heart.fill"
        case .work: "briefcase.fill"
        case .social: "person.2.fill"
        case .location: "location.fill"
        }
    }
    
    /// 카테고리 색상
    var colorName: String {
        switch self {
        case .reminder: "blue"
        case .health: "red"
        case .work: "purple"
        case .social: "green"
        case .location: "orange"
        }
    }
    
    // MARK: - UNNotificationCategory 생성
    
    /// 이 카테고리의 액션 버튼 정의
    var actions: [UNNotificationAction] {
        switch self {
        case .reminder:
            return [
                UNNotificationAction(
                    identifier: NotificationAction.snooze10.rawValue,
                    title: "10분 후 다시 알림",
                    options: []
                ),
                UNNotificationAction(
                    identifier: NotificationAction.complete.rawValue,
                    title: "완료",
                    options: [.destructive]
                )
            ]
            
        case .health:
            return [
                UNNotificationAction(
                    identifier: NotificationAction.done.rawValue,
                    title: "완료 ✓",
                    options: []
                ),
                UNNotificationAction(
                    identifier: NotificationAction.skip.rawValue,
                    title: "오늘 건너뛰기",
                    options: [.destructive]
                )
            ]
            
        case .work:
            return [
                UNNotificationAction(
                    identifier: NotificationAction.snooze30.rawValue,
                    title: "30분 후 다시 알림",
                    options: []
                ),
                UNNotificationAction(
                    identifier: NotificationAction.open.rawValue,
                    title: "앱 열기",
                    options: [.foreground]
                )
            ]
            
        case .social:
            return [
                UNNotificationAction(
                    identifier: NotificationAction.reply.rawValue,
                    title: "답장하기",
                    options: [.foreground]
                ),
                UNNotificationAction(
                    identifier: NotificationAction.dismiss.rawValue,
                    title: "무시",
                    options: []
                )
            ]
            
        case .location:
            return [
                UNNotificationAction(
                    identifier: NotificationAction.navigate.rawValue,
                    title: "길 안내",
                    options: [.foreground]
                ),
                UNNotificationAction(
                    identifier: NotificationAction.arrived.rawValue,
                    title: "도착 완료",
                    options: [.destructive]
                )
            ]
        }
    }
    
    /// UNNotificationCategory 객체 생성
    var unCategory: UNNotificationCategory {
        UNNotificationCategory(
            identifier: rawValue,
            actions: actions,
            intentIdentifiers: [],
            hiddenPreviewsBodyPlaceholder: "새 \(displayName) 알림",
            categorySummaryFormat: "%u개의 \(displayName) 알림",
            options: [.customDismissAction]
        )
    }
    
    /// 모든 카테고리의 UNNotificationCategory 집합
    static var allUNCategories: Set<UNNotificationCategory> {
        Set(allCases.map { $0.unCategory })
    }
}

// MARK: - 알림 액션 식별자

/// 알림에서 사용할 수 있는 액션 타입
enum NotificationAction: String {
    // 공통 액션
    case snooze10 = "SNOOZE_10"
    case snooze30 = "SNOOZE_30"
    case complete = "COMPLETE"
    case dismiss = "DISMISS"
    
    // 건강 액션
    case done = "DONE"
    case skip = "SKIP"
    
    // 업무 액션
    case open = "OPEN"
    
    // 소셜 액션
    case reply = "REPLY"
    
    // 위치 액션
    case navigate = "NAVIGATE"
    case arrived = "ARRIVED"
    
    /// 액션 설명
    var description: String {
        switch self {
        case .snooze10: "10분 후 다시 알림"
        case .snooze30: "30분 후 다시 알림"
        case .complete: "완료 처리"
        case .dismiss: "무시"
        case .done: "완료"
        case .skip: "건너뛰기"
        case .open: "앱 열기"
        case .reply: "답장"
        case .navigate: "길 안내"
        case .arrived: "도착 완료"
        }
    }
}
