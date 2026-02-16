import CloudKit
import Foundation

extension Note {
    
    /// CKRecord에서 Note 생성
    init?(from record: CKRecord) {
        guard record.recordType == NoteRecord.recordType else {
            return nil
        }
        
        self.id = record[NoteRecord.Field.id] as? String ?? record.recordID.recordName
        self.title = record[NoteRecord.Field.title] as? String ?? ""
        self.content = record[NoteRecord.Field.content] as? String ?? ""
        self.createdAt = record[NoteRecord.Field.createdAt] as? Date ?? record.creationDate ?? Date()
        self.modifiedAt = record[NoteRecord.Field.modifiedAt] as? Date ?? record.modificationDate ?? Date()
        self.isShared = false
        self.recordID = record.recordID
    }
}
