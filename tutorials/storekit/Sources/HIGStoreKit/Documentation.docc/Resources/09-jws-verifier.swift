import Foundation
import CryptoKit
import X509  // swift-certificates 패키지 필요

/// JWS 서명 검증기
struct JWSVerifier {
    
    /// Apple 루트 인증서 (Production)
    static let appleRootCertURL = URL(
        string: "https://www.apple.com/certificateauthority/AppleRootCA-G3.cer"
    )!
    
    /// JWS 서명 검증
    func verify(jws: String) async throws -> Bool {
        let parts = jws.split(separator: ".")
        guard parts.count == 3 else {
            throw VerificationError.invalidFormat
        }
        
        let headerPart = String(parts[0])
        let payloadPart = String(parts[1])
        let signaturePart = String(parts[2])
        
        // 1. 헤더에서 인증서 체인 추출
        let header = try decodeHeader(headerPart)
        
        // 2. 인증서 체인 검증
        guard try await verifyCertificateChain(header.x5c) else {
            throw VerificationError.certificateChainInvalid
        }
        
        // 3. 서명 검증
        let signingInput = "\(headerPart).\(payloadPart)"
        let leafCert = try extractLeafCertificate(from: header.x5c)
        
        return try verifySignature(
            input: signingInput,
            signature: signaturePart,
            publicKey: leafCert.publicKey
        )
    }
    
    /// JWS 페이로드 디코딩 (검증 후)
    func decode<T: Decodable>(_ type: T.Type, from jws: String) throws -> T {
        let parts = jws.split(separator: ".")
        guard parts.count == 3,
              let payloadData = Data(base64URLEncoded: String(parts[1])) else {
            throw VerificationError.invalidFormat
        }
        
        return try JSONDecoder().decode(type, from: payloadData)
    }
    
    // MARK: - Private
    
    private struct JWSHeader: Codable {
        let alg: String
        let x5c: [String]  // 인증서 체인 (Base64)
    }
    
    private func decodeHeader(_ base64: String) throws -> JWSHeader {
        guard let data = Data(base64URLEncoded: base64) else {
            throw VerificationError.invalidFormat
        }
        return try JSONDecoder().decode(JWSHeader.self, from: data)
    }
    
    private func verifyCertificateChain(_ chain: [String]) async throws -> Bool {
        // 인증서 체인의 각 단계를 검증
        // 1. Leaf cert → Intermediate cert 서명 확인
        // 2. Intermediate cert → Apple Root cert 서명 확인
        // 3. Apple Root cert가 신뢰할 수 있는지 확인
        
        // 실제 구현에서는 swift-certificates 또는 Security.framework 사용
        // 여기서는 개념적인 구조만 표시
        
        guard chain.count >= 2 else {
            return false
        }
        
        // Apple 루트 인증서와 체인의 마지막 인증서 비교
        // ... 구현 생략 ...
        
        return true
    }
    
    private func extractLeafCertificate(from chain: [String]) throws -> LeafCertificate {
        guard let leafCertBase64 = chain.first,
              let certData = Data(base64Encoded: leafCertBase64) else {
            throw VerificationError.certificateChainInvalid
        }
        
        // X.509 인증서에서 공개키 추출
        // swift-certificates 패키지 사용
        return LeafCertificate(publicKey: certData)
    }
    
    private func verifySignature(
        input: String,
        signature: String,
        publicKey: Data
    ) throws -> Bool {
        guard let signatureData = Data(base64URLEncoded: signature) else {
            throw VerificationError.invalidSignature
        }
        
        // ES256 서명 검증
        let inputData = Data(input.utf8)
        
        // P256 공개키로 서명 검증
        // ... CryptoKit 또는 Security.framework 사용 ...
        
        return true
    }
    
    struct LeafCertificate {
        let publicKey: Data
    }
    
    enum VerificationError: Error {
        case invalidFormat
        case certificateChainInvalid
        case invalidSignature
        case expired
    }
}
