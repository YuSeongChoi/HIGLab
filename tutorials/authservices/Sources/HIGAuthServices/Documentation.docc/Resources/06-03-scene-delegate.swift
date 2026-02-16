import UIKit
import AuthenticationServices

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // 앱이 활성화될 때마다 Apple ID 상태 확인
        checkAppleIDCredentialState()
    }
    
    private func checkAppleIDCredentialState() {
        // 저장된 User Identifier 로드
        guard let userID = KeychainManager.loadCredentials(
            userIdentifier: "appleUserID"
        )?.userIdentifier else {
            // 로그인 기록 없음 - 확인 불필요
            return
        }
        
        let provider = ASAuthorizationAppleIDProvider()
        
        provider.getCredentialState(forUserID: userID) { state, error in
            DispatchQueue.main.async {
                if state == .revoked || state == .notFound {
                    // 연결 해제됨 - 로그아웃 처리
                    self.handleSessionInvalid()
                }
            }
        }
    }
    
    private func handleSessionInvalid() {
        // 로그아웃 처리 및 로그인 화면 표시
        NotificationCenter.default.post(
            name: .appleIDSessionRevoked, 
            object: nil
        )
    }
}

extension Notification.Name {
    static let appleIDSessionRevoked = Notification.Name(
        "appleIDSessionRevoked"
    )
}
