import SwiftUI

struct ReminderScheduleView: View {
    @State private var title = ""
    @State private var selectedDate = Date()
    @State private var isScheduled = false
    
    var body: some View {
        Form {
            Section("리마인더 내용") {
                TextField("제목", text: $title)
            }
            
            Section("알림 시간") {
                DatePicker(
                    "알림 받을 시간",
                    selection: $selectedDate,
                    in: Date()...,  // 현재 이후만 선택 가능
                    displayedComponents: [.date, .hourAndMinute]
                )
            }
            
            Section {
                Button("리마인더 설정") {
                    scheduleReminder()
                }
                .disabled(title.isEmpty)
            }
        }
        .alert("알림 예약됨", isPresented: $isScheduled) {
            Button("확인", role: .cancel) {}
        }
    }
    
    private func scheduleReminder() {
        Task {
            try? await NotificationManager.shared.scheduleNotification(
                title: title,
                body: "탭하여 확인하세요",
                at: selectedDate
            )
            isScheduled = true
        }
    }
}
