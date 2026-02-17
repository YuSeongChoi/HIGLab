import ActivityKit
import Foundation

// MARK: - Activity 모니터링 유틸리티
@Observable
final class ActivityMonitor<T: ActivityAttributes> {
    private(set) var activities: [Activity<T>] = []
    private var updateTask: Task<Void, Never>?
    
    init() {
        refreshActivities()
        startMonitoring()
    }
    
    deinit {
        updateTask?.cancel()
    }
    
    // MARK: - 활성 Activity 조회
    
    func refreshActivities() {
        activities = Activity<T>.activities
    }
    
    // MARK: - 실시간 모니터링
    
    private func startMonitoring() {
        updateTask = Task {
            for await activity in Activity<T>.activityUpdates {
                await MainActor.run {
                    ActivityLogger.lifecycle.debug(
                        "Activity 업데이트 감지: \(activity.id)"
                    )
                    refreshActivities()
                }
            }
        }
    }
    
    // MARK: - 상태 확인
    
    func activity(withId id: String) -> Activity<T>? {
        activities.first { $0.id == id }
    }
    
    var activeCount: Int {
        activities.filter { $0.activityState == .active }.count
    }
    
    var staleCount: Int {
        activities.filter { $0.activityState == .stale }.count
    }
    
    // MARK: - 디버그 정보
    
    func debugDescription() -> String {
        """
        === Activity Monitor ===
        총 Activity: \(activities.count)
        - Active: \(activeCount)
        - Stale: \(staleCount)
        
        상세:
        \(activities.map { "[\($0.activityState)] \($0.id)" }.joined(separator: "\n"))
        ========================
        """
    }
}
