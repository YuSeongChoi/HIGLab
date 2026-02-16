import AuthenticationServices

// User Identifier는 앱-사용자 조합에 대해 고유합니다.
// 같은 사용자라도 다른 앱에서는 다른 ID를 받습니다.

func handleCredential(_ credential: ASAuthorizationAppleIDCredential) {
    // 고유 사용자 식별자 (항상 제공됨)
    let userIdentifier = credential.user
    // 예: "001234.abcdef1234567890.1234"
    
    // 이 값을 저장하여 사용자를 식별합니다
    saveToKeychain(userIdentifier)
    
    // 중요: 이 ID는 앱 간 추적에 사용될 수 없습니다
    // 앱 A의 ID ≠ 앱 B의 ID (같은 사용자라도)
}

func saveToKeychain(_ identifier: String) {
    // Keychain에 안전하게 저장
}
