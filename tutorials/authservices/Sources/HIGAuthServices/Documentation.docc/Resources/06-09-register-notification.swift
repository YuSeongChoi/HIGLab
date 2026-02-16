import AuthenticationServices
import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: 
            [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // Apple ID 연결 해제 알림 등록
        registerForAppleIDCredentialRevokedNotification()
        
        return true
    }
    
    private func registerForAppleIDCredentialRevokedNotification() {
        // credentialRevokedNotification 관찰
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCredentialRevoked),
            name: ASAuthorizationAppleIDProvider.credentialRevokedNotification,
            object: nil
        )
        
        print("Apple ID 연결 해제 알림 등록 완료")
    }
    
    @objc private func handleCredentialRevoked(_ notification: Notification) {
        // 앱 실행 중 연결 해제 감지
        print("⚠️ Apple ID 연결이 해제되었습니다")
        
        // 즉시 상태 재확인 후 로그아웃 처리
        DispatchQueue.main.async {
            // AuthManager를 통해 상태 확인 및 처리
            NotificationCenter.default.post(
                name: .appleIDCredentialRevoked,
                object: nil
            )
        }
    }
}

extension Notification.Name {
    static let appleIDCredentialRevoked = Notification.Name(
        "appleIDCredentialRevoked"
    )
}
