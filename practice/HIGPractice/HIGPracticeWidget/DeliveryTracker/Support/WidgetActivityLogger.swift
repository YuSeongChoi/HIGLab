import ActivityKit
import os.log

// 이 파일은 위젯 확장에서 활성 Live Activity 상태를 출력하는 디버그 로거입니다.
enum WidgetActivityLogger {
    static let logger = Logger(
        subsystem: "kr.co.cys.HIGPracticeWidget",
        category: "LiveActivity"
    )

    static func logAllActivities() {
        let activities = Activity<DeliveryAttributes>.activities
        logger.info("active activities: \(activities.count, privacy: .public)")
        for activity in activities {
            logger.debug("activity id=\(activity.id, privacy: .public) state=\(String(describing: activity.activityState), privacy: .public)")
        }
    }
}
