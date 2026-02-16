import SwiftUI
import EventKit

struct CreateEventView: View {
    @EnvironmentObject var calendarManager: CalendarManager
    
    @State private var title = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(3600)
    @State private var selectedAlarm: AlarmOption = .none
    
    var body: some View {
        Form {
            Section("이벤트 정보") {
                TextField("제목", text: $title)
            }
            
            Section("시간") {
                DatePicker("시작", selection: $startDate)
                DatePicker("종료", selection: $endDate)
            }
            
            Section("알림") {
                AlarmPickerView(selectedAlarm: $selectedAlarm)
            }
        }
    }
}
