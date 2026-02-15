import ActivityKit

extension DeliveryActivityManager {
    
    // MARK: - Push Token 서버 전송
    
    func observePushToken(for activity: Activity<DeliveryAttributes>) {
        Task {
            // pushTokenUpdates: 토큰이 변경될 때마다 새 값 방출
            for await tokenData in activity.pushTokenUpdates {
                let token = tokenData.map { String(format: "%02x", $0) }.joined()
                print("Push Token: \(token)")
                
                // 서버에 토큰 전송
                await sendTokenToServer(
                    activityId: activity.id,
                    token: token
                )
            }
        }
    }
    
    func sendTokenToServer(activityId: String, token: String) async {
        // 서버 API 호출
        let payload = [
            "activity_id": activityId,
            "push_token": token,
            "platform": "ios"
        ]
        
        // URLSession으로 서버에 전송
        guard let url = URL(string: "https://api.example.com/live-activity/register") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("Token 서버 등록 완료")
            }
        } catch {
            print("Token 등록 실패: \(error)")
        }
    }
}
