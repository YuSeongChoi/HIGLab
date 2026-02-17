import SwiftUI

// MARK: - 앱 진입점
/// SecureVault 앱의 @main 진입점
/// 앱 상태 관리 및 생명주기 처리

@main
struct SecureVaultApp: App {
    
    // MARK: - 상태 관리
    
    /// 인증 관리자 (앱 전역에서 공유)
    @StateObject private var authManager = AuthManager()
    
    /// 앱이 백그라운드로 전환되는지 감지
    @Environment(\.scenePhase) private var scenePhase
    
    // MARK: - 바디
    
    var body: some Scene {
        WindowGroup {
            // 인증 상태에 따라 화면 분기
            Group {
                if authManager.isAuthenticated {
                    // 인증됨 → 메인 콘텐츠
                    ContentView()
                } else {
                    // 잠금 상태 → 잠금 화면
                    LockScreenView()
                }
            }
            .environmentObject(authManager)
            .animation(.easeInOut(duration: 0.3), value: authManager.isAuthenticated)
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            handleScenePhaseChange(from: oldPhase, to: newPhase)
        }
    }
    
    // MARK: - 생명주기 처리
    
    /// 앱 상태 변화 처리
    private func handleScenePhaseChange(from oldPhase: ScenePhase, to newPhase: ScenePhase) {
        switch newPhase {
        case .background:
            // 백그라운드 진입 시 자동 잠금
            // HIG 권장: 민감한 정보를 다루는 앱은 백그라운드 진입 시 자동으로 잠가야 함
            authManager.lock()
            
        case .inactive:
            // 비활성 상태 (앱 전환 중, 알림 센터 등)
            // 필요시 민감한 정보 블러 처리 가능
            break
            
        case .active:
            // 활성 상태로 복귀
            // 자동 인증 시도하지 않음 (사용자가 명시적으로 인증)
            break
            
        @unknown default:
            break
        }
    }
}

// MARK: - 앱 설정 상수
enum AppConstants {
    /// 앱 이름
    static let appName = "SecureVault"
    
    /// 앱 버전
    static let version = "1.0.0"
    
    /// HIG 문서 URL
    static let higURL = URL(string: "https://developer.apple.com/design/human-interface-guidelines/authentication")!
    
    /// 인증 요청 사유 메시지
    static let authReason = "보안 금고에 접근하려면 인증이 필요합니다"
}
