import CoreNFC

func processMessage(_ message: NFCNDEFMessage) {
    let records = message.records
    
    // 모든 레코드 순회
    for (index, record) in records.enumerated() {
        print("--- 레코드 #\(index) ---")
        print("Type Name Format: \(record.typeNameFormat.rawValue)")
        print("Type: \(String(data: record.type, encoding: .utf8) ?? "N/A")")
        print("Payload 크기: \(record.payload.count) bytes")
        
        // 페이로드 미리보기 (첫 20바이트)
        let preview = record.payload.prefix(20)
        print("Payload 미리보기: \(preview.map { String(format: "%02X", $0) }.joined(separator: " "))")
    }
}
