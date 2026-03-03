//
//  ActivityManager.swift
//  HIGPractice
//
//  Created by YuSeongChoi on 3/3/26.
//

import SwiftUI
import ActivityKit
import Combine

/*
 Activity 생명주기 관리
 - Live Activity를 시작, 업데이트, 종료하는 방법을 학습합니다.
 */

// Activity.request로 새 Live Activity를 시작합니다.
// 사용자 권한과 시스템 제한을 확인해야 합니다.

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
        // 설정에서 Live Activity가 켜져 있는지 확인
        guard areActivitiesEnabled else {
            print("Live Activitiese가 비활성화되어 있습니다.")
            print("설정 > 앱 > Live Activities 활성화 필요")
            return false
        }
        
        // 진행 중인 Activity 수 제한 확인 (앱당 1개 권장)
        let runningActivities = Activity<DeliveryAttributes>.activities
        if runningActivities.count >= 1{
            print("이미 진행 중인 배달이 있습니다.")
            return false
        }
        
        return true
    }
}


extension DeliveryActivityManager {
    
    // MARK: - Activity 시작
    
    func startDeliveryActivity(
        orderNumber: String,
        storeName: String,
        estimatedMinutes: Int
    ) async throws {
        // 1. 권한 접근
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
            pushType: .token // 푸시 업데이트 활성화
        )
        
        self.currentActivity = activity
        print("Activity 시작됨: \(activity.id)")
    }
    
}

// MARK: - Activity 업데이트
// ContentState를 업데이트하여 실시간 상태를 반영합니다.

extension DeliveryActivityManager {
    
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
        var estimatedArrival: Date = Date()
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

// MARK: - Activity 종료
// 배달 완료 시 Activity를 종료합니다.

extension DeliveryActivityManager {
    
    func endDeliveryActivity() async {
        guard let activity = currentActivity else {
            print("진행 중인 Activcity가 없습니다.")
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
        print("Activity 종료함")
    }
    
    // 주문 취소 시
    func cancelDeliveryActivity() async {
        guard let activity = currentActivity else { return }
        
        // 취소 상태로 종료 (즉시 제거)
        await activity.end(nil, dismissalPolicy: .immediate)
        self.currentActivity = nil
        print("Activity cnlthehla")
    }
    
}

enum ActivityError: Error {
    case notAuthorized
    case alreadyRunning
}
