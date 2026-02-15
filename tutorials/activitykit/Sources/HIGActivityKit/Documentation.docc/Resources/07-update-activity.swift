import ActivityKit

extension DeliveryActivityManager {
    
    // MARK: - Activity 업데이트
    
    func updateDeliveryStatus(
        to status: DeliveryStatus,
        driverName: String? = nil,
        newEstimatedMinutes: Int? = nil
    ) async {
        guard let activity = currentActivity else {
            print("진행 중인 Activity가 없습니다.")
            return
        }
        
        // 새로운 ContentState 생성
        let estimatedArrival: Date
        if let minutes = newEstimatedMinutes {
            estimatedArrival = Date().addingTimeInterval(TimeInterval(minutes * 60))
        } else {
            estimatedArrival = activity.content.state.estimatedArrival
        }
        
        let updatedState = DeliveryAttributes.ContentState(
            status: status,
            estimatedArrival: estimatedArrival,
            driverName: driverName ?? activity.content.state.driverName,
            driverImageURL: activity.content.state.driverImageURL
        )
        
        // Activity 업데이트
        let content = ActivityContent(
            state: updatedState,
            staleDate: Date().addingTimeInterval(3600)
        )
        
        await activity.update(content)
        print("Activity 업데이트됨: \(status.displayName)")
    }
    
    // 배달원 배정 시
    func assignDriver(name: String, imageURL: URL?) async {
        await updateDeliveryStatus(to: .pickedUp, driverName: name)
    }
    
    // 근처 도착 시
    func driverNearby() async {
        await updateDeliveryStatus(to: .nearby, newEstimatedMinutes: 3)
    }
}
