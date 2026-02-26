import SwiftUI

@main
struct DocReaderApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            DocumentListView()
                .tabItem {
                    Label("문서", systemImage: "doc.text")
                }
            
            ScannerView()
                .tabItem {
                    Label("스캔", systemImage: "doc.text.viewfinder")
                }
        }
    }
}

#Preview {
    ContentView()
}
