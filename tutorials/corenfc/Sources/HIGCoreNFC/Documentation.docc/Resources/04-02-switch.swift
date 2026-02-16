import CoreNFC

class RecordParser {
    
    func parse(_ record: NFCNDEFPayload) -> String {
        switch record.typeNameFormat {
        case .empty:
            return "빈 레코드"
            
        case .nfcWellKnown:
            return parseWellKnown(record)
            
        case .media:
            return parseMedia(record)
            
        case .absoluteURI:
            return parseAbsoluteURI(record)
            
        case .nfcExternal:
            return parseExternal(record)
            
        case .unknown:
            return "알 수 없는 형식: \(record.payload.count) bytes"
            
        case .unchanged:
            return "청크 데이터 (이전 레코드 연속)"
            
        @unknown default:
            return "지원하지 않는 TNF"
        }
    }
    
    private func parseWellKnown(_ record: NFCNDEFPayload) -> String {
        // 다음 스텝에서 구현
        return "Well-Known 타입"
    }
    
    private func parseMedia(_ record: NFCNDEFPayload) -> String {
        return "Media 타입"
    }
    
    private func parseAbsoluteURI(_ record: NFCNDEFPayload) -> String {
        return "Absolute URI 타입"
    }
    
    private func parseExternal(_ record: NFCNDEFPayload) -> String {
        return "External 타입"
    }
}
