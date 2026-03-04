import ActivityKit
import os.log

enum ActivityDebugger {
    static let logger = Logger(
        subsystem: "kr.co.cys.HIGPractice",
        category: "LiveActivity"
    )

    static func logActivityState<T: ActivityAttributes>(_ activity: Activity<T>) {
        logger.debug(
            """
            Activity state
            id=\(activity.id, privacy: .public)
            state=\(String(describing: activity.activityState), privacy: .public)
            """
        )
    }

    static func logAllDeliveryActivities() {
        let activities = Activity<DeliveryAttributes>.activities
        logger.info("active delivery activities: \(activities.count, privacy: .public)")
        for activity in activities {
            logActivityState(activity)
        }
    }
}
