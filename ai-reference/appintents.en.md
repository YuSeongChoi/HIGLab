# App Intents AI Reference

> Guide for integrating apps with Siri, Shortcuts, and Widgets. Read this document to generate App Intents code.

## Overview

App Intents is a framework that connects app features with Siri, the Shortcuts app, and Spotlight.
It enables users to run app features through voice commands or shortcuts.

## Required Import

```swift
import AppIntents
```

## Core Components

### 1. AppIntent Protocol (Basic Intent)

```swift
struct AddTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Task"
    static var description = IntentDescription("Adds a new task")
    
    @Parameter(title: "Task Title")
    var taskTitle: String
    
    @Parameter(title: "Priority", default: .medium)
    var priority: TaskPriority
    
    func perform() async throws -> some IntentResult {
        let task = TaskManager.shared.addTask(title: taskTitle, priority: priority)
        return .result(value: task.title, dialog: "\(taskTitle) added")
    }
}
```

### 2. AppEnum (Enum Parameters)

```swift
enum TaskPriority: String, AppEnum {
    case low, medium, high
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Priority"
    
    static var caseDisplayRepresentations: [TaskPriority: DisplayRepresentation] = [
        .low: "Low",
        .medium: "Medium",
        .high: "High"
    ]
}
```

### 3. AppEntity (Custom Entities)

```swift
struct TaskEntity: AppEntity {
    var id: UUID
    var title: String
    var isCompleted: Bool
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Task"
    
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

### 4. AppShortcutsProvider (Siri Auto-Registration)

```swift
struct MyAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddTaskIntent(),
            phrases: [
                "Add a task in \(.applicationName)",
                "Add \(\.$taskTitle) to \(.applicationName)"
            ],
            shortTitle: "Add Task",
            systemImageName: "plus.circle"
        )
    }
}
```

## Complete Working Example

```swift
import SwiftUI
import AppIntents

// MARK: - Intent Definition
struct CompleteTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "Complete Task"
    static var description = IntentDescription("Marks a task as complete")
    
    @Parameter(title: "Task")
    var task: TaskEntity
    
    static var parameterSummary: some ParameterSummary {
        Summary("Complete '\(\.$task)'")
    }
    
    func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
        await TaskManager.shared.complete(task.id)
        return .result(value: true, dialog: "\(task.title) completed!")
    }
}

// MARK: - Widget Intent Integration (iOS 17+)
struct TaskToggleIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Task"
    
    @Parameter(title: "Task ID")
    var taskId: String
    
    init() {}
    init(taskId: String) { self.taskId = taskId }
    
    func perform() async throws -> some IntentResult {
        await TaskManager.shared.toggle(UUID(uuidString: taskId)!)
        return .result()
    }
}

// Use in widget
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

## Advanced Patterns

### 1. Result Return Types

```swift
// Simple completion
func perform() async throws -> some IntentResult {
    return .result()
}

// Return value
func perform() async throws -> some IntentResult & ReturnsValue<String> {
    return .result(value: "Result value")
}

// Dialog response
func perform() async throws -> some IntentResult & ProvidesDialog {
    return .result(dialog: "Completed")
}

// Open app
func perform() async throws -> some IntentResult & OpensIntent {
    return .result(opensIntent: OpenTaskDetailIntent(taskId: id))
}
```

### 2. Dynamic Options

```swift
struct SelectTaskIntent: AppIntent {
    @Parameter(title: "Task")
    var task: TaskEntity?
    
    static var parameterSummary: some ParameterSummary {
        Summary("Select '\(\.$task)'")
    }
}

// Add search functionality to EntityQuery
struct TaskQuery: EntityStringQuery {
    func entities(matching string: String) async throws -> [TaskEntity] {
        TaskManager.shared.search(string).map { $0.toEntity() }
    }
}
```

### 3. Focus Filter (Focus Mode Integration)

```swift
struct WorkFocusFilter: SetFocusFilterIntent {
    static var title: LocalizedStringResource = "Work Mode"
    
    @Parameter(title: "Show Work Projects Only")
    var showWorkOnly: Bool
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: showWorkOnly ? "Work Only" : "All")
    }
    
    func perform() async throws -> some IntentResult {
        AppState.shared.workModeEnabled = showWorkOnly
        return .result()
    }
}
```

## Important Notes

1. **Siri Phrase Rules**
   - `\(.applicationName)` must be included
   - Use natural language phrases
   - Parameters use `\(\.$paramName)` format

2. **Widget Intent (iOS 17+)**
   - Use `Button(intent:)`
   - Executes directly without launching app
   - Interactive Widget must be enabled

3. **Background Execution**
   - Intents run in background
   - UI updates must be on main thread
   - Avoid long-running tasks (30 second limit)

4. **Testing**
   - Test directly in Shortcuts app
   - Siri: "Hey Siri, [phrase] with [app name]"
