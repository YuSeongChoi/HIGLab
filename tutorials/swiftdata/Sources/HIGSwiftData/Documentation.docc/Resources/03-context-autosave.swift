import SwiftData
import SwiftUI

// SwiftData의 autosave 동작 이해하기

struct AutoSaveExampleView: View {
    @Environment(\.modelContext) private var context
    
    var body: some View {
        VStack {
            Button("할 일 추가") {
                // insert 후 별도 save() 없음
                let task = TaskItem(title: "자동 저장 테스트")
                context.insert(task)
                
                // ✅ SwiftData가 적절한 시점에 자동 저장
                // - 런루프 끝
                // - 메모리 압박 시
                // - 앱 백그라운드 진입 시
            }
        }
    }
}

// ─────────────────────────────────────────

// autosave 동작 방식

func explainAutosave(context: ModelContext) {
    // 1. 삽입
    let task = TaskItem(title: "테스트")
    context.insert(task)
    
    // 2. 수정
    task.isCompleted = true
    
    // 3. 삭제
    context.delete(task)
    
    // 위 모든 변경사항은 "pending changes"로 추적됨
    // 런루프가 끝나면 자동으로 저장됨
    
    // 명시적 저장이 필요한 경우:
    // - 백그라운드 컨텍스트 사용 시
    // - 즉시 저장이 필요한 중요 데이터
    // - 롤백 전 저장 확인
    
    do {
        try context.save()
        print("명시적 저장 완료")
    } catch {
        print("저장 실패: \(error)")
    }
}

// ─────────────────────────────────────────

// autosave 비활성화 (특수한 경우)

@main
struct NoAutoSaveApp: App {
    var container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: TaskItem.self)
            // autosave 비활성화
            container.mainContext.autosaveEnabled = false
        } catch {
            fatalError("Container 초기화 실패: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}

// ⚠️ autosave 비활성화 시:
// - 모든 변경사항을 수동으로 save() 해야 함
// - 앱 종료 시 저장 안 된 데이터 손실 가능
// - 특별한 이유 없으면 권장하지 않음
