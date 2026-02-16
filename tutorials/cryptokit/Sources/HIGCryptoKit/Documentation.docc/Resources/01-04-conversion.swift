import CryptoKit
import Foundation

// 데이터 변환 유틸리티
extension String {
    var data: Data { Data(utf8) }
}

extension Data {
    var base64: String { base64EncodedString() }
    var hex: String { map { String(format: "%02x", $0) }.joined() }
}

// 사용 예시
let message = "Hello, CryptoKit!"
let messageData = message.data
print("Base64: \(messageData.base64)")
print("Hex: \(messageData.hex)")
