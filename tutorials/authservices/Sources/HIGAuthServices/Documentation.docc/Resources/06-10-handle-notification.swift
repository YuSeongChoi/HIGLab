import AuthenticationServices

extension AppleAuthManager {
    
    func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            forName: ASAuthorizationAppleIDProvider.credentialRevokedNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleCredentialRevokedNotification()
        }
    }
    
    private func handleCredentialRevokedNotification() {
        // 알림 수신 시 상태 재확인
        // 중복 로그아웃 방지
        
        guard let userID = getSavedUserID() else {
            // 이미 로그아웃됨
            return
        }
        
        let provider = ASAuthorizationAppleIDProvider()
        
        provider.getCredentialState(forUserID: userID) { [weak self] state, _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if state == .revoked {
                    // 실제로 연결 해제된 경우만 로그아웃
                    print("연결 해제 확인됨 - 로그아웃 처리")
                    self.handleRevokedState()
                } else {
                    // 다른 앱의 연결 해제일 수 있음
                    print("현재 앱은 여전히 연결됨")
                }
            }
        }
    }
}
