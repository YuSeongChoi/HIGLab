import Foundation

/// 알림 ID 관리를 위한 상수
enum NotificationID {
    // 반복 알림 ID (의미 있는 이름 사용)
    static let dailyWaterReminder = "daily-water-reminder"
    static let morningRoutine = "morning-routine"
    static let eveningReview = "evening-review"
    
    // 평일 알림용 접두사
    static func weekday(_ base: String, weekday: Int) -> String {
        "\(base)-weekday-\(weekday)"
    }
    
    // 리마인더별 알림 ID
    static func reminder(_ id: UUID) -> String {
        "reminder-\(id.uuidString)"
    }
    
    // 평일 알림 ID들
    static func weekdayIDs(_ base: String) -> [String] {
        (2...6).map { weekday(base, weekday: $0) }
    }
}

// 사용 예시
// NotificationID.dailyWaterReminder → "daily-water-reminder"
// NotificationID.weekday("work-alarm", weekday: 2) → "work-alarm-weekday-2"
// NotificationID.weekdayIDs("work-alarm") → 5개의 ID 배열
