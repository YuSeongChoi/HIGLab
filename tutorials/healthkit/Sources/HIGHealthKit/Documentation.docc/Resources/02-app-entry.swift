import SwiftUI

// MARK: - App Entry Point에서 HealthManager 주입

@main
struct FitnessDashboardApp: App {
    // 앱 레벨에서 HealthManager 인스턴스 생성
    @StateObject private var healthManager = HealthManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                // 모든 하위 뷰에서 접근 가능하도록 주입
                .environmentObject(healthManager)
        }
    }
}

// ContentView에서 HealthKit 사용 가능 여부에 따라 분기
struct ContentView: View {
    @EnvironmentObject var healthManager: HealthManager
    
    var body: some View {
        if healthManager.isHealthKitAvailable {
            DashboardView()
        } else {
            UnsupportedDeviceView()
        }
    }
}

struct UnsupportedDeviceView: View {
    var body: some View {
        ContentUnavailableView(
            "지원되지 않는 기기",
            systemImage: "heart.slash",
            description: Text("이 기기에서는 건강 데이터를 사용할 수 없습니다.")
        )
    }
}
