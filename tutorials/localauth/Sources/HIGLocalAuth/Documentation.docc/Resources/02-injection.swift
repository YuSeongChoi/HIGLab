import SwiftUI

// SwiftUI Environment를 통한 의존성 주입

// 1. EnvironmentKey 정의
struct AuthenticationManagerKey: EnvironmentKey {
    static let defaultValue = AuthenticationManager()
}

extension EnvironmentValues {
    var authManager: AuthenticationManager {
        get { self[AuthenticationManagerKey.self] }
        set { self[AuthenticationManagerKey.self] = newValue }
    }
}

// 2. App에서 설정
@main
struct SecureVaultApp: App {
    @State private var authManager = AuthenticationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.authManager, authManager)
        }
    }
}

// 3. View에서 사용
struct LockScreenView: View {
    @Environment(\.authManager) private var authManager
    
    var body: some View {
        Button("잠금 해제") {
            Task {
                await authManager.authenticate()
            }
        }
    }
}
