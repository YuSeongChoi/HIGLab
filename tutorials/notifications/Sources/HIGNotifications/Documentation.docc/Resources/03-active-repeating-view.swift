import SwiftUI

struct ActiveRepeatingView: View {
    @State private var pendingNotifications: [UNNotificationRequest] = []
    
    var body: some View {
        List {
            ForEach(pendingNotifications, id: \.identifier) { request in
                VStack(alignment: .leading) {
                    Text(request.content.title)
                        .font(.headline)
                    Text(request.identifier)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .onDelete { indexSet in
                deleteNotifications(at: indexSet)
            }
        }
        .navigationTitle("활성 알림")
        .task {
            await loadNotifications()
        }
    }
    
    private func loadNotifications() async {
        pendingNotifications = await NotificationManager.shared.getPendingNotifications()
    }
    
    private func deleteNotifications(at offsets: IndexSet) {
        let identifiers = offsets.map { pendingNotifications[$0].identifier }
        NotificationManager.shared.cancelNotifications(identifiers: identifiers)
        pendingNotifications.remove(atOffsets: offsets)
    }
}
