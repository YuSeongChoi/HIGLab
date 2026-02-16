import SwiftUI
import TipKit

@main
struct TipKitDemoApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    // 앱 시작 시 Tips 초기화 (필수!)
                    try? await Tips.configure()
                }
        }
    }
}
