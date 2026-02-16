import CoreNFC

// 종합 NDEF 레코드 파서
class NDEFRecordParser {
    
    enum ParsedRecord {
        case text(String, locale: Locale?)
        case url(URL)
        case media(mimeType: String, data: Data)
        case external(domain: String, type: String, data: Data)
        case smartPoster([ParsedRecord])
        case unknown(Data)
        case empty
    }
    
    func parse(_ record: NFCNDEFPayload) -> ParsedRecord {
        switch record.typeNameFormat {
        case .empty:
            return .empty
            
        case .nfcWellKnown:
            return parseWellKnown(record)
            
        case .media:
            let mimeType = String(data: record.type, encoding: .utf8) ?? "application/octet-stream"
            return .media(mimeType: mimeType, data: record.payload)
            
        case .absoluteURI:
            if let urlString = String(data: record.type, encoding: .utf8),
               let url = URL(string: urlString) {
                return .url(url)
            }
            return .unknown(record.payload)
            
        case .nfcExternal:
            let typeString = String(data: record.type, encoding: .utf8) ?? ""
            let components = typeString.split(separator: ":")
            let domain = components.first.map(String.init) ?? typeString
            let type = components.dropFirst().first.map(String.init) ?? ""
            return .external(domain: domain, type: type, data: record.payload)
            
        case .unknown, .unchanged:
            return .unknown(record.payload)
            
        @unknown default:
            return .unknown(record.payload)
        }
    }
    
    private func parseWellKnown(_ record: NFCNDEFPayload) -> ParsedRecord {
        let typeString = String(data: record.type, encoding: .utf8) ?? ""
        
        switch typeString {
        case "T":
            if let (text, locale) = record.wellKnownTypeTextPayload() {
                return .text(text, locale: locale)
            }
        case "U":
            if let url = record.wellKnownTypeURIPayload() {
                return .url(url)
            }
        default:
            break
        }
        
        return .unknown(record.payload)
    }
    
    // 전체 메시지 파싱
    func parseMessage(_ message: NFCNDEFMessage) -> [ParsedRecord] {
        return message.records.map { parse($0) }
    }
}
