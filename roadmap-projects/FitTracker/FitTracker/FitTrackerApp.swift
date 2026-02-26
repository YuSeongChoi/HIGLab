import SwiftUI

@main
struct FitTrackerApp: App {
    @State private var healthManager = HealthManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(healthManager)
        }
    }
}

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("오늘", systemImage: "heart.fill")
                }
                .tag(0)
            
            WorkoutView()
                .tabItem {
                    Label("운동", systemImage: "figure.run")
                }
                .tag(1)
            
            HistoryView()
                .tabItem {
                    Label("기록", systemImage: "calendar")
                }
                .tag(2)
        }
    }
}

#Preview {
    ContentView()
        .environment(HealthManager())
}
