import AppIntents

// MARK: - 파라미터가 있는 Intent

struct AddTodoWithTitleIntent: AppIntent {
    static var title: LocalizedStringResource = "할 일 추가"
    
    // 파라미터 정의
    @Parameter(title: "할 일 제목")
    var todoTitle: String
    
    @Parameter(title: "우선순위", default: .medium)
    var priority: TodoPriority
    
    @Parameter(title: "마감일", optionality: .optional)
    var dueDate: Date?
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let todo = Todo(
            title: todoTitle,
            priority: priority,
            dueDate: dueDate
        )
        TodoStore.shared.add(todo)
        
        return .result(dialog: "\(todoTitle) 추가 완료!")
    }
}

// 열거형도 파라미터로 사용 가능
enum TodoPriority: String, AppEnum {
    case high, medium, low
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "우선순위")
    
    static var caseDisplayRepresentations: [TodoPriority: DisplayRepresentation] = [
        .high: "높음",
        .medium: "보통",
        .low: "낮음"
    ]
}
