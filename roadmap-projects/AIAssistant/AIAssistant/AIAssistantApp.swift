import SwiftUI

@main
struct AIAssistantApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ChatView()
                .tabItem {
                    Label("채팅", systemImage: "bubble.left.and.bubble.right")
                }
                .tag(0)
            
            ImageAnalysisView()
                .tabItem {
                    Label("이미지 분석", systemImage: "photo.on.rectangle.angled")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Label("설정", systemImage: "gear")
                }
                .tag(2)
        }
    }
}

#Preview {
    ContentView()
}
