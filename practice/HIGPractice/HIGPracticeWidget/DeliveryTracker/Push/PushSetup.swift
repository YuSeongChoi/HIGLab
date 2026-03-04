//
//  PushSetup.swift
//  HIGPractice
//
//  Created by YuSeongChoi on 3/3/26.
//

import SwiftUI
import ActivityKit

// MARK: - Push Token 설정
// Live Activity는 전용 Push Token을 가집니다.
// 이 토큰으로 APNs를 통해 원격 업데이트가 가능합니다.

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
            pushType: .token // <- 중요!
        )
        
        self.currentActivity = activity
        
        // Push Token 관찰 시작
        observePushToken(for: activity)
    }
    
}

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
        guard let url = URL(string: "https://api.example.com/live-activity-register") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpReponse = response as? HTTPURLResponse, httpReponse.statusCode == 200 {
                print("Token 서버 등록 완료")
            }
        } catch {
            print("Token 등록 실패: \(error)")
        }
    }
    
}

extension DeliveryActivityManager {
    
    // MARK: - Token 갱신 처리
    
    func observeAllActivityTokens() {
        // 모든 Activity의 토큰 변경 감지
        for activity in Activity<DeliveryAttributes>.activities {
            observePushToken(for: activity)
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
