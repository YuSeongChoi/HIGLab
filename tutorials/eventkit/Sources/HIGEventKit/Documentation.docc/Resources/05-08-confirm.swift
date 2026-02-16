import SwiftUI
import EventKit

struct EventDetailView: View {
    @EnvironmentObject var calendarManager: CalendarManager
    let event: EKEvent
    
    @State private var showDeleteAlert = false
    
    var body: some View {
        List {
            Text(event.title)
            Text(event.startDate, style: .date)
        }
        .toolbar {
            Button(role: .destructive) {
                showDeleteAlert = true
            } label: {
                Image(systemName: "trash")
            }
        }
        .alert("이벤트 삭제", isPresented: $showDeleteAlert) {
            Button("삭제", role: .destructive) {
                try? calendarManager.deleteEvent(event)
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("이 이벤트를 삭제하시겠습니까?")
        }
    }
}
