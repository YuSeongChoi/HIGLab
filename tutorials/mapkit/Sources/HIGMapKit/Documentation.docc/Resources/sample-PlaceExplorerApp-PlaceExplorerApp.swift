import SwiftUI

// MARK: - App Entry Point

@main
struct PlaceExplorerApp: App {
    
    /// 위치 관리자 (앱 전체에서 공유)
    @State private var locationManager = LocationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(locationManager)
        }
    }
}
