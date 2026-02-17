import Foundation
import CryptoKit

/// App Store Server API JWT 생성
struct AppStoreJWT {
    
    let keyID: String        // App Store Connect Key ID
    let issuerID: String     // App Store Connect Issuer ID  
    let bundleID: String     // 앱 번들 ID
    let privateKey: P256.Signing.PrivateKey
    
    /// JWT 토큰 생성
    func generateToken() throws -> String {
        let header = Header(kid: keyID)
        let payload = Payload(
            iss: issuerID,
            iat: Int(Date().timeIntervalSince1970),
            exp: Int(Date().addingTimeInterval(3600).timeIntervalSince1970),
            aud: "appstoreconnect-v1",
            bid: bundleID
        )
        
        // Header + Payload를 Base64URL 인코딩
        let headerData = try JSONEncoder().encode(header)
        let payloadData = try JSONEncoder().encode(payload)
        
        let headerString = headerData.base64URLEncodedString()
        let payloadString = payloadData.base64URLEncodedString()
        
        // 서명 생성
        let signingInput = "\(headerString).\(payloadString)"
        let signature = try privateKey.signature(for: Data(signingInput.utf8))
        let signatureString = signature.rawRepresentation.base64URLEncodedString()
        
        return "\(signingInput).\(signatureString)"
    }
    
    // MARK: - Types
    
    struct Header: Codable {
        let alg = "ES256"
        let typ = "JWT"
        let kid: String
    }
    
    struct Payload: Codable {
        let iss: String  // issuer ID
        let iat: Int     // issued at
        let exp: Int     // expiration
        let aud: String  // audience
        let bid: String  // bundle ID
    }
}

// MARK: - Base64URL

extension Data {
    func base64URLEncodedString() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
