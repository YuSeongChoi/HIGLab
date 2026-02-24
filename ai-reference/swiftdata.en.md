# SwiftData AI Reference

> Data persistence framework implementation guide. Read this document to implement SwiftData CRUD operations.

## Overview

SwiftData is a modern data persistence framework that leverages Swift macros.
You can define data models with just the @Model macro without the complexity of Core Data.

## Required Import

```swift
import SwiftData
import SwiftUI
```

## Core Components

### 1. @Model Macro (Data Model)

```swift
@Model
final class Task {
    var title: String
    var isCompleted: Bool
    var createdAt: Date
    var dueDate: Date?
    var priority: Int
    
    // Relationship (1:N)
    @Relationship(deleteRule: .cascade)
    var subtasks: [Subtask]?
    
    // Inverse relationship
    @Relationship(inverse: \Category.tasks)
    var category: Category?
    
    init(title: String, isCompleted: Bool = false, priority: Int = 0) {
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = Date()
        self.priority = priority
    }
}

@Model
final class Category {
    var name: String
    var color: String
    var tasks: [Task]?
    
    init(name: String, color: String = "blue") {
        self.name = name
        self.color = color
    }
}
```

### 2. ModelContainer Setup

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Task.self, Category.self])
    }
}

// Or custom configuration
let container = try ModelContainer(
    for: Task.self, Category.self,
    configurations: ModelConfiguration(isStoredInMemoryOnly: false)
)
```

### 3. @Query Macro (Data Retrieval)

```swift
struct TaskListView: View {
    // Basic query
    @Query var tasks: [Task]
    
    // Sorting
    @Query(sort: \Task.createdAt, order: .reverse)
    var sortedTasks: [Task]
    
    // Filtering + Sorting
    @Query(
        filter: #Predicate<Task> { !$0.isCompleted },
        sort: [SortDescriptor(\Task.priority, order: .reverse)]
    )
    var pendingTasks: [Task]
    
    var body: some View {
        List(tasks) { task in
            Text(task.title)
        }
    }
}
```

### 4. ModelContext (CRUD Operations)

```swift
struct TaskView: View {
    @Environment(\.modelContext) private var context
    
    // CREATE
    func addTask(title: String) {
        let task = Task(title: title)
        context.insert(task)
        // Auto-save (explicit: try? context.save())
    }
    
    // UPDATE
    func toggleTask(_ task: Task) {
        task.isCompleted.toggle()
        // Changes are automatically tracked
    }
    
    // DELETE
    func deleteTask(_ task: Task) {
        context.delete(task)
    }
}
```

## Complete Working Example: Todo App

```swift
import SwiftUI
import SwiftData

// MARK: - Model
@Model
final class TodoItem {
    var title: String
    var isCompleted: Bool
    var createdAt: Date
    
    init(title: String) {
        self.title = title
        self.isCompleted = false
        self.createdAt = Date()
    }
}

// MARK: - App
@main
struct TodoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: TodoItem.self)
    }
}

// MARK: - View
struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \TodoItem.createdAt, order: .reverse) var todos: [TodoItem]
    @State private var newTitle = ""
    
    var body: some View {
        NavigationStack {
            List {
                // Input field
                HStack {
                    TextField("New todo", text: $newTitle)
                    Button("Add") {
                        addTodo()
                    }
                    .disabled(newTitle.isEmpty)
                }
                
                // Todo list
                ForEach(todos) { todo in
                    HStack {
                        Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(todo.isCompleted ? .green : .gray)
                            .onTapGesture {
                                todo.isCompleted.toggle()
                            }
                        
                        Text(todo.title)
                            .strikethrough(todo.isCompleted)
                    }
                }
                .onDelete(perform: deleteTodos)
            }
            .navigationTitle("Todo List")
        }
    }
    
    private func addTodo() {
        let todo = TodoItem(title: newTitle)
        context.insert(todo)
        newTitle = ""
    }
    
    private func deleteTodos(at offsets: IndexSet) {
        for index in offsets {
            context.delete(todos[index])
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: TodoItem.self, inMemory: true)
}
```

## Advanced Queries

### Dynamic Filtering

```swift
struct FilteredListView: View {
    @Query var tasks: [Task]
    
    init(showCompleted: Bool) {
        let predicate = #Predicate<Task> { task in
            showCompleted || !task.isCompleted
        }
        _tasks = Query(filter: predicate, sort: \Task.createdAt)
    }
    
    var body: some View {
        List(tasks) { task in
            Text(task.title)
        }
    }
}
```

### Search

```swift
struct SearchableListView: View {
    @Query var tasks: [Task]
    @State private var searchText = ""
    
    init(searchText: String) {
        if searchText.isEmpty {
            _tasks = Query()
        } else {
            let predicate = #Predicate<Task> { task in
                task.title.localizedStandardContains(searchText)
            }
            _tasks = Query(filter: predicate)
        }
    }
}
```

### FetchDescriptor (Direct Query in Code)

```swift
func fetchPendingTasks(context: ModelContext) throws -> [Task] {
    let descriptor = FetchDescriptor<Task>(
        predicate: #Predicate { !$0.isCompleted },
        sortBy: [SortDescriptor(\Task.priority, order: .reverse)]
    )
    return try context.fetch(descriptor)
}

// Count only
func countPendingTasks(context: ModelContext) throws -> Int {
    let descriptor = FetchDescriptor<Task>(
        predicate: #Predicate { !$0.isCompleted }
    )
    return try context.fetchCount(descriptor)
}
```

## Relationships

### 1:N Relationship

```swift
@Model
final class Author {
    var name: String
    
    @Relationship(deleteRule: .cascade)  // Delete books when author is deleted
    var books: [Book]?
    
    init(name: String) {
        self.name = name
    }
}

@Model
final class Book {
    var title: String
    var author: Author?
    
    init(title: String, author: Author? = nil) {
        self.title = title
        self.author = author
    }
}
```

### Usage

```swift
let author = Author(name: "John Doe")
let book = Book(title: "First Book", author: author)
context.insert(author)
context.insert(book)
```

## Migration

```swift
// Schema version management
enum SchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] {
        [Task.self]
    }
}

enum SchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)
    static var models: [any PersistentModel.Type] {
        [TaskV2.self]  // Model with new fields
    }
}

// Migration plan
enum MigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [SchemaV1.self, SchemaV2.self]
    }
    
    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }
    
    static let migrateV1toV2 = MigrationStage.lightweight(
        fromVersion: SchemaV1.self,
        toVersion: SchemaV2.self
    )
}
```

## @Transient (Exclude from Storage)

```swift
@Model
final class User {
    var name: String
    var email: String
    
    @Transient  // Not persisted
    var isLoggedIn: Bool = false
}
```

## Important Notes

1. **@Model is class only**: struct not supported
2. **final recommended**: Issues may occur with inheritance
3. **Auto-save**: Auto-save by default (explicit save() call possible)
4. **Main thread**: UI operations in @MainActor context
5. **Preview**: Use `inMemory: true` recommended

## CloudKit Sync

```swift
let config = ModelConfiguration(
    cloudKitDatabase: .private("iCloud.com.myapp")
)
let container = try ModelContainer(for: Task.self, configurations: config)
```
