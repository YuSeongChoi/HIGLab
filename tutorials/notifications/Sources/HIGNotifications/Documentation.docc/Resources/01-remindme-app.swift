import SwiftUI

@main
struct RemindMeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ReminderListView()
                .navigationTitle("RemindMe")
        }
    }
}

struct ReminderListView: View {
    var body: some View {
        List {
            Text("리마인더 목록이 여기 표시됩니다")
        }
    }
}
