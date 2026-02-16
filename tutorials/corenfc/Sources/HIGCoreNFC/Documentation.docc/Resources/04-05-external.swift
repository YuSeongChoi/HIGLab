import CoreNFC

class RecordParser {
    
    struct ExternalRecord {
        let domain: String
        let typeName: String
        let data: Data
    }
    
    func parseExternal(_ record: NFCNDEFPayload) -> ExternalRecord? {
        guard record.typeNameFormat == .nfcExternal else { return nil }
        
        // Type 필드: "도메인:타입" 형식
        // 예: "example.com:mydata", "com.myapp:config"
        guard let typeString = String(data: record.type, encoding: .utf8) else {
            return nil
        }
        
        // 도메인과 타입 분리
        let components = typeString.split(separator: ":")
        let domain: String
        let typeName: String
        
        if components.count >= 2 {
            domain = String(components[0])
            typeName = String(components[1])
        } else {
            domain = typeString
            typeName = ""
        }
        
        print("External 타입:")
        print("  Domain: \(domain)")
        print("  Type: \(typeName)")
        print("  Data: \(record.payload.count) bytes")
        
        // 앱 고유 데이터 처리
        // 예: 제품 ID, 설정 정보, 암호화된 데이터 등
        
        return ExternalRecord(
            domain: domain,
            typeName: typeName,
            data: record.payload
        )
    }
}
