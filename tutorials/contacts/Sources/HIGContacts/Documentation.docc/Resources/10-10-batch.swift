import Contacts

class SyncManager {
    let store = CNContactStore()
    
    // 여러 연락처를 한 번에 저장 (배치 처리)
    func batchSave(contacts: [CNMutableContact]) throws {
        let saveRequest = CNSaveRequest()
        
        for contact in contacts {
            if contact.identifier.isEmpty {
                // 새 연락처
                saveRequest.add(contact, toContainerWithIdentifier: nil)
            } else {
                // 기존 연락처 업데이트
                saveRequest.update(contact)
            }
        }
        
        try store.execute(saveRequest)
    }
    
    // 청크 단위로 처리 (대량 데이터)
    func batchSaveInChunks(
        contacts: [CNMutableContact],
        chunkSize: Int = 100
    ) throws {
        let chunks = contacts.chunked(into: chunkSize)
        
        for (index, chunk) in chunks.enumerated() {
            try batchSave(contacts: chunk)
            print("청크 \(index + 1)/\(chunks.count) 저장 완료")
        }
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
