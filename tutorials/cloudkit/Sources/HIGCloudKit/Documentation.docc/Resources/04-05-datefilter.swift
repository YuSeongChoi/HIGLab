import CloudKit
import Foundation

extension CloudKitManager {
    
    /// 날짜 범위로 메모 필터링
    func fetchNotes(from startDate: Date, to endDate: Date) async throws -> [Note] {
        let predicate = NSPredicate(
            format: "%K >= %@ AND %K <= %@",
            NoteRecord.Field.modifiedAt, startDate as NSDate,
            NoteRecord.Field.modifiedAt, endDate as NSDate
        )
        
        let query = CKQuery(
            recordType: NoteRecord.recordType,
            predicate: predicate
        )
        
        let (records, _) = try await privateDatabase.records(
            matching: query,
            inZoneWith: notesZoneID
        )
        
        return records.compactMap { _, result in
            guard let record = try? result.get() else { return nil }
            return Note(from: record)
        }
    }
    
    /// 오늘 수정된 메모만 조회
    func fetchTodayNotes() async throws -> [Note] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return try await fetchNotes(from: startOfDay, to: endOfDay)
    }
}
