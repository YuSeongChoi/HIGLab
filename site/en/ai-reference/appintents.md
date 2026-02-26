# App Intents AI Reference

> Siri, 단축어, 위젯과 앱을 통합하는 가이드. 이 문서를 읽고 App Intents 코드를 생성할 수 있습니다.

## 개요

App Intents는 Siri, 단축어 앱, Spotlight와 앱 기능을 연결하는 프레임워크입니다.
사용자가 음성 명령이나 단축어로 앱 기능을 실행할 수 있게 합니다.

## 필수 Import

```swift
import AppIntents
```

## 핵심 구성요소

### 1. AppIntent 프로토콜 (기본 Intent)

```swift
struct AddTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "할 일 추가"
    static var description = IntentDescription("새로운 할 일을 추가합니다")
    
    @Parameter(title: "할 일 제목")
    var taskTitle: String
    
    @Parameter(title: "우선순위", default: .medium)
    var priority: TaskPriority
    
    func perform() async throws -> some IntentResult {
        let task = TaskManager.shared.addTask(title: taskTitle, priority: priority)
        return .result(value: task.title, dialog: "\(taskTitle) 추가됨")
    }
}
```

### 2. AppEnum (열거형 파라미터)

```swift
enum TaskPriority: String, AppEnum {
    case low, medium, high
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "우선순위"
    
    static var caseDisplayRepresentations: [TaskPriority: DisplayRepresentation] = [
        .low: "낮음",
        .medium: "보통",
        .high: "높음"
    ]
}
```

### 3. AppEntity (커스텀 엔티티)

```swift
struct TaskEntity: AppEntity {
    var id: UUID
    var title: String
    var isCompleted: Bool
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "할 일"
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)")
    }
    
    static var defaultQuery = TaskQuery()
}

struct TaskQuery: EntityQuery {
    func entities(for identifiers: [UUID]) async throws -> [TaskEntity] {
        TaskManager.shared.tasks(for: identifiers).map { $0.toEntity() }
    }
    
    func suggestedEntities() async throws -> [TaskEntity] {
        TaskManager.shared.recentTasks.map { $0.toEntity() }
    }
}
```

### 4. AppShortcutsProvider (Siri 자동 등록)

```swift
struct MyAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddTaskIntent(),
            phrases: [
                "할 일 추가해줘 \(.applicationName)",
                "\(.applicationName)에 \(\.$taskTitle) 추가"
            ],
            shortTitle: "할 일 추가",
            systemImageName: "plus.circle"
        )
    }
}
```

## 전체 작동 예제

```swift
import SwiftUI
import AppIntents

// MARK: - Intent 정의
struct CompleteTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "할 일 완료"
    static var description = IntentDescription("할 일을 완료 처리합니다")
    
    @Parameter(title: "할 일")
    var task: TaskEntity
    
    static var parameterSummary: some ParameterSummary {
        Summary("'\(\.$task)' 완료하기")
    }
    
    func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
        await TaskManager.shared.complete(task.id)
        return .result(value: true, dialog: "\(task.title) 완료!")
    }
}

// MARK: - 위젯 Intent 연동 (iOS 17+)
struct TaskToggleIntent: AppIntent {
    static var title: LocalizedStringResource = "할 일 토글"
    
    @Parameter(title: "Task ID")
    var taskId: String
    
    init() {}
    init(taskId: String) { self.taskId = taskId }
    
    func perform() async throws -> some IntentResult {
        await TaskManager.shared.toggle(UUID(uuidString: taskId)!)
        return .result()
    }
}

// 위젯에서 사용
struct TaskWidgetView: View {
    let task: TaskItem
    
    var body: some View {
        Button(intent: TaskToggleIntent(taskId: task.id.uuidString)) {
            HStack {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                Text(task.title)
            }
        }
    }
}
```

## 고급 패턴

### 1. 결과 반환 타입들

```swift
// 단순 완료
func perform() async throws -> some IntentResult {
    return .result()
}

// 값 반환
func perform() async throws -> some IntentResult & ReturnsValue<String> {
    return .result(value: "결과값")
}

// 대화 응답
func perform() async throws -> some IntentResult & ProvidesDialog {
    return .result(dialog: "완료되었습니다")
}

// 앱 열기
func perform() async throws -> some IntentResult & OpensIntent {
    return .result(opensIntent: OpenTaskDetailIntent(taskId: id))
}
```

### 2. 동적 옵션 제공

```swift
struct SelectTaskIntent: AppIntent {
    @Parameter(title: "할 일")
    var task: TaskEntity?
    
    static var parameterSummary: some ParameterSummary {
        Summary("'\(\.$task)' 선택")
    }
}

// EntityQuery에 검색 기능 추가
struct TaskQuery: EntityStringQuery {
    func entities(matching string: String) async throws -> [TaskEntity] {
        TaskManager.shared.search(string).map { $0.toEntity() }
    }
}
```

### 3. Focus Filter (집중 모드 연동)

```swift
struct WorkFocusFilter: SetFocusFilterIntent {
    static var title: LocalizedStringResource = "업무 모드"
    
    @Parameter(title: "업무 프로젝트만 표시")
    var showWorkOnly: Bool
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: showWorkOnly ? "업무만" : "전체")
    }
    
    func perform() async throws -> some IntentResult {
        AppState.shared.workModeEnabled = showWorkOnly
        return .result()
    }
}
```

## 주의사항

1. **Siri 구문 규칙**
   - `\(.applicationName)` 필수 포함
   - 자연스러운 한국어 구문 사용
   - 파라미터는 `\(\.$paramName)` 형식

2. **위젯 Intent (iOS 17+)**
   - `Button(intent:)` 사용
   - 앱 실행 없이 바로 실행됨
   - Interactive Widget 활성화 필요

3. **백그라운드 실행**
   - Intent는 백그라운드에서 실행됨
   - UI 업데이트는 메인 스레드에서
   - 긴 작업은 피하기 (30초 제한)

4. **테스트**
   - 단축어 앱에서 직접 테스트
   - Siri: "Hey Siri, [앱이름]으로 [구문]"
