import Foundation
import CryptoKit

/// 서버 사이드: Promotional Offer 서명 생성
/// ⚠️ 이 코드는 서버에서 실행되어야 합니다.
/// 클라이언트에서 Private Key를 사용하면 안 됩니다!
struct OfferSigner {
    
    /// App Store Connect에서 생성한 Subscription Key
    private let keyId: String
    
    /// Private Key (PEM 형식)
    private let privateKey: P256.Signing.PrivateKey
    
    /// Bundle ID
    private let bundleId: String
    
    init(keyId: String, privateKeyPEM: String, bundleId: String) throws {
        self.keyId = keyId
        self.bundleId = bundleId
        self.privateKey = try P256.Signing.PrivateKey(pemRepresentation: privateKeyPEM)
    }
    
    /// Promotional Offer 서명 생성
    func generateSignature(
        productId: String,
        offerId: String,
        applicationUsername: String
    ) throws -> OfferSignature {
        // 고유 nonce 생성
        let nonce = UUID()
        
        // 현재 타임스탬프 (밀리초)
        let timestamp = Int(Date().timeIntervalSince1970 * 1000)
        
        // 서명할 페이로드 구성
        // 형식: appBundleID + keyIdentifier + productIdentifier + offerIdentifier + applicationUsername + nonce + timestamp
        let payload = [
            bundleId,
            keyId,
            productId,
            offerId,
            applicationUsername,
            nonce.uuidString,
            String(timestamp)
        ].joined(separator: "\u{2063}")  // Invisible separator
        
        // ECDSA P-256 서명
        let payloadData = Data(payload.utf8)
        let signature = try privateKey.signature(for: payloadData)
        let signatureBase64 = signature.derRepresentation.base64EncodedString()
        
        return OfferSignature(
            keyId: keyId,
            nonce: nonce,
            timestamp: timestamp,
            signature: signatureBase64
        )
    }
}

/// 클라이언트에 전달할 서명 정보
struct OfferSignature: Codable {
    let keyId: String
    let nonce: UUID
    let timestamp: Int
    let signature: String
}

// MARK: - API 엔드포인트 예시 (Server-side)

/*
 서버 API 예시 (Node.js/Swift Vapor/etc.):
 
 POST /api/promotional-offer/sign
 
 Request:
 {
   "productId": "com.app.premium.monthly",
   "offerId": "winback_50_off",
   "userId": "user123"
 }
 
 Response:
 {
   "keyId": "ABC123DEFG",
   "nonce": "550e8400-e29b-41d4-a716-446655440000",
   "timestamp": 1640000000000,
   "signature": "MEUCIQDr3..."
 }
*/

// MARK: - 클라이언트 API 호출

/// 클라이언트에서 서버 API 호출하여 서명 획득
class OfferSignatureService {
    let baseURL: URL
    
    init(baseURL: URL) {
        self.baseURL = baseURL
    }
    
    func requestSignature(
        productId: String,
        offerId: String,
        userId: String
    ) async throws -> OfferSignature {
        let url = baseURL.appendingPathComponent("promotional-offer/sign")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "productId": productId,
            "offerId": offerId,
            "userId": userId
        ]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw SignatureError.serverError
        }
        
        return try JSONDecoder().decode(OfferSignature.self, from: data)
    }
}

enum SignatureError: Error {
    case serverError
    case invalidSignature
}
