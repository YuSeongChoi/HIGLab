import Foundation
import SwiftUI

// MARK: - 할일 저장소
/// 할일 목록을 관리하는 싱글톤 저장소
/// UserDefaults를 사용해 데이터를 영구 저장합니다.
/// App Group을 통해 위젯과 인텐트에서 동일한 데이터에 접근 가능
@MainActor
final class TodoStore: ObservableObject {
    
    // MARK: - 싱글톤
    
    /// 공유 인스턴스
    static let shared = TodoStore()
    
    // MARK: - 속성
    
    /// 할일 목록 (변경 시 자동 저장)
    @Published var todos: [TodoItem] = [] {
        didSet {
            save()
            notifyUpdate()
        }
    }
    
    // MARK: - 저장소 설정
    
    private let storageKey = "SiriTodo.todos"
    
    /// 앱 그룹 UserDefaults (위젯/인텐트 공유용)
    /// 실제 배포 시 앱 그룹 ID로 변경 필요
    private let userDefaults: UserDefaults
    
    /// 앱 그룹 식별자
    /// 실제 사용 시 "group.com.yourcompany.SiriTodo" 형태로 설정
    static let appGroupIdentifier = "group.com.example.SiriTodo"
    
    // MARK: - 초기화
    
    private init() {
        // 앱 그룹 UserDefaults 시도, 실패 시 표준 사용
        if let groupDefaults = UserDefaults(suiteName: Self.appGroupIdentifier) {
            self.userDefaults = groupDefaults
        } else {
            self.userDefaults = .standard
        }
        
        load()
    }
    
    // MARK: - CRUD 작업
    
    /// 새 할일 추가
    /// - Parameters:
    ///   - title: 할일 제목
    ///   - notes: 상세 메모 (선택)
    ///   - priority: 우선순위
    ///   - dueDate: 마감일 (선택)
    ///   - tagIds: 태그 ID 목록
    /// - Returns: 생성된 할일 항목
    @discardableResult
    func add(
        title: String,
        notes: String? = nil,
        priority: Priority = .normal,
        dueDate: Date? = nil,
        tagIds: [UUID] = []
    ) -> TodoItem {
        let item = TodoItem(
            title: title,
            notes: notes,
            priority: priority,
            dueDate: dueDate,
            tagIds: tagIds
        )
        todos.append(item)
        return item
    }
    
    /// 할일 업데이트
    /// - Parameters:
    ///   - id: 업데이트할 할일 ID
    ///   - update: 업데이트 클로저
    /// - Returns: 업데이트된 할일 (없으면 nil)
    @discardableResult
    func update(id: UUID, _ update: (inout TodoItem) -> Void) -> TodoItem? {
        guard let index = todos.firstIndex(where: { $0.id == id }) else {
            return nil
        }
        
        var item = todos[index]
        update(&item)
        item.updatedAt = Date()
        todos[index] = item
        
        return item
    }
    
    /// 할일 완료 처리
    /// - Parameter item: 완료할 할일
    func complete(_ item: TodoItem) {
        guard let index = todos.firstIndex(where: { $0.id == item.id }) else {
            return
        }
        todos[index].isCompleted = true
        todos[index].completedAt = Date()
        todos[index].updatedAt = Date()
    }
    
    /// ID로 할일 완료 처리
    /// - Parameter id: 할일 ID
    /// - Returns: 완료된 할일 (없으면 nil)
    @discardableResult
    func complete(id: UUID) -> TodoItem? {
        guard let index = todos.firstIndex(where: { $0.id == id }) else {
            return nil
        }
        todos[index].isCompleted = true
        todos[index].completedAt = Date()
        todos[index].updatedAt = Date()
        return todos[index]
    }
    
    /// 할일 미완료로 되돌리기
    /// - Parameter id: 할일 ID
    /// - Returns: 되돌려진 할일 (없으면 nil)
    @discardableResult
    func uncomplete(id: UUID) -> TodoItem? {
        guard let index = todos.firstIndex(where: { $0.id == id }) else {
            return nil
        }
        todos[index].isCompleted = false
        todos[index].completedAt = nil
        todos[index].updatedAt = Date()
        return todos[index]
    }
    
