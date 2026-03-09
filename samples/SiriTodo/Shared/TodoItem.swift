import Foundation
import AppIntents

// MARK: - 할일 모델
/// Siri 및 단축어에서 사용할 수 있는 할일 항목
/// AppEntity를 준수하여 Siri와 단축어에서 엔티티로 사용 가능
struct TodoItem: Identifiable, Codable, Hashable, Sendable {
    
    // MARK: - 속성
    
    let id: UUID                    // 고유 식별자
    var title: String               // 할일 제목
    var notes: String?              // 상세 메모
    var isCompleted: Bool           // 완료 여부
    var priority: Priority          // 우선순위
    var dueDate: Date?              // 마감일
    var tagIds: [UUID]              // 연결된 태그 ID 목록
    var reminderDate: Date?         // 알림 시간
    var createdAt: Date             // 생성 시간
    var completedAt: Date?          // 완료 시간
    var updatedAt: Date             // 마지막 수정 시간
    
    // MARK: - 초기화
    
    init(
        id: UUID = UUID(),
        title: String,
        notes: String? = nil,
        isCompleted: Bool = false,
        priority: Priority = .normal,
        dueDate: Date? = nil,
        tagIds: [UUID] = [],
        reminderDate: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.isCompleted = isCompleted
        self.priority = priority
        self.dueDate = dueDate
        self.tagIds = tagIds
        self.reminderDate = reminderDate
        self.createdAt = Date()
        self.completedAt = nil
        self.updatedAt = Date()
    }
    
    // MARK: - 계산 속성
    
    /// 마감일 정보
    var dueDateInfo: DueDate? {
        dueDate.map { DueDate($0) }
    }
    
    /// 기한이 지났는지 확인
    var isOverdue: Bool {
        guard let dueDate else { return false }
        return !isCompleted && dueDate < Date()
    }
    
    /// 오늘 마감인지 확인
    var isDueToday: Bool {
        guard let dueDate else { return false }
        return Calendar.current.isDateInToday(dueDate)
    }
    
    /// 정렬 우선순위 (높을수록 먼저)
    var sortPriority: Int {
        var score = priority.sortWeight * 100
        
        // 기한 지난 항목 최상위
        if isOverdue {
            score += 1000
        }
        
        // 오늘 마감 항목 높은 우선순위
        if isDueToday {
            score += 500
        }
        
        return score
    }
    
    // MARK: - 요약 문자열
    
    /// 간단한 요약 (Siri 응답용)
    var summary: String {
        var parts: [String] = [title]
        
        if let dueDateInfo {
            parts.append("(\(dueDateInfo.relativeString))")
        }
        
        if priority != .normal {
            parts.append(priority.emoji)
        }
        
        return parts.joined(separator: " ")
    }
    
    /// 상세 요약 (여러 줄)
    var detailedSummary: String {
        var lines: [String] = []
        
        lines.append("📝 \(title)")
        
        if let notes, !notes.isEmpty {
            lines.append("   메모: \(notes)")
        }
        
        lines.append("   우선순위: \(priority.displayName) \(priority.emoji)")
        
        if let dueDateInfo {
            lines.append("   마감: \(dueDateInfo.dateString) \(dueDateInfo.statusEmoji)")
        }
        
        let status = isCompleted ? "완료됨 ✅" : "진행 중 ⏳"
        lines.append("   상태: \(status)")
        
        return lines.joined(separator: "\n")
    }
}

// MARK: - AppEntity 준수
/// AppIntents에서 할일 항목을 엔티티로 사용하기 위한 확장
extension TodoItem: AppEntity {
    
    // MARK: - 타입 표시 정보
    
    /// 엔티티 타입 표시 이름
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "할일")
    }
    
    // MARK: - 개별 항목 표시
    
    /// 개별 항목 표시 정보
    var displayRepresentation: DisplayRepresentation {
        // 부제목 구성
        var subtitleParts: [String] = []
        
        if isCompleted {
            subtitleParts.append("✅ 완료됨")
        } else if isOverdue {
            subtitleParts.append("⚠️ 기한 지남")
        } else if isDueToday {
            subtitleParts.append("📅 오늘 마감")
        } else {
            subtitleParts.append("⏳ 진행 중")
        }
        
        if priority != .normal {
            subtitleParts.append(priority.displayName)
        }
        
        let subtitle = subtitleParts.joined(separator: " · ")
        
        // 아이콘 결정
        let imageName = isCompleted ? "checkmark.circle.fill" : priority.systemImageName
        
        return DisplayRepresentation(
            title: "\(title)",
            subtitle: "\(subtitle)",
            image: .init(systemName: imageName)
        )
    }
    
    // MARK: - 기본 쿼리
    
    /// 기본 쿼리 제공
    static var defaultQuery: TodoItemQuery {
        TodoItemQuery()
    }
}

