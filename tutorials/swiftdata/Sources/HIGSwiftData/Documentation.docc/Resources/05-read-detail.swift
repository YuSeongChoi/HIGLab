import SwiftUI
import SwiftData

// 할 일 상세 뷰

struct TaskDetailView: View {
    let task: TaskItem
    
    @Environment(\.modelContext) private var context
    @State private var showingEditSheet = false
    
    var body: some View {
        List {
            // 기본 정보
            Section {
                statusRow
                priorityRow
            }
            
            // 메모
            if !task.note.isEmpty {
                Section("메모") {
                    Text(task.note)
                        .foregroundStyle(.secondary)
                }
            }
            
            // 날짜 정보
            Section("날짜") {
                dateRow("생성일", date: task.createdAt)
                
                if let dueDate = task.dueDate {
                    dateRow("마감일", date: dueDate, isOverdue: task.isOverdue)
                }
                
                if let completedAt = task.completedAt {
                    dateRow("완료일", date: completedAt)
                }
            }
            
            // 태그
            if !task.tags.isEmpty {
                Section("태그") {
                    FlowLayout(spacing: 8) {
                        ForEach(task.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.blue.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            
            // 액션
            Section {
                Button {
                    withAnimation {
                        task.toggleCompletion()
                    }
                } label: {
                    Label(
                        task.isCompleted ? "미완료로 변경" : "완료로 표시",
                        systemImage: task.isCompleted ? "arrow.uturn.backward" : "checkmark"
                    )
                }
                
                Button(role: .destructive) {
                    context.delete(task)
                } label: {
                    Label("삭제", systemImage: "trash")
                }
            }
        }
        .navigationTitle(task.title)
        .toolbar {
            Button("편집") {
                showingEditSheet = true
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditTaskSheet(task: task)
        }
    }
    
    // MARK: - Row Views
    
    private var statusRow: some View {
        HStack {
            Text("상태")
            Spacer()
            HStack(spacing: 4) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                Text(task.isCompleted ? "완료" : "진행 중")
            }
            .foregroundStyle(task.isCompleted ? .green : .orange)
        }
    }
    
    private var priorityRow: some View {
        HStack {
            Text("우선순위")
            Spacer()
            Text("\(task.priority.emoji) \(task.priority.title)")
        }
    }
    
    private func dateRow(_ label: String, date: Date, isOverdue: Bool = false) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(date.formatted(date: .abbreviated, time: .shortened))
                .foregroundStyle(isOverdue ? .red : .secondary)
        }
    }
}

// ─────────────────────────────────────────

// 간단한 FlowLayout (태그 표시용)
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }
    
    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var maxHeight: CGFloat = 0
        let maxWidth = proposal.width ?? .infinity
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += maxHeight + spacing
                maxHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            maxHeight = max(maxHeight, size.height)
            x += size.width + spacing
        }
        
        return (positions, CGSize(width: maxWidth, height: y + maxHeight))
    }
}