    /// 우선순위 변경
    /// - Parameters:
    ///   - id: 할일 ID
    ///   - priority: 새 우선순위
    /// - Returns: 변경된 할일 (없으면 nil)
    @discardableResult
    func setPriority(id: UUID, priority: Priority) -> TodoItem? {
        guard let index = todos.firstIndex(where: { $0.id == id }) else {
            return nil
        }
        todos[index].priority = priority
        todos[index].updatedAt = Date()
        return todos[index]
    }
    
    /// 마감일 변경
    /// - Parameters:
    ///   - id: 할일 ID
    ///   - dueDate: 새 마감일 (nil이면 제거)
    /// - Returns: 변경된 할일 (없으면 nil)
    @discardableResult
    func setDueDate(id: UUID, dueDate: Date?) -> TodoItem? {
        guard let index = todos.firstIndex(where: { $0.id == id }) else {
            return nil
        }
        todos[index].dueDate = dueDate
        todos[index].updatedAt = Date()
        return todos[index]
    }
    
    /// 태그 추가
    /// - Parameters:
    ///   - id: 할일 ID
    ///   - tagId: 추가할 태그 ID
    /// - Returns: 변경된 할일 (없으면 nil)
    @discardableResult
    func addTag(id: UUID, tagId: UUID) -> TodoItem? {
        guard let index = todos.firstIndex(where: { $0.id == id }) else {
            return nil
        }
        if !todos[index].tagIds.contains(tagId) {
            todos[index].tagIds.append(tagId)
            todos[index].updatedAt = Date()
        }
        return todos[index]
    }
    
    /// 태그 제거
    /// - Parameters:
    ///   - id: 할일 ID
    ///   - tagId: 제거할 태그 ID
    /// - Returns: 변경된 할일 (없으면 nil)
    @discardableResult
    func removeTag(id: UUID, tagId: UUID) -> TodoItem? {
        guard let index = todos.firstIndex(where: { $0.id == id }) else {
            return nil
        }
        todos[index].tagIds.removeAll { $0 == tagId }
        todos[index].updatedAt = Date()
        return todos[index]
    }
    
    /// 할일 삭제
    /// - Parameter item: 삭제할 할일
    func delete(_ item: TodoItem) {
        todos.removeAll { $0.id == item.id }
    }
    
    /// ID로 할일 삭제
    /// - Parameter id: 삭제할 할일 ID
    /// - Returns: 삭제 성공 여부
    @discardableResult
    func delete(id: UUID) -> Bool {
        let countBefore = todos.count
        todos.removeAll { $0.id == id }
        return todos.count < countBefore
    }
    
    /// 여러 할일 삭제
    /// - Parameter ids: 삭제할 할일 ID 목록
    /// - Returns: 삭제된 개수
    @discardableResult
    func delete(ids: [UUID]) -> Int {
        let countBefore = todos.count
        todos.removeAll { ids.contains($0.id) }
        return countBefore - todos.count
    }
    
    /// 완료된 모든 할일 삭제
    /// - Returns: 삭제된 개수
    @discardableResult
    func deleteAllCompleted() -> Int {
        let countBefore = todos.count
        todos.removeAll { $0.isCompleted }
        return countBefore - todos.count
    }
    
    // MARK: - 조회
    
    /// ID로 할일 찾기
    func find(id: UUID) -> TodoItem? {
        todos.first { $0.id == id }
    }
    
    /// 제목으로 할일 찾기
    func find(byTitle title: String) -> TodoItem? {
        todos.first { $0.title.lowercased() == title.lowercased() }
    }
    
    /// 제목 검색 (부분 일치)
    func search(query: String) -> [TodoItem] {
        guard !query.isEmpty else { return todos }
        
        let lowercasedQuery = query.lowercased()
        return todos.filter { todo in
            todo.title.lowercased().contains(lowercasedQuery) ||
            (todo.notes?.lowercased().contains(lowercasedQuery) ?? false)
        }
    }
    
    // MARK: - 필터링된 목록
    
    /// 완료된 할일만 필터링
    var completedTodos: [TodoItem] {
        todos.filter { $0.isCompleted }
    }
    
    /// 미완료 할일만 필터링
    var incompleteTodos: [TodoItem] {
        todos.filter { !$0.isCompleted }
    }
    
