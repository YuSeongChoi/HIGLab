import ActivityKit
import Combine
import Foundation
import os

// 이 파일은 Delivery Live Activity의 시작/업데이트/종료를 앱에서 제어하는 매니저입니다.
@MainActor
final class DeliveryActivityManager: ObservableObject {
    @Published private(set) var currentActivity: Activity<DeliveryAttributes>?
    @Published private(set) var lastMessage: String = ""

    var areActivitiesEnabled: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }

    func start() async {
        guard areActivitiesEnabled else {
            AppActivityLogger.logError(ActivityError.disabled, context: "start")
            lastMessage = "Live Activities 비활성화 상태입니다."
            return
        }

        if let existing = Activity<DeliveryAttributes>.activities.first {
            currentActivity = existing
            AppActivityLogger.lifecycle.info("기존 Activity 재사용: \(existing.id)")
            lastMessage = "기존 Activity 재사용: \(existing.id)"
            return
        }

        do {
            let attributes = DeliveryAttributes(
                orderNumber: "HIG-2026-0001",
                storeName: "HIG Kitchen",
                storeImageURL: nil,
                customerAddress: "서울시 강남구"
            )

            let state = DeliveryAttributes.ContentState(
                status: .preparing,
                orderTime: Date(),
                estimatedArrival: Date().addingTimeInterval(20 * 60),
                driverName: nil,
                driverImageURL: nil
            )

            let activity = try await SafeActivityManager.safeStart(
                attributes: attributes,
                state: state
            )
            currentActivity = activity
            lastMessage = "start 성공: \(activity.id)"
        } catch {
            AppActivityLogger.logError(error, context: "start")
            lastMessage = "start 실패: \(error.localizedDescription)"
        }
    }

    func update(status: DeliveryStatus, minutes: Int? = nil, driverName: String? = nil) async {
        guard let activity = currentActivity ?? Activity<DeliveryAttributes>.activities.first else {
            AppActivityLogger.lifecycle.warning("update 요청 무시: 대상 Activity 없음")
            lastMessage = "업데이트할 Activity가 없습니다."
            return
        }

        currentActivity = activity

        let eta = minutes.map { Date().addingTimeInterval(TimeInterval($0 * 60)) } ?? activity.content.state.estimatedArrival
        let state = DeliveryAttributes.ContentState(
            status: status,
            orderTime: Date(),
            estimatedArrival: eta,
            driverName: driverName ?? activity.content.state.driverName,
            driverImageURL: activity.content.state.driverImageURL
        )

        await SafeActivityManager.safeUpdate(activity: activity, state: state)
        lastMessage = "update 성공: \(status.rawValue)"
    }

    func end() async {
        guard let activity = currentActivity ?? Activity<DeliveryAttributes>.activities.first else {
            AppActivityLogger.lifecycle.warning("end 요청 무시: 대상 Activity 없음")
            lastMessage = "종료할 Activity가 없습니다."
            return
        }

        let final = DeliveryAttributes.ContentState(
            status: .delivered,
            orderTime: Date(),
            estimatedArrival: Date(),
            driverName: activity.content.state.driverName,
            driverImageURL: activity.content.state.driverImageURL
        )
        await SafeActivityManager.safeEnd(
            activity: activity,
            finalState: final,
            dismissalPolicy: .default
        )
        currentActivity = nil
        lastMessage = "end 성공"
    }
}
