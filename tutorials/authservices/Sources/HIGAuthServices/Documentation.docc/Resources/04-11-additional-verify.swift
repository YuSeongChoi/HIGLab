import AuthenticationServices

extension AppleSignInManager {
    
    func handleUnknownUser(
        _ credential: ASAuthorizationAppleIDCredential
    ) {
        // realUserStatus가 .unknown인 경우
        // 봇이나 자동화된 계정일 가능성 고려
        
        // 옵션 1: 이메일 인증 요청
        if let email = credential.email {
            sendVerificationEmail(to: email)
        }
        
        // 옵션 2: 전화번호 인증 추가
        // requestPhoneVerification()
        
        // 옵션 3: 제한된 기능만 제공
        // grantLimitedAccess(credential.user)
        
        // 옵션 4: reCAPTCHA 등 추가 검증
        // showCaptchaChallenge()
    }
    
    private func sendVerificationEmail(to email: String) {
        print("인증 이메일 발송: \(email)")
        // 이메일 발송 로직
    }
    
    // 보안 수준에 따른 대응 전략
    enum SecurityLevel {
        case low      // 대부분 신뢰
        case medium   // unknown 시 이메일 인증
        case high     // unknown 시 다중 인증
    }
}
