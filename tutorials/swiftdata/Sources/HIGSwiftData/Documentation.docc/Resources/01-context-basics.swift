import SwiftData
import SwiftUI

// ModelContext: 실제 CRUD 연산이 일어나는 곳
// SwiftUI 환경에서 @Environment로 자동 주입됨

struct TaskListView: View {
    // SwiftUI 환경에서 ModelContext 가져오기
    @Environment(\.modelContext) private var context
    
    var body: some View {
        VStack {
            Button("새 할 일 추가") {
                addTask()
            }
        }
    }
    
    func addTask() {
        // 새 객체 생성
        let task = TaskItem(title: "새로운 할 일")
        
        // Context에 삽입
        context.insert(task)
        
        // 💡 자동 저장!
        // SwiftData는 기본적으로 autosave가 활성화되어 있음
        // 명시적 저장이 필요한 경우:
        // try? context.save()
    }
}

// ─────────────────────────────────────────

// Context의 주요 메서드들
func contextOperations(context: ModelContext) {
    let task = TaskItem(title: "예제")
    
    // 삽입
    context.insert(task)
    
    // 삭제
    context.delete(task)
    
    // 명시적 저장 (보통 불필요)
    try? context.save()
    
    // 변경사항 롤백
    context.rollback()
    
    // 메모리에서 객체 해제 (성능 최적화)
    context.reset()
}

// ─────────────────────────────────────────

// 백그라운드 작업용 별도 Context
@MainActor
func backgroundWork(container: ModelContainer) async {
    // 메인 컨텍스트
    let mainContext = container.mainContext
    
    // 백그라운드 작업용 새 컨텍스트
    let bgContext = ModelContext(container)
    
    // 백그라운드에서 대량 작업 수행
    Task.detached {
        for i in 0..<1000 {
            let task = TaskItem(title: "Task \(i)")
            bgContext.insert(task)
        }
        try? bgContext.save()
    }
}
