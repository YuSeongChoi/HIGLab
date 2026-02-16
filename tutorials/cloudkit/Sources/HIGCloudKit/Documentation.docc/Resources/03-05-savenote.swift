import CloudKit

extension CloudKitManager {
    
    /// 메모 저장
    func saveNote(_ note: Note) async throws -> Note {
        // Note를 CKRecord로 변환
        let record = note.toRecord(in: notesZoneID)
        
        // CloudKit에 저장
        let savedRecord = try await privateDatabase.save(record)
        
        // 저장된 레코드로 Note 업데이트
        var updatedNote = note
        updatedNote.recordID = savedRecord.recordID
        
        print("✅ Note saved: \(savedRecord.recordID.recordName)")
        return updatedNote
    }
}
