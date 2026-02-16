import CloudKit

/// 메모 레코드 타입 정의
enum NoteRecord {
    // 레코드 타입명 (CloudKit Dashboard에서 확인)
    static let recordType = "Note"
    
    // 필드 키
    enum Field {
        static let id = "noteID"
        static let title = "title"
        static let content = "content"
        static let createdAt = "createdAt"
        static let modifiedAt = "modifiedAt"
    }
}
