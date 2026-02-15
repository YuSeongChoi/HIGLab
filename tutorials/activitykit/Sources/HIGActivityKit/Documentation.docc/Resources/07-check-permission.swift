import ActivityKit

// MARK: - Activity Manager
// Live Activity 생명주기 관리

@MainActor
class DeliveryActivityManager: ObservableObject {
    @Published var currentActivity: Activity<DeliveryAttributes>?
    
    // MARK: - 권한 확인
    
    var areActivitiesEnabled: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }
    
    func checkPermission() async -> Bool {
        // 설정에서 Live Activities가 켜져 있는지 확인
        guard areActivitiesEnabled else {
            print("Live Activities가 비활성화되어 있습니다.")
            print("설정 > 앱 > Live Activities 활성화 필요")
            return false
        }
        
        // 진행 중인 Activity 수 제한 확인 (앱당 1개 권장)
        let runningActivities = Activity<DeliveryAttributes>.activities
        if runningActivities.count >= 1 {
            print("이미 진행 중인 배달이 있습니다.")
            return false
        }
        
        return true
    }
}
