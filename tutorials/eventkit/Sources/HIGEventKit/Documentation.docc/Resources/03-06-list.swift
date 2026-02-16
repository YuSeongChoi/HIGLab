import SwiftUI
import EventKit

struct CalendarListView: View {
    @EnvironmentObject var calendarManager: CalendarManager
    
    var body: some View {
        List(calendarManager.calendars, id: \.calendarIdentifier) { calendar in
            Text(calendar.title)
        }
        .navigationTitle("캘린더")
    }
}
