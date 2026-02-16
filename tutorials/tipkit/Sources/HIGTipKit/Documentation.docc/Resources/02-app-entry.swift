import SwiftUI
import TipKit

@main
struct TipKitDemoApp: App {
    
    init() {
        // 앱 시작 시 TipKit 초기화
        // Task로 감싸서 async 메서드 호출
        Task {
            try? await Tips.configure()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
