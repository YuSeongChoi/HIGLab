import SwiftData
import Foundation

@Model
class TaskItem {
    // @Attribute(.unique): 유니크 제약 조건
    // 중복 값 삽입 시 → 기존 데이터 업데이트 (Upsert)
    
    @Attribute(.unique)
    var id: UUID
    
    var title: String
    var isCompleted: Bool
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        isCompleted: Bool = false,
        createdAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
}

// ─────────────────────────────────────────

// Upsert 동작 예시
func upsertExample(context: ModelContext) {
    let id = UUID()
    
    // 첫 번째 삽입
    let task1 = TaskItem(id: id, title: "원래 제목")
    context.insert(task1)
    
    // 같은 ID로 다시 삽입 → 업데이트됨!
    let task2 = TaskItem(id: id, title: "변경된 제목")
    context.insert(task2)
    
    // 결과: 데이터베이스에는 "변경된 제목"인 항목 1개만 존재
}

// 💡 복합 유니크 키도 가능
// 예: 같은 카테고리 내에서 제목 중복 방지
@Model
class UniqueTaskItem {
    @Attribute(.unique)
    var compositeKey: String  // "categoryId_title" 형식으로 조합
    
    var title: String
    var categoryId: UUID
    
    init(title: String, categoryId: UUID) {
        self.title = title
        self.categoryId = categoryId
        self.compositeKey = "\(categoryId)_\(title)"
    }
}
