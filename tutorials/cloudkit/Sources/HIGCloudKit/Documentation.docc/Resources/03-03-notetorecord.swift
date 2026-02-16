import CloudKit
import Foundation

struct Note: Identifiable {
    let id: String
    var title: String
    var content: String
    var createdAt: Date
    var modifiedAt: Date
    var recordID: CKRecord.ID?
    
    /// Note를 CKRecord로 변환
    func toRecord(in zoneID: CKRecordZone.ID) -> CKRecord {
        // 기존 recordID가 있으면 사용, 없으면 새로 생성
        let recordID = self.recordID ?? CKRecord.ID(
            recordName: self.id,
            zoneID: zoneID
        )
        
        let record = CKRecord(
            recordType: NoteRecord.recordType,
            recordID: recordID
        )
        
        // 필드 설정
        record[NoteRecord.Field.id] = self.id
        record[NoteRecord.Field.title] = self.title
        record[NoteRecord.Field.content] = self.content
        record[NoteRecord.Field.createdAt] = self.createdAt
        record[NoteRecord.Field.modifiedAt] = self.modifiedAt
        
        return record
    }
}
