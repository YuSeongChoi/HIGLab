import CoreNFC

class RecordParser {
    
    struct MediaRecord {
        let mimeType: String
        let data: Data
    }
    
    func parseMedia(_ record: NFCNDEFPayload) -> MediaRecord? {
        guard record.typeNameFormat == .media else { return nil }
        
        // Type 필드가 MIME 타입을 나타냄
        // 예: "text/plain", "application/json", "image/png"
        guard let mimeType = String(data: record.type, encoding: .utf8) else {
            return nil
        }
        
        print("MIME Type: \(mimeType)")
        print("Data Size: \(record.payload.count) bytes")
        
        // MIME 타입에 따른 처리
        if mimeType.hasPrefix("text/") {
            // 텍스트 데이터
            if let text = String(data: record.payload, encoding: .utf8) {
                print("Content: \(text)")
            }
        } else if mimeType == "application/json" {
            // JSON 데이터
            if let json = try? JSONSerialization.jsonObject(with: record.payload) {
                print("JSON: \(json)")
            }
        } else if mimeType.hasPrefix("image/") {
            // 이미지 데이터 (NFC 태그 용량 제한으로 드묾)
            print("Image data received")
        }
        
        return MediaRecord(mimeType: mimeType, data: record.payload)
    }
}
