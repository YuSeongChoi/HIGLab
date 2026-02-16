import SwiftUI

struct ContentView: View {
    @EnvironmentObject var calendarManager: CalendarManager
    
    var body: some View {
        List(calendarManager.calendars, id: \.calendarIdentifier) { calendar in
            Text(calendar.title)
        }
        .onAppear {
            calendarManager.refresh()
        }
    }
}
