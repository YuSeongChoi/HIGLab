import SwiftUI
import SwiftData

// 복합 정렬: 여러 기준으로 정렬

struct TaskListView: View {
    // 1차: 우선순위 내림차순 (긴급 먼저)
    // 2차: 생성일 오름차순 (같은 우선순위면 오래된 것 먼저)
    @Query(sort: [
        SortDescriptor(\TaskItem.priority.rawValue, order: .reverse),
        SortDescriptor(\TaskItem.createdAt, order: .forward)
    ])
    private var tasks: [TaskItem]
    
    var body: some View {
        List(tasks) { task in
            HStack {
                Text(task.priority.emoji)
                VStack(alignment: .leading) {
                    Text(task.title)
                    Text(task.createdAt.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

// ─────────────────────────────────────────

// 실무 정렬 패턴

struct RealWorldSortView: View {
    // 패턴 1: 미완료 우선 + 마감일 임박 순
    @Query(sort: [
        SortDescriptor(\TaskItem.isCompleted, order: .forward),  // false(미완료) 먼저
        SortDescriptor(\TaskItem.dueDate, order: .forward)       // 가까운 마감일 먼저
    ])
    private var byDueDate: [TaskItem]
    
    // 패턴 2: 카테고리별 + 우선순위별
    // (Category 모델은 Chapter 6에서 추가)
    @Query(sort: [
        SortDescriptor(\TaskItem.priority.rawValue, order: .reverse),
        SortDescriptor(\TaskItem.title, order: .forward)
    ])
    private var byPriorityAndTitle: [TaskItem]
    
    var body: some View {
        Text("실무 정렬 패턴")
    }
}

// ─────────────────────────────────────────

// 💡 정렬 순서 팁
// 1. 가장 중요한 기준을 첫 번째로
// 2. Bool은 false < true (미완료 먼저: forward)
// 3. Optional은 nil이 마지막
// 4. 같은 값일 때만 다음 정렬 기준 적용

// 정렬 결과 예시:
// 🔴 긴급 | 회의 준비 (1일 전 생성)
// 🔴 긴급 | 보고서 작성 (오늘 생성)
// 🟠 높음 | 코드 리뷰 (2일 전 생성)
// 🟡 보통 | 이메일 정리 (3일 전 생성)
