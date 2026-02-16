import CoreNFC
import Foundation

class URLTextParser {
    
    struct TextRecord {
        let text: String
        let locale: Locale?
        let languageCode: String
    }
    
    func parseTextRecord(_ record: NFCNDEFPayload) -> TextRecord? {
        // Well-Known Text 타입 확인
        guard record.typeNameFormat == .nfcWellKnown,
              String(data: record.type, encoding: .utf8) == "T" else {
            return nil
        }
        
        // 편의 메서드로 텍스트와 로케일 추출
        guard let (text, locale) = record.wellKnownTypeTextPayload() else {
            return nil
        }
        
        return TextRecord(
            text: text,
            locale: locale,
            languageCode: locale?.identifier ?? "unknown"
        )
    }
    
    // 사용 예시
    func processTextRecord(_ record: NFCNDEFPayload) {
        if let textRecord = parseTextRecord(record) {
            print("텍스트: \(textRecord.text)")
            print("언어: \(textRecord.languageCode)")
        }
    }
}
