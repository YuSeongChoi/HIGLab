import SwiftUI
import SwiftData

// 완료 토글 구현

struct TaskRowWithToggle: View {
    @Bindable var task: TaskItem
    
    var body: some View {
        HStack(spacing: 12) {
            // 완료 토글 버튼
            Button {
                withAnimation(.spring(response: 0.3)) {
                    task.toggleCompletion()
                }
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(task.isCompleted ? .green : .gray)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)
            
            // 내용
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .strikethrough(task.isCompleted, color: .secondary)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)
                
                if let dueDate = task.dueDate {
                    dueDateLabel(dueDate)
                }
            }
            
            Spacer()
            
            Text(task.priority.emoji)
        }
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    private func dueDateLabel(_ date: Date) -> some View {
        let isOverdue = !task.isCompleted && date < .now
        let isToday = Calendar.current.isDateInToday(date)
        
        HStack(spacing: 4) {
            Image(systemName: isOverdue ? "exclamationmark.circle.fill" : "calendar")
                .font(.caption2)
            
            Text(dateText(date))
                .font(.caption)
        }
        .foregroundStyle(isOverdue ? .red : (isToday ? .orange : .secondary))
    }
    
    private func dateText(_ date: Date) -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "오늘 \(date.formatted(date: .omitted, time: .shortened))"
        } else if calendar.isDateInTomorrow(date) {
            return "내일"
        } else {
            return date.formatted(date: .abbreviated, time: .omitted)
        }
    }
}

// ─────────────────────────────────────────

// 스와이프 액션으로 토글

struct TaskListWithSwipe: View {
    @Query(sort: \TaskItem.createdAt, order: .reverse, animation: .default)
    private var tasks: [TaskItem]
    
    var body: some View {
        List(tasks) { task in
            TaskRowWithToggle(task: task)
                .swipeActions(edge: .leading) {
                    Button {
                        withAnimation {
                            task.toggleCompletion()
                        }
                    } label: {
                        Label(
                            task.isCompleted ? "미완료" : "완료",
                            systemImage: task.isCompleted ? "arrow.uturn.backward" : "checkmark"
                        )
                    }
                    .tint(task.isCompleted ? .orange : .green)
                }
        }
    }
}

// ─────────────────────────────────────────

// TaskItem의 toggleCompletion 메서드 (02-model-final.swift에 정의됨)
/*
extension TaskItem {
    func toggleCompletion() {
        isCompleted.toggle()
        completedAt = isCompleted ? .now : nil
    }
}
*/

#Preview {
    TaskListWithSwipe()
        .modelContainer(.preview)
}
