import AuthenticationServices

extension CredentialStateChecker {
    
    func handleCredentialState(
        _ state: ASAuthorizationAppleIDProvider.CredentialState
    ) {
        switch state {
            
        case .authorized:
            // ✅ 정상 연결됨
            // 앱 사용 계속 허용
            print("Apple ID 연결 상태: 정상")
            proceedToMainApp()
            
        case .revoked:
            // ❌ 사용자가 연결 해제함
            // 로그아웃 처리 필수
            print("Apple ID 연결 해제됨")
            performLogout()
            
        case .notFound:
            // ⚠️ 인증 기록 없음
            // 로그인 화면 표시
            print("Apple ID 인증 기록 없음")
            showLoginScreen()
            
        case .transferred:
            // 🔄 앱 소유권 이전됨
            // 마이그레이션 처리
            print("앱 이전됨 - 계정 마이그레이션 필요")
            handleTransfer()
            
        @unknown default:
            break
        }
    }
    
    private func proceedToMainApp() { }
    private func performLogout() { }
    private func showLoginScreen() { }
    private func handleTransfer() { }
}
