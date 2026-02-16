import SwiftUI
import SwiftData

// @Query with Animation
// 데이터 변경 시 부드러운 애니메이션

struct AnimatedTaskListView: View {
    // animation 파라미터로 애니메이션 적용
    @Query(sort: \TaskItem.createdAt, order: .reverse, animation: .default)
    private var tasks: [TaskItem]
    
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(tasks) { task in
                    TaskRowView(task: task)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                // 삭제 시 애니메이션 자동 적용
                                context.delete(task)
                            } label: {
                                Label("삭제", systemImage: "trash")
                            }
                        }
                }
            }
            .navigationTitle("할 일")
            .toolbar {
                Button {
                    // 추가 시 애니메이션 자동 적용
                    let task = TaskItem(title: "새 할 일 \(tasks.count + 1)")
                    context.insert(task)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

// ─────────────────────────────────────────

// 커스텀 애니메이션

struct CustomAnimationView: View {
    // 스프링 애니메이션
    @Query(
        sort: \TaskItem.createdAt,
        animation: .spring(response: 0.3, dampingFraction: 0.7)
    )
    private var tasks: [TaskItem]
    
    var body: some View {
        List(tasks) { task in
            Text(task.title)
        }
    }
}

// ─────────────────────────────────────────

// 애니메이션 비교

struct AnimationComparisonView: View {
    // 애니메이션 없음
    @Query(sort: \TaskItem.createdAt)
    private var noAnimation: [TaskItem]
    
    // 기본 애니메이션
    @Query(sort: \TaskItem.createdAt, animation: .default)
    private var defaultAnimation: [TaskItem]
    
    // 느린 애니메이션
    @Query(sort: \TaskItem.createdAt, animation: .easeInOut(duration: 0.5))
    private var slowAnimation: [TaskItem]
    
    // 바운스 애니메이션
    @Query(sort: \TaskItem.createdAt, animation: .bouncy)
    private var bouncyAnimation: [TaskItem]
    
    var body: some View {
        Text("애니메이션 비교")
    }
}

// 💡 애니메이션 사용 팁:
// - 리스트 추가/삭제에 적합
// - 너무 느린 애니메이션은 UX 저하
// - 대량 데이터 변경 시 성능 고려
// - .default가 대부분의 경우 적합
