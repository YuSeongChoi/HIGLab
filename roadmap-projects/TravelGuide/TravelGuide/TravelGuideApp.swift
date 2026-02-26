import SwiftUI

@main
struct TravelGuideApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            MapExploreView()
                .tabItem {
                    Label("탐색", systemImage: "map")
                }
            
            WeatherView()
                .tabItem {
                    Label("날씨", systemImage: "cloud.sun")
                }
            
            ItineraryView()
                .tabItem {
                    Label("일정", systemImage: "calendar")
                }
        }
    }
}

#Preview {
    ContentView()
}
