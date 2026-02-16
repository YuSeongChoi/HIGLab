import CloudKit

extension CloudKitManager {
    
    /// Query 기반 구독 생성
    func createQuerySubscription() -> CKQuerySubscription {
        // 모든 Note 레코드 변경 감지
        let predicate = NSPredicate(value: true)
        
        let subscription = CKQuerySubscription(
            recordType: NoteRecord.recordType,
            predicate: predicate,
            subscriptionID: "note-changes",
            options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion]
        )
        
        return subscription
    }
}
