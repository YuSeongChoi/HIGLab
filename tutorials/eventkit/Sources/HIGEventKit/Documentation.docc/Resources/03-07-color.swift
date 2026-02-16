import SwiftUI
import EventKit

struct CalendarListView: View {
    @EnvironmentObject var calendarManager: CalendarManager
    
    var body: some View {
        List(calendarManager.calendars, id: \.calendarIdentifier) { calendar in
            HStack {
                Circle()
                    .fill(Color(cgColor: calendar.cgColor))
                    .frame(width: 12, height: 12)
                
                Text(calendar.title)
            }
        }
        .navigationTitle("캘린더")
    }
}
