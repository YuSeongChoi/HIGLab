import SwiftUI

/// 러닝 트래커 앱 엔트리 포인트
@main
struct RunningTrackerApp: App {
    /// 앱 전체에서 공유할 LocationManager
    @StateObject private var locationManager = LocationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationManager)  // 하위 뷰에 전달
        }
    }
}
