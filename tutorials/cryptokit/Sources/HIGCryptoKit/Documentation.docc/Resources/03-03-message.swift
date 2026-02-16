import CryptoKit
import Foundation

// 메시지 인증 시스템
struct AuthenticatedMessage {
    let content: Data
    let authCode: Data
    
    init(content: String, key: SymmetricKey) {
        self.content = Data(content.utf8)
        let hmac = HMAC<SHA256>.authenticationCode(for: self.content, using: key)
        self.authCode = Data(hmac)
    }
    
    func verify(using key: SymmetricKey) -> Bool {
        HMAC<SHA256>.isValidAuthenticationCode(
            authCode,
            authenticating: content,
            using: key
        )
    }
}
