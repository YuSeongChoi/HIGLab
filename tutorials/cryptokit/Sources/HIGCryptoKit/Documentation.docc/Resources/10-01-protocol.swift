import CryptoKit
import Foundation

// 암호화 서비스 프로토콜
protocol CryptoService {
    func encrypt(_ data: Data, for recipient: PublicKeyBundle) throws -> EncryptedPayload
    func decrypt(_ payload: EncryptedPayload) throws -> Data
    func sign(_ data: Data) throws -> Data
    func verify(_ signature: Data, for data: Data, from sender: PublicKeyBundle) -> Bool
}

// 공개 키 번들
struct PublicKeyBundle: Codable {
    let keyAgreement: Data  // 암호화용
    let signing: Data       // 서명 검증용
    let userId: String
}

// 암호화된 페이로드
struct EncryptedPayload: Codable {
    let ciphertext: Data
    let ephemeralPublicKey: Data  // 일회용 키
    let signature: Data
}
