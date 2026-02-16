import SwiftUI
import AVFoundation

@main
struct CameraApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        CameraView()
    }
}
