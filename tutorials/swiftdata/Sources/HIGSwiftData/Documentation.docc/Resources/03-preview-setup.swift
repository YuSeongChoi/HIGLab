import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationStack {
            Text("TaskMaster")
                .navigationTitle("할 일")
        }
    }
}

// ═══════════════════════════════════════════
// Preview에서 SwiftData 사용하기
// ═══════════════════════════════════════════

#Preview {
    ContentView()
        // Preview에도 modelContainer 필요!
        .modelContainer(for: TaskItem.self, inMemory: true)
}

// ─────────────────────────────────────────

// 샘플 데이터가 필요한 Preview

#Preview("샘플 데이터 포함") {
    // 메모리 전용 컨테이너 생성
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: TaskItem.self,
        configurations: config
    )
    
    // 샘플 데이터 삽입
    let context = container.mainContext
    for sample in TaskItem.samples {
        context.insert(sample)
    }
    
    return ContentView()
        .modelContainer(container)
}

// ─────────────────────────────────────────

// 재사용 가능한 Preview Container

extension ModelContainer {
    @MainActor
    static var preview: ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: TaskItem.self,
            configurations: config
        )
        
        // 샘플 데이터
        let context = container.mainContext
        context.insert(TaskItem(title: "운동하기", priority: .high))
        context.insert(TaskItem(title: "책 읽기", isCompleted: true))
        context.insert(TaskItem(title: "장보기", priority: .low))
        
        return container
    }
}

// 사용법:
#Preview("재사용 컨테이너") {
    ContentView()
        .modelContainer(.preview)
}

// ─────────────────────────────────────────

// 💡 Preview 팁
// 1. inMemory: true로 실제 데이터에 영향 없이 테스트
// 2. 샘플 데이터로 다양한 상태 테스트
// 3. PreviewContainer를 만들어 재사용
// 4. 에러 상태도 Preview로 확인
