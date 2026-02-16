import CoreNFC
import Foundation

// 텍스트 레코드 바이트 구조
//
// Byte 0: 상태 바이트
//   - Bit 7: 인코딩 (0 = UTF-8, 1 = UTF-16)
//   - Bit 6: 예약됨
//   - Bit 5-0: 언어 코드 길이 (IANA 형식)
//
// Byte 1~N: 언어 코드 (예: "en", "ko", "ja")
// Byte N+1~: 실제 텍스트

func parseTextManually(_ payload: Data) -> (text: String, language: String)? {
    guard !payload.isEmpty else { return nil }
    
    let statusByte = payload[0]
    
    // 인코딩 확인 (bit 7)
    let isUTF16 = (statusByte & 0x80) != 0
    let encoding: String.Encoding = isUTF16 ? .utf16 : .utf8
    
    // 언어 코드 길이 (bit 0-5)
    let languageCodeLength = Int(statusByte & 0x3F)
    
    guard payload.count > languageCodeLength + 1 else { return nil }
    
    // 언어 코드 추출
    let languageCodeData = payload[1..<(1 + languageCodeLength)]
    let languageCode = String(data: languageCodeData, encoding: .utf8) ?? "?"
    
    // 텍스트 추출
    let textData = payload[(1 + languageCodeLength)...]
    guard let text = String(data: textData, encoding: encoding) else {
        return nil
    }
    
    return (text, languageCode)
}
