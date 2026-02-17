import Foundation
import AppIntents

// MARK: - 할일 모델
/// Siri 및 단축어에서 사용할 수 있는 할일 항목
struct TodoItem: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String           // 할일 제목
    var isCompleted: Bool       // 완료 여부
    var createdAt: Date         // 생성 시간
    var completedAt: Date?      // 완료 시간
    
    init(id: UUID = UUID(), title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = Date()
        self.completedAt = nil
    }
}

// MARK: - AppEntity 준수
/// AppIntents에서 할일 항목을 엔티티로 사용하기 위한 확장
extension TodoItem: AppEntity {
    
    // 엔티티 타입 표시 이름
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "할일")
    }
    
    // 개별 항목 표시 정보
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(title)",
            subtitle: isCompleted ? "완료됨" : "진행 중"
        )
    }
    
    // 기본 쿼리 제공
    static var defaultQuery: TodoItemQuery {
        TodoItemQuery()
    }
}

// MARK: - 엔티티 쿼리
/// Siri가 할일 항목을 검색할 때 사용하는 쿼리
struct TodoItemQuery: EntityQuery {
    
    // ID로 할일 조회
    func entities(for identifiers: [UUID]) async throws -> [TodoItem] {
        let store = TodoStore.shared
        return store.todos.filter { identifiers.contains($0.id) }
    }
    
    // 모든 할일 조회 (추천 항목)
    func suggestedEntities() async throws -> [TodoItem] {
        TodoStore.shared.todos
    }
}

// MARK: - 문자열 검색 지원
extension TodoItemQuery: EntityStringQuery {
    
    // 문자열로 할일 검색
    func entities(matching string: String) async throws -> [TodoItem] {
        let store = TodoStore.shared
        
        // 빈 문자열이면 전체 반환
        guard !string.isEmpty else {
            return store.todos
        }
        
        // 제목에 검색어가 포함된 항목 필터링
        return store.todos.filter { todo in
            todo.title.localizedCaseInsensitiveContains(string)
        }
    }
}
