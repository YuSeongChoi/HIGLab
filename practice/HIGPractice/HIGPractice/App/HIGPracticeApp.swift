import SwiftUI

@main
struct HIGPracticeApp: App {
    @StateObject private var progressStore = LearningProgressStore()

    var body: some Scene {
        WindowGroup {
            PracticeHomeView()
                .environmentObject(progressStore)
        }
    }
}
