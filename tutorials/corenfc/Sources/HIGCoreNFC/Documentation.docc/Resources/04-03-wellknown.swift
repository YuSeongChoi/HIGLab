import CoreNFC

class RecordParser {
    
    func parse(_ record: NFCNDEFPayload) -> String {
        switch record.typeNameFormat {
        case .nfcWellKnown:
            return parseWellKnown(record)
        default:
            return "기타 타입"
        }
    }
    
    private func parseWellKnown(_ record: NFCNDEFPayload) -> String {
        // Well-Known 타입의 type 필드 확인
        let typeString = String(data: record.type, encoding: .utf8) ?? ""
        
        switch typeString {
        case "T":
            // Text 레코드
            if let (text, locale) = record.wellKnownTypeTextPayload() {
                return "텍스트 [\(locale?.identifier ?? "?")]: \(text)"
            }
            return "텍스트 파싱 실패"
            
        case "U":
            // URI 레코드
            if let url = record.wellKnownTypeURIPayload() {
                return "URL: \(url.absoluteString)"
            }
            return "URL 파싱 실패"
            
        case "Sp":
            // Smart Poster (여러 레코드 포함)
            return "Smart Poster"
            
        case "act":
            // Action 레코드
            return "Action 레코드"
            
        case "s":
            // Size 레코드
            return "Size 레코드"
            
        case "t":
            // Type 레코드 (MIME)
            return "Type 레코드"
            
        default:
            return "Unknown Well-Known: \(typeString)"
        }
    }
}
