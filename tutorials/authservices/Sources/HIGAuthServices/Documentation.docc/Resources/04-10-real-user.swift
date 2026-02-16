import AuthenticationServices

extension AppleSignInManager {
    
    func checkRealUserStatus(
        _ credential: ASAuthorizationAppleIDCredential
    ) {
        // realUserStatus: Apple이 판단한 사용자 진위 여부
        let status = credential.realUserStatus
        
        switch status {
        case .likelyReal:
            // 실제 사람일 가능성 높음
            // 추가 검증 없이 진행
            print("✅ 실제 사용자로 판단됨")
            proceedWithLogin(credential)
            
        case .unknown:
            // 판단 불가 (새 기기, 새 Apple ID 등)
            // 추가 검증 고려
            print("⚠️ 사용자 진위 불명")
            proceedWithCaution(credential)
            
        case .unsupported:
            // 이 기능을 지원하지 않는 환경
            print("ℹ️ realUserStatus 미지원")
            proceedWithLogin(credential)
            
        @unknown default:
            break
        }
    }
    
    private func proceedWithLogin(
        _ credential: ASAuthorizationAppleIDCredential
    ) {
        // 정상 로그인 진행
    }
    
    private func proceedWithCaution(
        _ credential: ASAuthorizationAppleIDCredential
    ) {
        // 추가 검증 후 로그인 진행
    }
}
