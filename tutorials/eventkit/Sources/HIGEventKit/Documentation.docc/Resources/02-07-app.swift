import SwiftUI

@main
struct CalendarApp: App {
    @StateObject private var calendarManager = CalendarManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(calendarManager)
        }
    }
}
