import Foundation
import SwiftUI

// MARK: - 할일 저장소
/// 할일 목록을 관리하는 싱글톤 저장소
/// UserDefaults를 사용해 데이터를 영구 저장합니다.
@MainActor
final class TodoStore: ObservableObject {
    
    // MARK: - 싱글톤
    static let shared = TodoStore()
    
    // MARK: - 속성
    /// 할일 목록 (변경 시 자동 저장)
    @Published var todos: [TodoItem] = [] {
        didSet {
            save()
        }
    }
    
    // MARK: - 저장소 키
    private let storageKey = "SiriTodo.todos"
    
    // MARK: - 앱 그룹 (위젯/인텐트 공유용)
    /// 실제 사용 시 앱 그룹 ID로 변경 필요
    private let userDefaults = UserDefaults.standard
    // private let userDefaults = UserDefaults(suiteName: "group.com.yourcompany.SiriTodo")!
    
    // MARK: - 초기화
    private init() {
        load()
    }
    
    // MARK: - CRUD 작업
    
    /// 새 할일 추가
    /// - Parameter title: 할일 제목
    /// - Returns: 생성된 할일 항목
    @discardableResult
    func add(title: String) -> TodoItem {
        let item = TodoItem(title: title)
        todos.append(item)
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
        return todos[index]
    }
    
    /// 할일 삭제
    /// - Parameter item: 삭제할 할일
    func delete(_ item: TodoItem) {
        todos.removeAll { $0.id == item.id }
    }
    
    /// 완료된 할일만 필터링
    var completedTodos: [TodoItem] {
        todos.filter { $0.isCompleted }
    }
    
    /// 미완료 할일만 필터링
    var incompleteTodos: [TodoItem] {
        todos.filter { !$0.isCompleted }
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
            todos = [
                TodoItem(title: "Siri로 할일 추가해보기"),
                TodoItem(title: "단축어 앱에서 확인하기"),
                TodoItem(title: "AppIntents 문서 읽기")
            ]
            return
        }
        todos = decoded
    }
    
    /// 모든 데이터 초기화 (디버그용)
    func reset() {
        todos = []
    }
}
