import SwiftData
import Foundation

// ═══════════════════════════════════════════════════════════════════
// TaskMaster의 핵심 모델: TaskItem
// 모든 챕터에서 사용하는 최종 버전
// ═══════════════════════════════════════════════════════════════════

/// 할 일의 우선순위
enum Priority: Int, Codable, CaseIterable, Identifiable {
    case low = 0
    case medium = 1
    case high = 2
    case urgent = 3
    
    var id: Int { rawValue }
    
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
}

// ─────────────────────────────────────────

/// 할 일 항목
@Model
class TaskItem {
    // 유니크 식별자
    @Attribute(.unique)
    var id: UUID
    
    // Spotlight 검색 가능
    @Attribute(.spotlight)
    var title: String
    
    // 상세 메모
    var note: String
    
    // 완료 상태
    var isCompleted: Bool
    
    // 우선순위
    var priority: Priority
    
    // 타임스탬프
    var createdAt: Date
    var completedAt: Date?
    var dueDate: Date?
    
    // 태그 (배열)
    var tags: [String]
    
    // 첨부 이미지 (외부 저장)
    @Attribute(.externalStorage)
    var imageData: Data?
    
    // 임시 상태 (저장 안 함)
    @Transient
    var isEditing: Bool = false
    
    // MARK: - 계산 프로퍼티
    
    /// 기한 초과 여부
    var isOverdue: Bool {
        guard let dueDate, !isCompleted else { return false }
        return dueDate < Date.now
    }
    
    /// 오늘 마감 여부
    var isDueToday: Bool {
        guard let dueDate else { return false }
        return Calendar.current.isDateInToday(dueDate)
    }
    
    // MARK: - Init
    
    init(
        id: UUID = UUID(),
        title: String,
        note: String = "",
        isCompleted: Bool = false,
        priority: Priority = .medium,
        createdAt: Date = .now,
        dueDate: Date? = nil,
        tags: [String] = [],
        imageData: Data? = nil
    ) {
        self.id = id
        self.title = title
        self.note = note
        self.isCompleted = isCompleted
        self.priority = priority
        self.createdAt = createdAt
        self.dueDate = dueDate
        self.tags = tags
        self.imageData = imageData
    }
    
    // MARK: - Methods
    
    /// 완료 토글
    func toggleCompletion() {
        isCompleted.toggle()
        completedAt = isCompleted ? .now : nil
    }
}

// ─────────────────────────────────────────

// 💡 Preview용 샘플 데이터
extension TaskItem {
    static var preview: TaskItem {
        TaskItem(
            title: "SwiftData 튜토리얼 완료하기",
            note: "Chapter 1부터 10까지 전부!",
            priority: .high,
            dueDate: Calendar.current.date(byAdding: .day, value: 3, to: .now),
            tags: ["학습", "iOS"]
        )
    }
    
    static var samples: [TaskItem] {
        [
            TaskItem(title: "아침 운동하기", priority: .medium, tags: ["건강"]),
            TaskItem(title: "장보기", note: "우유, 계란, 빵", priority: .low),
            TaskItem(title: "프로젝트 리뷰", priority: .urgent, dueDate: .now),
            TaskItem(title: "책 읽기", isCompleted: true, priority: .low)
        ]
    }
}
