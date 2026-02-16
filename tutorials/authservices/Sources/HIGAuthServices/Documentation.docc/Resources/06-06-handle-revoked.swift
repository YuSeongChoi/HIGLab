import AuthenticationServices

extension AppleAuthManager {
    
    func handleRevokedState() {
        // 1. 로컬 세션 데이터 삭제
        clearLocalSession()
        
        // 2. Keychain에서 자격 증명 삭제
        deleteStoredCredentials()
        
        // 3. UI 상태 업데이트
        authState = .unauthenticated
        
        // 4. 로그인 화면으로 이동
        navigateToLogin()
    }
    
    private func clearLocalSession() {
        // UserDefaults 정리
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "sessionToken")
        
        // 메모리 내 세션 데이터 초기화
        // ...
        
        print("로컬 세션 삭제 완료")
    }
    
    private func deleteStoredCredentials() {
        // Keychain에서 Apple 자격 증명 삭제
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.example.myapp.appleid"
        ]
        SecItemDelete(query as CFDictionary)
        
        print("Keychain 자격 증명 삭제 완료")
    }
    
    private func navigateToLogin() {
        // 로그인 화면 표시 알림
        NotificationCenter.default.post(
            name: .showLoginScreen,
            object: nil
        )
    }
}

extension Notification.Name {
    static let showLoginScreen = Notification.Name("showLoginScreen")
}
