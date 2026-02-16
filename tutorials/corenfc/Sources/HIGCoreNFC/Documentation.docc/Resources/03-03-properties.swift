import CoreNFC

struct RecordInfo {
    let typeNameFormat: NFCTypeNameFormat
    let type: Data
    let identifier: Data
    let payload: Data
}

func analyzeRecord(_ record: NFCNDEFPayload) -> RecordInfo {
    // 1. Type Name Format (TNF)
    // - 레코드 타입을 해석하는 방법을 정의
    let tnf = record.typeNameFormat
    
    // 2. Type
    // - TNF에 따라 해석되는 레코드 타입
    // - Well-Known 타입: "T" (텍스트), "U" (URI)
    let type = record.type
    
    // 3. Identifier (선택적)
    // - 레코드를 식별하는 고유 ID
    let identifier = record.identifier
    
    // 4. Payload
    // - 실제 데이터
    let payload = record.payload
    
    print("TNF: \(tnf)")
    print("Type: \(String(data: type, encoding: .utf8) ?? "binary")")
    print("ID: \(identifier.isEmpty ? "없음" : identifier.hexString)")
    print("Payload: \(payload.count) bytes")
    
    return RecordInfo(
        typeNameFormat: tnf,
        type: type,
        identifier: identifier,
        payload: payload
    )
}

extension Data {
    var hexString: String {
        map { String(format: "%02X", $0) }.joined()
    }
}
