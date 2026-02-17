import ActivityKit
import os.log

struct ActivityDebugger {
    static let logger = Logger(
        subsystem: "com.example.delivery",
        category: "LiveActivity"
    )
    
    static func logActivityState<T: ActivityAttributes>(
        _ activity: Activity<T>
    ) {
        logger.debug("""
            Activity State:
            - ID: \(activity.id)
            - State: \(String(describing: activity.activityState))
            - Content: \(String(describing: activity.content))
            """)
    }
    
    static func logAllActivities() {
        let activities = Activity<DeliveryAttributes>.activities
        logger.info("총 \(activities.count)개의 활성 Activity")
        
        for activity in activities {
            logActivityState(activity)
        }
    }
}
