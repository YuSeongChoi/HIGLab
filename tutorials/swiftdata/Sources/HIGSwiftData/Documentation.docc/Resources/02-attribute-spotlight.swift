import SwiftData
import Foundation

@Model
class TaskItem {
    // @Attribute(.spotlight): Spotlight 검색 인덱싱
    // 사용자가 시스템 검색에서 앱 데이터를 찾을 수 있음
    
    @Attribute(.spotlight)
    var title: String
    
    @Attribute(.spotlight)
    var note: String
    
    var isCompleted: Bool
    var createdAt: Date
    var priority: Priority
    
    init(
        title: String,
        note: String = "",
        isCompleted: Bool = false,
        priority: Priority = .medium,
        createdAt: Date = .now
    ) {
        self.title = title
        self.note = note
        self.isCompleted = isCompleted
        self.priority = priority
        self.createdAt = createdAt
    }
}

// ─────────────────────────────────────────

// Spotlight 검색 결과:
// 사용자가 iPhone에서 아래로 스와이프 → "장보기" 검색
// → TaskMaster 앱의 "장보기 목록 작성" 할 일이 검색 결과에 표시

// 💡 Spotlight 인덱싱 팁:
// - 사용자가 검색할 만한 필드에만 적용
// - 너무 많은 필드 인덱싱 → 성능 저하
// - 민감한 정보는 인덱싱하지 않기 (비밀번호, 개인정보 등)

// ─────────────────────────────────────────

// 여러 Attribute를 조합할 수도 있음
@Model
class RichTaskItem {
    @Attribute(.unique, .spotlight)
    var id: UUID
    
    @Attribute(.spotlight)
    var title: String
    
    @Attribute(.externalStorage)
    var imageData: Data?
    
    init(id: UUID = UUID(), title: String, imageData: Data? = nil) {
        self.id = id
        self.title = title
        self.imageData = imageData
    }
}
