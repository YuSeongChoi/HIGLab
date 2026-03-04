import SwiftUI
import ActivityKit

// 이 파일은 ActivityKit 학습용 로컬 테스트 패널(Start/Update/End 버튼 UI)입니다.
struct DeliveryActivityDebugPanel: View {
    @StateObject private var manager = DeliveryActivityManager()
    @StateObject private var monitor = ActivityMonitor<DeliveryAttributes>()

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ActivityKit Local Test")
                .font(.headline)
            Text(manager.areActivitiesEnabled ? "Live Activities: ON" : "Live Activities: OFF")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack {
                Button("Start") {
                    Task { await manager.start() }
                }
                .buttonStyle(.borderedProminent)

                Button("End") {
                    Task { await manager.end() }
                }
                .buttonStyle(.bordered)
            }

            HStack {
                Button("Picked Up") {
                    Task { await manager.update(status: .pickedUp, minutes: 10, driverName: "김배달") }
                }
                .buttonStyle(.bordered)
                
                Button("Delivering") {
                    Task { await manager.update(status: .nearby, minutes: 5, driverName: "김배달") }
                }
                .buttonStyle(.bordered)

                Button("Arrived") {
                    Task { await manager.update(status: .delivered, minutes: 0) }
                }
                .buttonStyle(.bordered)
            }
            .font(.caption)

            if !manager.lastMessage.isEmpty {
                Text(manager.lastMessage)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Divider()

            HStack {
                Text("Active Activities: \(monitor.activities.count)")
                    .font(.caption.weight(.semibold))
                Spacer()
                Button("Refresh") {
                    monitor.refreshActivities()
                }
                .font(.caption2)
                .buttonStyle(.bordered)
            }

            if monitor.activities.isEmpty {
                Text("활성 Activity 없음")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(monitor.activities, id: \.id) { activity in
                    VStack(alignment: .leading, spacing: 2) {
                        Text("id=\(activity.id)")
                            .font(.caption2.monospaced())
                        Text("state=\(String(describing: activity.activityState))")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
    }
}
