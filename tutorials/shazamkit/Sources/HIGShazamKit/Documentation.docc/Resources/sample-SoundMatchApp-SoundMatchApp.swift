import SwiftUI

// MARK: - SoundMatchApp
// ShazamKit 음악 인식 앱의 진입점

@main
struct SoundMatchApp: App {
    // MARK: - 상태 객체
    @State private var shazamManager = ShazamManager()
    @State private var history = MatchHistory.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(shazamManager)
                .environment(history)
        }
    }
}
