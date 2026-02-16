import SwiftData
import Foundation

// 우선순위 enum
// Codable을 채택하면 SwiftData가 자동으로 저장
enum Priority: Int, Codable, CaseIterable {
    case low = 0
    case medium = 1
    case high = 2
    case urgent = 3
    
    var title: String {
        switch self {
        case .low: return "낮음"
        case .medium: return "보통"
        case .high: return "높음"
        case .urgent: return "긴급"
        }
    }
    
    var emoji: String {
        switch self {
        case .low: return "🟢"
        case .medium: return "🟡"
        case .high: return "🟠"
        case .urgent: return "🔴"
        }
    }
    
    var color: String {
        switch self {
        case .low: return "green"
        case .medium: return "yellow"
        case .high: return "orange"
        case .urgent: return "red"
        }
    }
}

// ─────────────────────────────────────────

@Model
class TaskItem {
    var title: String
    var note: String
    var isCompleted: Bool
    var createdAt: Date
    var dueDate: Date?
    
    // 🆕 Priority enum 추가
    var priority: Priority
    
    init(
        title: String,
        note: String = "",
        isCompleted: Bool = false,
        priority: Priority = .medium,  // 기본값: 보통
        createdAt: Date = .now,
        dueDate: Date? = nil
    ) {
        self.title = title
        self.note = note
        self.isCompleted = isCompleted
        self.priority = priority
        self.createdAt = createdAt
        self.dueDate = dueDate
    }
}

// 💡 String enum도 가능
enum TaskStatus: String, Codable {
    case todo = "todo"
    case inProgress = "in_progress"
    case done = "done"
}