    /// 기한이 지난 할일
    var overdueTodos: [TodoItem] {
        todos.filter { $0.isOverdue }
    }
    
    /// 오늘 마감인 할일
    var todayTodos: [TodoItem] {
        todos.filter { $0.isDueToday }
    }
    
    /// 특정 우선순위 할일
    func todos(with priority: Priority) -> [TodoItem] {
        todos.filter { $0.priority == priority }
    }
    
    /// 특정 태그가 있는 할일
    func todos(withTag tagId: UUID) -> [TodoItem] {
        todos.filter { $0.tagIds.contains(tagId) }
    }
    
    /// 우선순위순으로 정렬된 미완료 할일
    var sortedIncompleteTodos: [TodoItem] {
        incompleteTodos.sorted { $0.sortPriority > $1.sortPriority }
    }
    
    // MARK: - 통계
    
    /// 할일 통계
    var statistics: TodoStatistics {
        TodoStatistics(
            total: todos.count,
            completed: completedTodos.count,
            incomplete: incompleteTodos.count,
            overdue: overdueTodos.count,
            dueToday: todayTodos.count,
            highPriority: todos(with: .high).count + todos(with: .urgent).count
        )
    }
    
    // MARK: - 영구 저장
    
    /// 데이터 저장
    private func save() {
        guard let data = try? JSONEncoder().encode(todos) else {
            return
        }
        userDefaults.set(data, forKey: storageKey)
    }
    
    /// 데이터 불러오기
    private func load() {
        guard let data = userDefaults.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([TodoItem].self, from: data) else {
            // 샘플 데이터로 초기화
            todos = Self.sampleTodos
            return
        }
        todos = decoded
    }
    
    /// 위젯 업데이트 알림
    private func notifyUpdate() {
        // WidgetKit 리로드 요청 (위젯 타겟에서만 동작)
        #if canImport(WidgetKit)
        import WidgetKit
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }
    
    // MARK: - 디버그/개발용
    
    /// 모든 데이터 초기화
    func reset() {
        todos = []
    }
    
    /// 샘플 데이터로 리셋
    func resetToSample() {
        todos = Self.sampleTodos
    }
    
    /// 샘플 데이터
    private static let sampleTodos: [TodoItem] = [
        TodoItem(
            title: "Siri로 할일 추가해보기",
            priority: .high,
            dueDate: DueDate.today.date
        ),
        TodoItem(
            title: "단축어 앱에서 확인하기",
            priority: .normal
        ),
        TodoItem(
            title: "AppIntents 문서 읽기",
            notes: "WWDC 2022 세션도 함께 시청",
            priority: .normal,
            dueDate: DueDate.tomorrow.date
        ),
        TodoItem(
            title: "위젯 연동 테스트",
            priority: .low,
            dueDate: DueDate.nextWeek.date
        )
    ]
}

// MARK: - 통계 구조체
/// 할일 통계 정보
struct TodoStatistics {
    let total: Int          // 전체 할일 수
    let completed: Int      // 완료된 할일 수
    let incomplete: Int     // 미완료 할일 수
    let overdue: Int        // 기한 지난 할일 수
    let dueToday: Int       // 오늘 마감 할일 수
    let highPriority: Int   // 높은 우선순위 할일 수
    
    /// 완료율 (0.0 ~ 1.0)
    var completionRate: Double {
        guard total > 0 else { return 0 }
        return Double(completed) / Double(total)
    }
    
    /// 완료율 퍼센트 문자열
    var completionRateString: String {
        String(format: "%.0f%%", completionRate * 100)
    }
    
    /// 요약 문자열
    var summary: String {
        if total == 0 {
            return "할일이 없습니다"
        }
        
        var parts: [String] = []
        parts.append("전체 \(total)개")
        parts.append("완료 \(completed)개")
        
        if overdue > 0 {
            parts.append("⚠️ 기한 지남 \(overdue)개")
        }
        
        if dueToday > 0 {
            parts.append("📅 오늘 마감 \(dueToday)개")
        }
        
        return parts.joined(separator: ", ")
    }
}

// MARK: - Sendable 준수 (인텐트에서 사용)
extension TodoStore: @unchecked Sendable {}
