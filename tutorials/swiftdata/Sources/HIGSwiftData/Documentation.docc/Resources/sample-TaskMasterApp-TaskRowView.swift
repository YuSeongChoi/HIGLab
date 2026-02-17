import SwiftUI
import SwiftData

// MARK: - 할일 Row 뷰

/// 할일 목록의 개별 아이템을 표시하는 뷰
/// - 완료 체크박스
/// - 제목 및 우선순위
/// - 마감일 및 카테고리 표시
struct TaskRowView: View {
    // MARK: - 속성
    
    @Bindable var task: TaskItem
    
    // MARK: - 뷰 본문
    
    var body: some View {
        HStack(spacing: 12) {
            // 완료 토글 버튼
            completionToggle
            
            // 메인 콘텐츠
            VStack(alignment: .leading, spacing: 4) {
                // 제목 행
                HStack(spacing: 6) {
                    // 우선순위 표시
                    if task.priority > 0 {
                        priorityBadge
                    }
                    
                    // 제목
                    Text(task.title)
                        .font(.body)
                        .strikethrough(task.isCompleted)
                        .foregroundStyle(task.isCompleted ? .secondary : .primary)
                        .lineLimit(2)
                }
                
                // 서브 정보 (마감일, 카테고리)
                HStack(spacing: 8) {
                    // 마감일
                    if let dueDate = task.dueDate {
                        dueDateLabel(for: dueDate)
                    }
                    
                    // 카테고리
                    if let category = task.category {
                        categoryLabel(for: category)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
    
    // MARK: - 서브뷰: 완료 토글
    
    private var completionToggle: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                task.toggleCompletion()
            }
        } label: {
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundStyle(task.isCompleted ? .green : .gray)
                .symbolEffect(.bounce, value: task.isCompleted)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - 서브뷰: 우선순위 뱃지
    
    private var priorityBadge: some View {
        let priority = task.taskPriority
        
        return Image(systemName: priority.symbol)
            .font(.caption)
            .fontWeight(.bold)
            .foregroundStyle(priorityColor(for: priority))
    }
    
    private func priorityColor(for priority: TaskPriority) -> Color {
        switch priority {
        case .none: .gray
        case .low: .blue
        case .medium: .orange
        case .high: .red
        }
    }
    
    // MARK: - 서브뷰: 마감일 라벨
    
    private func dueDateLabel(for date: Date) -> some View {
        HStack(spacing: 2) {
            Image(systemName: "calendar")
                .font(.caption2)
            
            Text(formattedDueDate(date))
                .font(.caption)
        }
        .foregroundStyle(dueDateColor)
    }
    
    private var dueDateColor: Color {
        if task.isOverdue { return .red }
        if task.isDueSoon { return .orange }
        return .secondary
    }
    
    private func formattedDueDate(_ date: Date) -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "오늘"
        } else if calendar.isDateInTomorrow(date) {
            return "내일"
        } else if calendar.isDateInYesterday(date) {
            return "어제"
        } else {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            
            // 올해인지 확인
            if calendar.component(.year, from: date) == calendar.component(.year, from: Date()) {
                formatter.dateFormat = "M월 d일"
            } else {
                formatter.dateFormat = "yyyy.M.d"
            }
            
            return formatter.string(from: date)
        }
    }
    
    // MARK: - 서브뷰: 카테고리 라벨
    
    private func categoryLabel(for category: Category) -> some View {
        HStack(spacing: 2) {
            Image(systemName: category.iconName)
                .font(.caption2)
            
            Text(category.name)
                .font(.caption)
        }
        .foregroundStyle(category.color)
    }
}

// MARK: - 프리뷰

#Preview("기본") {
    let container = ModelContainer.preview
    
    return List {
        TaskRowView(task: TaskItem(
            title: "SwiftData 문서 읽기",
            dueDate: Date(),
            priority: 3
        ))
        
        TaskRowView(task: TaskItem(
            title: "장보기 - 우유, 계란, 빵, 과일",
            dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()),
            priority: 2
        ))
        
        TaskRowView(task: TaskItem(
            title: "완료된 할일",
            isCompleted: true,
            priority: 0
        ))
        
        TaskRowView(task: TaskItem(
            title: "마감 지난 할일",
            dueDate: Calendar.current.date(byAdding: .day, value: -2, to: Date()),
            priority: 1
        ))
    }
    .modelContainer(container)
}

#Preview("다크 모드") {
    List {
        TaskRowView(task: TaskItem(
            title: "다크 모드 테스트",
            dueDate: Date(),
            priority: 3
        ))
    }
    .preferredColorScheme(.dark)
    .modelContainer(.preview)
}
