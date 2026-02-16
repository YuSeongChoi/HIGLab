import SwiftData
import Foundation

@Model
class TaskItem {
    // ═══════════════════════════════════════════
    // 📦 지원되는 프로퍼티 타입
    // ═══════════════════════════════════════════
    
    // 기본 타입
    var title: String
    var count: Int
    var progress: Double
    var isCompleted: Bool
    
    // 날짜/시간
    var createdAt: Date
    var dueDate: Date?          // Optional도 OK
    
    // 식별자
    var id: UUID
    
    // 바이너리 데이터
    var thumbnail: Data?
    
    // URL
    var attachmentURL: URL?
    
    // 컬렉션 (Codable 요소)
    var tags: [String]          // 배열
    var metadata: [String: String]  // 딕셔너리
    
    // Codable enum (다음 스텝에서 상세 설명)
    // var priority: Priority
    
    init(title: String) {
        self.title = title
        self.count = 0
        self.progress = 0.0
        self.isCompleted = false
        self.createdAt = .now
        self.dueDate = nil
        self.id = UUID()
        self.thumbnail = nil
        self.attachmentURL = nil
        self.tags = []
        self.metadata = [:]
    }
}

// ⚠️ 지원되지 않는 타입
// - 클로저: var handler: () -> Void  ❌
// - 타입: var type: Any.Type  ❌
// - 제네릭 타입 (직접): var item: T  ❌
