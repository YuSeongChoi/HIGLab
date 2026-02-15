import ActivityKit

extension DeliveryActivityManager {
    
    // MARK: - Activity 종료
    
    func endDeliveryActivity() async {
        guard let activity = currentActivity else {
            print("진행 중인 Activity가 없습니다.")
            return
        }
        
        // 최종 상태로 업데이트
        let finalState = DeliveryAttributes.ContentState(
            status: .delivered,
            estimatedArrival: Date(),
            driverName: activity.content.state.driverName,
            driverImageURL: activity.content.state.driverImageURL
        )
        
        let finalContent = ActivityContent(
            state: finalState,
            staleDate: nil
        )
        
        // 종료 정책 설정
        // .default: 즉시 종료
        // .after(Date): 지정 시간까지 표시 후 종료
        // .immediate: 정말 즉시 종료
        await activity.end(
            finalContent,
            dismissalPolicy: .after(Date().addingTimeInterval(3600)) // 1시간 후 제거
        )
        
        self.currentActivity = nil
        print("Activity 종료됨")
    }
    
    // 주문 취소 시
    func cancelDeliveryActivity() async {
        guard let activity = currentActivity else { return }
        
        // 취소 상태로 종료 (즉시 제거)
        await activity.end(nil, dismissalPolicy: .immediate)
        self.currentActivity = nil
        print("Activity 취소됨")
    }
}
