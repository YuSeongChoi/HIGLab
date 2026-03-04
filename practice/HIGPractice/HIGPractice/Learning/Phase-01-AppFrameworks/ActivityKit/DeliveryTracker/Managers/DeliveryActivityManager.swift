import ActivityKit
import Combine
import Foundation
import os

@MainActor
final class DeliveryActivityManager: ObservableObject {
    @Published private(set) var currentActivity: Activity<DeliveryAttributes>?
    @Published private(set) var lastMessage: String = ""

    var areActivitiesEnabled: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }

    func start() async {
        guard areActivitiesEnabled else {
            lastMessage = "Live Activities 비활성화 상태입니다."
            ActivityDebugger.logger.error("start blocked: live activities disabled")
            return
        }

        if let existing = Activity<DeliveryAttributes>.activities.first {
            currentActivity = existing
            lastMessage = "기존 Activity 재사용: \(existing.id)"
            ActivityDebugger.logger.info("reusing existing activity id=\(existing.id, privacy: .public)")
            ActivityDebugger.logActivityState(existing)
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
                estimatedArrival: Date().addingTimeInterval(20 * 60),
                driverName: nil,
                driverImageURL: nil
            )

            let content = ActivityContent(state: state, staleDate: Date().addingTimeInterval(3600))
            let activity = try Activity.request(attributes: attributes, content: content, pushType: nil)
            currentActivity = activity
            lastMessage = "start 성공: \(activity.id)"
            ActivityDebugger.logger.info("start success id=\(activity.id, privacy: .public)")
            ActivityDebugger.logActivityState(activity)
        } catch {
            lastMessage = "start 실패: \(error.localizedDescription)"
            ActivityDebugger.logger.error("start failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    func update(status: DeliveryStatus, minutes: Int? = nil, driverName: String? = nil) async {
        guard let activity = currentActivity ?? Activity<DeliveryAttributes>.activities.first else {
            lastMessage = "업데이트할 Activity가 없습니다."
            ActivityDebugger.logger.error("update failed: no active activity")
            return
        }

        currentActivity = activity

        let eta = minutes.map { Date().addingTimeInterval(TimeInterval($0 * 60)) } ?? activity.content.state.estimatedArrival
        let state = DeliveryAttributes.ContentState(
            status: status,
            estimatedArrival: eta,
            driverName: driverName ?? activity.content.state.driverName,
            driverImageURL: activity.content.state.driverImageURL
        )

        await activity.update(ActivityContent(state: state, staleDate: Date().addingTimeInterval(3600)))
        lastMessage = "update 성공: \(status.displayName)"
        ActivityDebugger.logger.info("update success status=\(status.rawValue, privacy: .public)")
        ActivityDebugger.logActivityState(activity)
    }

    func end() async {
        guard let activity = currentActivity ?? Activity<DeliveryAttributes>.activities.first else {
            lastMessage = "종료할 Activity가 없습니다."
            ActivityDebugger.logger.error("end failed: no active activity")
            return
        }

        let final = DeliveryAttributes.ContentState(
            status: .delivered,
            estimatedArrival: Date(),
            driverName: activity.content.state.driverName,
            driverImageURL: activity.content.state.driverImageURL
        )
        await activity.end(ActivityContent(state: final, staleDate: nil), dismissalPolicy: .default)
        currentActivity = nil
        lastMessage = "end 성공"
        ActivityDebugger.logger.info("end success id=\(activity.id, privacy: .public)")
        ActivityDebugger.logAllDeliveryActivities()
    }
}
