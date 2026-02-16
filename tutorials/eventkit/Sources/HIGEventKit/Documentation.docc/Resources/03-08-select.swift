import SwiftUI
import EventKit

struct CalendarListView: View {
    @EnvironmentObject var calendarManager: CalendarManager
    @Binding var selectedCalendar: EKCalendar?
    
    var body: some View {
        List(calendarManager.calendars, id: \.calendarIdentifier) { calendar in
            HStack {
                Circle()
                    .fill(Color(cgColor: calendar.cgColor))
                    .frame(width: 12, height: 12)
                
                Text(calendar.title)
                
                Spacer()
                
                if calendar == selectedCalendar {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                selectedCalendar = calendar
            }
        }
        .navigationTitle("캘린더")
    }
}
