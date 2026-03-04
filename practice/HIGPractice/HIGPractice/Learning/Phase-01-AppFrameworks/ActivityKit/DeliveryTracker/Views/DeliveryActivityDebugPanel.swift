import SwiftUI

struct DeliveryActivityDebugPanel: View {
    @StateObject private var manager = DeliveryActivityManager()

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

                Button("Nearby") {
                    Task { await manager.update(status: .nearby, minutes: 3) }
                }
                .buttonStyle(.bordered)

                Button("Delivered") {
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
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
    }
}
