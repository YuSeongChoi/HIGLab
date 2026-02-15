import ActivityKit

// MARK: - Push Token 설정

extension DeliveryActivityManager {
    
    func startActivityWithPush(
        attributes: DeliveryAttributes,
        initialState: DeliveryAttributes.ContentState
    ) async throws {
        let content = ActivityContent(state: initialState, staleDate: nil)
        
        // pushType: .token으로 푸시 업데이트 활성화
        let activity = try Activity.request(
            attributes: attributes,
            content: content,
            pushType: .token  // ← 중요!
        )
        
        self.currentActivity = activity
        
        // Push Token 관찰 시작
        observePushToken(for: activity)
    }
}
