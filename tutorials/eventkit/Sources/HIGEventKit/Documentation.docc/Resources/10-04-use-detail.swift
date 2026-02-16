import SwiftUI
import EventKit

struct ContentView: View {
    @State private var selectedEvent: EKEvent?
    @State private var showDetail = false
    
    var body: some View {
        List {
            // 이벤트 목록...
        }
        .sheet(isPresented: $showDetail) {
            if let event = selectedEvent {
                NavigationStack {
                    EventDetailViewWrapper(event: event)
                }
            }
        }
    }
}
