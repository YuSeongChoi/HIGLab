import SwiftUI
import EventKit

struct CreateEventView: View {
    @EnvironmentObject var calendarManager: CalendarManager
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(3600)
    
    var body: some View {
        Form {
            Section("이벤트 정보") {
                TextField("제목", text: $title)
            }
            
            Section("시간") {
                DatePicker("시작", selection: $startDate)
                DatePicker("종료", selection: $endDate)
            }
        }
        .navigationTitle("새 이벤트")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("저장") {
                    saveEvent()
                }
                .disabled(title.isEmpty)
            }
        }
    }
    
    private func saveEvent() {
        let event = calendarManager.createEvent(
            title: title,
            startDate: startDate,
            endDate: endDate
        )
        
        do {
            try calendarManager.saveEvent(event)
            dismiss()
        } catch {
            // 에러 처리
        }
    }
}
