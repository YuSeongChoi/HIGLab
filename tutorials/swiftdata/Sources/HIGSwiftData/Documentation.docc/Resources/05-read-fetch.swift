import SwiftData
import Foundation

// FetchDescriptor로 직접 조회

@MainActor
class TaskService {
    let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    // MARK: - 단일 조회
    
    /// ID로 할 일 찾기
    func findTask(by id: UUID) -> TaskItem? {
        let predicate = #Predicate<TaskItem> { $0.id == id }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        
        return try? context.fetch(descriptor).first
    }
    
    /// 제목으로 찾기
    func findTask(by title: String) -> TaskItem? {
        let predicate = #Predicate<TaskItem> { $0.title == title }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        
        return try? context.fetch(descriptor).first
    }
    
    // MARK: - 목록 조회
    
    /// 미완료 할 일 목록
    func getPendingTasks() -> [TaskItem] {
        let predicate = #Predicate<TaskItem> { !$0.isCompleted }
        let descriptor = FetchDescriptor(
            predicate: predicate,
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        return (try? context.fetch(descriptor)) ?? []
    }
    
    /// 오늘 마감인 할 일
    func getTodayTasks() -> [TaskItem] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = #Predicate<TaskItem> { task in
            if let dueDate = task.dueDate {
                return dueDate >= startOfDay && dueDate < endOfDay
            }
            return false
        }
        
        let descriptor = FetchDescriptor(predicate: predicate)
        return (try? context.fetch(descriptor)) ?? []
    }
    
    /// 우선순위별 할 일
    func getTasks(priority: Priority) -> [TaskItem] {
        let predicate = #Predicate<TaskItem> { $0.priority == priority }
        let descriptor = FetchDescriptor(predicate: predicate)
        return (try? context.fetch(descriptor)) ?? []
    }
    
    // MARK: - 집계
    
    /// 할 일 개수
    func getTaskCount(completed: Bool? = nil) -> Int {
        var descriptor = FetchDescriptor<TaskItem>()
        
        if let completed {
            descriptor.predicate = #Predicate<TaskItem> { $0.isCompleted == completed }
        }
        
        return (try? context.fetchCount(descriptor)) ?? 0
    }
    
    /// 통계 정보
    func getStatistics() -> (total: Int, pending: Int, completed: Int) {
        let total = getTaskCount()
        let completed = getTaskCount(completed: true)
        let pending = total - completed
        return (total, pending, completed)
    }
}

// ─────────────────────────────────────────

// 💡 FetchDescriptor vs @Query
// FetchDescriptor: 명령형, 한 번 실행, ViewModel에서 사용
// @Query: 선언형, 자동 갱신, SwiftUI 뷰에서 사용

// FetchDescriptor 옵션:
// - predicate: 필터 조건
// - sortBy: 정렬 기준
// - fetchLimit: 최대 개수
// - fetchOffset: 시작 위치 (페이징)
// - includePendingChanges: 미저장 변경사항 포함 여부
