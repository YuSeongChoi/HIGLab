import ActivityKit

extension DeliveryActivityManager {
    
    // MARK: - Activity 시작
    
    func startDeliveryActivity(
        orderNumber: String,
        storeName: String,
        estimatedMinutes: Int
    ) async throws {
        // 1. 권한 확인
        guard await checkPermission() else {
            throw ActivityError.notAuthorized
        }
        
        // 2. Attributes 생성 (Static 데이터)
        let attributes = DeliveryAttributes(
            orderNumber: orderNumber,
            storeName: storeName,
            storeImageURL: nil,
            customerAddress: "서울시 강남구"
        )
        
        // 3. 초기 ContentState 생성
        let initialState = DeliveryAttributes.ContentState(
            status: .preparing,
            estimatedArrival: Date().addingTimeInterval(TimeInterval(estimatedMinutes * 60)),
            driverName: nil,
            driverImageURL: nil
        )
        
        // 4. Activity 시작
        let content = ActivityContent(
            state: initialState,
            staleDate: Date().addingTimeInterval(3600) // 1시간 후 stale 처리
        )
        
        let activity = try Activity.request(
            attributes: attributes,
            content: content,
            pushType: .token  // 푸시 업데이트 활성화
        )
        
        self.currentActivity = activity
        print("Activity 시작됨: \(activity.id)")
    }
}

enum ActivityError: Error {
    case notAuthorized
    case alreadyRunning
}
