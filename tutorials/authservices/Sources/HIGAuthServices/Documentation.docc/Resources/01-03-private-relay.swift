import AuthenticationServices

// Private Email Relay 예시
// 사용자가 "이메일 숨기기"를 선택하면:
// 실제 이메일: user@example.com
// 앱에 전달됨: abc123xyz@privaterelay.appleid.com

func handleCredential(_ credential: ASAuthorizationAppleIDCredential) {
    if let email = credential.email {
        // Private Relay 이메일인지 확인
        if email.contains("privaterelay.appleid.com") {
            print("Private Email Relay 사용 중")
            // 이 이메일로도 정상적으로 메일 발송 가능
            // (발신 도메인 등록 필요)
        } else {
            print("실제 이메일 공유됨")
        }
    }
}
