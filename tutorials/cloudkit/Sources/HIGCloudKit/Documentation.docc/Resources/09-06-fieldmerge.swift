import CloudKit
import Foundation

extension ConflictResolver {
    
    /// 필드별 병합 전략 (최신 수정 우선)
    func resolveWithFieldMerge(conflict: ConflictInfo) -> CKRecord {
        let resolved = conflict.serverRecord
        
        // 각 필드별로 최신 값 선택
        let serverModified = conflict.serverRecord.modificationDate ?? Date.distantPast
        let clientModified = conflict.clientRecord.modificationDate ?? Date.distantPast
        
        // 특정 필드는 클라이언트 우선 (예: 사용자가 마지막으로 편집한 필드)
        if clientModified > serverModified {
            // title, content는 클라이언트 값 사용
            resolved[NoteRecord.Field.title] = conflict.clientRecord[NoteRecord.Field.title]
            resolved[NoteRecord.Field.content] = conflict.clientRecord[NoteRecord.Field.content]
            resolved[NoteRecord.Field.modifiedAt] = clientModified
        }
        
        return resolved
    }
    
    /// 스마트 병합 (텍스트 필드 합치기)
    func resolveWithSmartMerge(conflict: ConflictInfo) -> CKRecord {
        let resolved = conflict.serverRecord
        
        // 제목: 클라이언트 우선
        resolved[NoteRecord.Field.title] = conflict.clientRecord[NoteRecord.Field.title]
        
        // 내용: 양쪽 변경사항 모두 포함
        let serverContent = conflict.serverRecord[NoteRecord.Field.content] as? String ?? ""
        let clientContent = conflict.clientRecord[NoteRecord.Field.content] as? String ?? ""
        
        if serverContent != clientContent {
            resolved[NoteRecord.Field.content] = """
            === 서버 버전 ===
            \(serverContent)
            
            === 내 변경사항 ===
            \(clientContent)
            """
        }
        
        return resolved
    }
}
