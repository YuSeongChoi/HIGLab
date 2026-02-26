import SwiftUI

@main
struct PeerChatApp: App {
    @State private var chatManager = ChatManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(chatManager)
        }
    }
}

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            PeerListView()
                .tabItem {
                    Label("주변", systemImage: "antenna.radiowaves.left.and.right")
                }
                .tag(0)
            
            ChatListView()
                .tabItem {
                    Label("채팅", systemImage: "bubble.left.and.bubble.right")
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
        .environment(ChatManager())
}
