import SwiftUI
import AuthenticationServices

@main
struct MyApp: App {
    @StateObject private var authManager = AuthenticationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .task {
                    // 앱 시작 시 Apple ID 상태 확인
                    await authManager.checkCredentialState()
                }
                .onReceive(
                    NotificationCenter.default.publisher(
                        for: UIApplication.willEnterForegroundNotification
                    )
                ) { _ in
                    // 포그라운드 진입 시마다 확인
                    Task {
                        await authManager.checkCredentialState()
                    }
                }
        }
    }
}

@MainActor
class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    
    func checkCredentialState() async {
        guard let userID = loadSavedUserID() else { return }
        
        let provider = ASAuthorizationAppleIDProvider()
        
        do {
            let state = try await provider.credentialState(forUserID: userID)
            isAuthenticated = (state == .authorized)
        } catch {
            isAuthenticated = false
        }
    }
    
    private func loadSavedUserID() -> String? {
        return nil // 구현
    }
}
