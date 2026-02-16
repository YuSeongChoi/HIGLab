import SwiftData

// @Model 매크로의 마법
// 컴파일 시점에 다음을 자동 생성:
// - PersistentModel 프로토콜 채택
// - Observable 프로토콜 채택
// - 프로퍼티 변경 추적 코드
// - 영속성 메타데이터

@Model
class TaskItem {
    // 기본 타입들은 자동으로 영속화됨
    var title: String
    var note: String?          // Optional도 OK
    var isCompleted: Bool
    var priority: Int
    var createdAt: Date
    var dueDate: Date?
    
    // Codable 타입도 지원
    var tags: [String]
    
    // 계산 프로퍼티는 저장되지 않음 (의도된 동작)
    var isOverdue: Bool {
        guard let dueDate else { return false }
        return !isCompleted && dueDate < .now
    }
    
    // 필수 init
    init(
        title: String,
        note: String? = nil,
        isCompleted: Bool = false,
        priority: Int = 0,
        createdAt: Date = .now,
        dueDate: Date? = nil,
        tags: [String] = []
    ) {
        self.title = title
        self.note = note
        self.isCompleted = isCompleted
        self.priority = priority
        self.createdAt = createdAt
        self.dueDate = dueDate
        self.tags = tags
    }
}
