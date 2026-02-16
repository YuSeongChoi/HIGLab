import Foundation
import SwiftData

// MARK: - 할일 아이템 모델

/// SwiftData를 사용한 할일 데이터 모델
/// - 제목, 완료 상태, 마감일, 우선순위, 카테고리 등을 관리
@Model
final class TaskItem {
    // MARK: - 속성
    
    /// 할일 제목
    var title: String
    
    /// 완료 여부
    var isCompleted: Bool
    
    /// 마감일 (선택)
    var dueDate: Date?
    
    /// 우선순위 (0: 없음, 1: 낮음, 2: 중간, 3: 높음)
    var priority: Int
    
    /// 메모 / 상세 내용
    var notes: String
    
    /// 생성 일시
    var createdAt: Date
    
    /// 완료 일시
    var completedAt: Date?
    
    /// 소속 카테고리 (역관계)
    @Relationship(inverse: \Category.tasks)
    var category: Category?
    
    // MARK: - 초기화
    
    init(
        title: String,
        isCompleted: Bool = false,
        dueDate: Date? = nil,
        priority: Int = 0,
        notes: String = "",
        category: Category? = nil
    ) {
        self.title = title
        self.isCompleted = isCompleted
        self.dueDate = dueDate
        self.priority = priority
        self.notes = notes
        self.category = category
        self.createdAt = Date()
        self.completedAt = nil
    }
}

// MARK: - 우선순위 열거형

/// 할일 우선순위
enum TaskPriority: Int, CaseIterable, Identifiable {
    case none = 0
    case low = 1
    case medium = 2
    case high = 3
    
    var id: Int { rawValue }
    
    /// 표시 이름
    var name: String {
        switch self {
        case .none: "없음"
        case .low: "낮음"
        case .medium: "중간"
        case .high: "높음"
        }
    }
    
    /// SF Symbol 아이콘
    var symbol: String {
        switch self {
        case .none: "minus"
        case .low: "arrow.down"
        case .medium: "equal"
        case .high: "arrow.up"
        }
    }
    
    /// 색상
    var color: String {
        switch self {
        case .none: "gray"
        case .low: "blue"
        case .medium: "orange"
        case .high: "red"
        }
    }
}

// MARK: - 편의 확장

extension TaskItem {
    /// 우선순위 열거형 접근
    var taskPriority: TaskPriority {
        get { TaskPriority(rawValue: priority) ?? .none }
        set { priority = newValue.rawValue }
    }
    
    /// 마감일까지 남은 일수
    var daysUntilDue: Int? {
        guard let dueDate else { return nil }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let due = calendar.startOfDay(for: dueDate)
        return calendar.dateComponents([.day], from: today, to: due).day
    }
    
    /// 마감 임박 여부 (3일 이내)
    var isDueSoon: Bool {
        guard let days = daysUntilDue else { return false }
        return days >= 0 && days <= 3
    }
    
    /// 마감 지남 여부
    var isOverdue: Bool {
        guard let days = daysUntilDue else { return false }
        return days < 0 && !isCompleted
    }
    
    /// 완료 토글
    func toggleCompletion() {
        isCompleted.toggle()
        completedAt = isCompleted ? Date() : nil
    }
}

// MARK: - 정렬

extension TaskItem {
    /// 정렬 기준
    enum SortOption: String, CaseIterable {
        case createdAt = "생성일"
        case dueDate = "마감일"
        case priority = "우선순위"
        case title = "제목"
    }
}
