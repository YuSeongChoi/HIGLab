import AuthenticationServices
import CryptoKit

class AppleSignInManager {
    
    private var currentNonce: String?
    
    func startSignIn() {
        // 1. 원본 nonce 생성 및 저장
        let nonce = generateNonce()
        currentNonce = nonce  // 서버 검증용으로 보관
        
        // 2. SHA256 해시 생성
        let hashedNonce = sha256(nonce)
        
        // 3. 요청에 해시된 nonce 설정
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = hashedNonce  // 해시값 전달
        
        // 4. 인증 실행...
    }
    
    // SHA256 해시 함수
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { 
            String(format: "%02x", $0) 
        }.joined()
    }
    
    func generateNonce(length: Int = 32) -> String {
        // 이전 단계에서 구현
        return ""
    }
}