// MARK: - 엔티티 쿼리
/// Siri가 할일 항목을 검색할 때 사용하는 쿼리
struct TodoItemQuery: EntityQuery {
    
    // MARK: - ID로 조회
    
    /// ID로 할일 조회
    func entities(for identifiers: [UUID]) async throws -> [TodoItem] {
        let store = await TodoStore.shared
        return await store.todos.filter { identifiers.contains($0.id) }
    }
    
    // MARK: - 추천 항목
    
    /// 모든 할일 조회 (추천 항목)
    func suggestedEntities() async throws -> [TodoItem] {
        // 미완료 항목 우선, 우선순위/마감일 순으로 정렬
        let store = await TodoStore.shared
        return await store.todos
            .filter { !$0.isCompleted }
            .sorted { $0.sortPriority > $1.sortPriority }
    }
}

// MARK: - 문자열 검색 지원
extension TodoItemQuery: EntityStringQuery {
    
    /// 문자열로 할일 검색
    func entities(matching string: String) async throws -> [TodoItem] {
        let store = await TodoStore.shared
        
        // 빈 문자열이면 전체 반환
        guard !string.isEmpty else {
            return await store.todos
        }
        
        // 제목 또는 메모에 검색어가 포함된 항목 필터링
        return await store.todos.filter { todo in
            todo.title.localizedCaseInsensitiveContains(string) ||
            (todo.notes?.localizedCaseInsensitiveContains(string) ?? false)
        }
    }
}

// MARK: - 엔티티 속성 쿼리 (고급 필터링)
extension TodoItemQuery: EntityPropertyQuery {
    
    // MARK: - 쿼리 속성 정의
    
    /// 쿼리에서 사용할 수 있는 속성들
    static var properties: QueryProperties {
        Property(\TodoItem.title) {
            EqualToComparator()
            ContainsComparator()
        }
        Property(\TodoItem.isCompleted) {
            EqualToComparator()
        }
        Property(\TodoItem.priority) {
            EqualToComparator()
        }
    }
    
    /// 정렬 옵션
    static var sortingOptions: SortingOptions {
        SortingOptions {
            SortableBy(\TodoItem.title)
            SortableBy(\TodoItem.createdAt)
            SortableBy(\TodoItem.priority)
        }
    }
    
    /// 속성 기반 쿼리 실행
    func entities(
        matching comparators: [ComparatorMapping<TodoItem>],
        mode: ComparatorMode,
        sortedBy: [Sort<TodoItem>],
        limit: Int?
    ) async throws -> [TodoItem] {
        let store = await TodoStore.shared
        var results = await store.todos
        
        // 필터링
        results = results.filter { todo in
            comparators.allSatisfy { mapping in
                mapping.comparator.matches(todo, for: mapping.keyPath)
            }
        }
        
        // 정렬
        for sort in sortedBy.reversed() {
            results.sort { lhs, rhs in
                let ascending = sort.order == .ascending
                
                switch sort.by {
                case \TodoItem.title:
                    return ascending ? lhs.title < rhs.title : lhs.title > rhs.title
                case \TodoItem.createdAt:
                    return ascending ? lhs.createdAt < rhs.createdAt : lhs.createdAt > rhs.createdAt
                case \TodoItem.priority:
                    return ascending ? lhs.priority < rhs.priority : lhs.priority > rhs.priority
                default:
                    return false
                }
            }
        }
        
        // 제한
        if let limit {
            results = Array(results.prefix(limit))
        }
        
        return results
    }
}

// MARK: - TransientEntity (단축어 전용)
/// 실행 결과로 반환되는 임시 엔티티
struct TodoResultEntity: TransientAppEntity {
    
    var id: UUID
    var title: String
    var message: String
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "할일 결과"
    }
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(title)",
            subtitle: "\(message)"
        )
    }
}
