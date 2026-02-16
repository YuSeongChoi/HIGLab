import CoreNFC

// NDEF 메시지 구조
// NFCNDEFMessage
//   └── records: [NFCNDEFPayload]
//         ├── record[0]
//         ├── record[1]
//         └── ...

func processMessage(_ message: NFCNDEFMessage) {
    // 레코드 배열에 접근
    let records = message.records
    
    print("이 메시지에는 \(records.count)개의 레코드가 있습니다.")
    
    // 첫 번째 레코드 확인
    if let firstRecord = records.first {
        print("첫 번째 레코드 타입: \(firstRecord.type)")
    }
}
