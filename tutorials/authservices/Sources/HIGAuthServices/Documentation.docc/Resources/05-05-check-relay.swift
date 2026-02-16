import AuthenticationServices

extension AppleSignInManager {
    
    /// Private Email Relay 사용 여부 확인
    func isPrivateRelayEmail(_ email: String) -> Bool {
        return email.hasSuffix("@privaterelay.appleid.com")
    }
    
    func handleEmail(_ email: String) {
        if isPrivateRelayEmail(email) {
            // Private Relay 이메일
            // - 사용자의 실제 이메일을 알 수 없음
            // - 이 주소로 이메일 발송 가능 (도메인 등록 필요)
            // - 사용자가 설정에서 릴레이를 해제할 수 있음
            print("🔒 Private Email Relay 사용 중")
            print("이 이메일로 발송하려면 도메인 등록이 필요합니다")
        } else {
            // 실제 이메일
            // - 바로 이메일 발송 가능
            print("📧 실제 이메일 주소")
        }
    }
}
