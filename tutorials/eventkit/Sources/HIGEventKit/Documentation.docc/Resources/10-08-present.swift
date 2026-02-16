import SwiftUI
import EventKit

struct ContentView: View {
    @EnvironmentObject var calendarManager: CalendarManager
    @State private var showEditor = false
    
    var body: some View {
        NavigationStack {
            List {
                // 이벤트 목록
            }
            .toolbar {
                Button {
                    showEditor = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showEditor) {
                EventEditorWrapper(
                    eventStore: calendarManager.eventStore,
                    event: nil,
                    isPresented: $showEditor
                )
            }
        }
    }
}
