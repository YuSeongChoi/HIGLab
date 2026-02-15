import ActivityKit

extension DeliveryActivityManager {
    
    // MARK: - Token 갱신 처리
    
    func observeAllActivityTokens() {
        Task {
            // 모든 Activity의 토큰 변경 감지
            for activity in Activity<DeliveryAttributes>.activities {
                observePushToken(for: activity)
            }
        }
    }
    
    // Activity 상태 변경 감지
    func observeActivityState(for activity: Activity<DeliveryAttributes>) {
        Task {
            for await state in activity.activityStateUpdates {
                switch state {
                case .active:
                    print("Activity 활성화됨")
                case .ended:
                    print("Activity 종료됨")
                case .dismissed:
                    print("Activity 닫힘")
                case .stale:
                    print("Activity 오래됨")
                @unknown default:
                    break
                }
            }
        }
    }
    
    // Content 업데이트 감지 (푸시로 업데이트됐을 때)
    func observeContentUpdates(for activity: Activity<DeliveryAttributes>) {
        Task {
            for await content in activity.contentUpdates {
                print("Content 업데이트됨: \(content.state.status.displayName)")
            }
        }
    }
}
