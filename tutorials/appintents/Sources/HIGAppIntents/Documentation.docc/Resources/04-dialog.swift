import AppIntents

// MARK: - Siri 대화 흐름

struct SmartAddTodoIntent: AppIntent {
    static var title: LocalizedStringResource = "할 일 추가"
    
    @Parameter(title: "할 일 제목")
    var todoTitle: String?
    
    // 파라미터 값을 묻는 대화
    static var parameterSummary: some ParameterSummary {
        Summary("\(\.$todoTitle) 추가하기")
    }
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // 제목이 없으면 Siri가 물어봄
        guard let title = todoTitle else {
            throw $todoTitle.needsValueError("어떤 할 일을 추가할까요?")
        }
        
        TodoStore.shared.add(title: title)
        
        return .result(dialog: "\(title) 추가했어요!")
    }
}

// 확인 대화
struct DeleteAllTodosIntent: AppIntent {
    static var title: LocalizedStringResource = "모든 할 일 삭제"
    
    // 실행 전 확인
    func perform() async throws -> some IntentResult & ProvidesDialog {
        try await requestConfirmation(
            result: .result(dialog: "정말 모든 할 일을 삭제할까요?")
        )
        
        TodoStore.shared.deleteAll()
        return .result(dialog: "모두 삭제했습니다")
    }
}
