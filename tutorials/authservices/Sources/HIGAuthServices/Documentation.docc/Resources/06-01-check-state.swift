import AuthenticationServices

class CredentialStateChecker {
    
    func checkCredentialState(userID: String) {
        let provider = ASAuthorizationAppleIDProvider()
        
        // 비동기로 상태 확인
        provider.getCredentialState(forUserID: userID) { state, error in
            
            if let error = error {
                print("상태 확인 실패: \(error)")
                return
            }
            
            // Main 스레드에서 UI 업데이트
            DispatchQueue.main.async {
                self.handleCredentialState(state)
            }
        }
    }
    
    private func handleCredentialState(
        _ state: ASAuthorizationAppleIDProvider.CredentialState
    ) {
        // 상태에 따른 처리
    }
}
