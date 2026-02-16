import Foundation
import CryptoKit

class AppleSignInManager {
    
    // 현재 로그인 세션의 nonce 저장
    private var currentNonce: String?
    
    // 랜덤 nonce 생성 (32바이트)
    func generateNonce(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(
            kSecRandomDefault, 
            randomBytes.count, 
            &randomBytes
        )
        
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce")
        }
        
        let charset: [Character] = Array(
            "0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._"
        )
        
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
}
