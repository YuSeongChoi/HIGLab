# SwiftData AI Reference

> 데이터 영속성 프레임워크 구현 가이드. 이 문서를 읽고 SwiftData CRUD를 구현할 수 있습니다.

## 개요

SwiftData는 Swift 매크로를 활용한 현대적인 데이터 영속성 프레임워크입니다.
Core Data의 복잡함 없이 @Model 매크로만으로 데이터 모델을 정의할 수 있습니다.

## 필수 Import

```swift
import SwiftData
import SwiftUI
```

## 핵심 구성요소

### 1. @Model 매크로 (데이터 모델)

```swift
@Model
final class Task {
    var title: String
    var isCompleted: Bool
    var createdAt: Date
    var dueDate: Date?
    var priority: Int
    
    // 관계 (1:N)
    @Relationship(deleteRule: .cascade)
    var subtasks: [Subtask]?
    
    // 역관계
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

### 2. ModelContainer 설정

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

// 또는 커스텀 설정
let container = try ModelContainer(
    for: Task.self, Category.self,
    configurations: ModelConfiguration(isStoredInMemoryOnly: false)
)
```

### 3. @Query 매크로 (데이터 조회)

```swift
struct TaskListView: View {
    // 기본 쿼리
    @Query var tasks: [Task]
    
    // 정렬
    @Query(sort: \Task.createdAt, order: .reverse)
    var sortedTasks: [Task]
    
    // 필터링 + 정렬
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

### 4. ModelContext (CRUD 작업)

```swift
struct TaskView: View {
    @Environment(\.modelContext) private var context
    
    // CREATE
    func addTask(title: String) {
        let task = Task(title: title)
        context.insert(task)
        // 자동 저장 (명시적: try? context.save())
    }
    
    // UPDATE
    func toggleTask(_ task: Task) {
        task.isCompleted.toggle()
        // 변경 자동 추적
    }
    
    // DELETE
    func deleteTask(_ task: Task) {
        context.delete(task)
    }
}
```

## 전체 작동 예제: 할일 앱

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
                // 입력 필드
                HStack {
                    TextField("새 할일", text: $newTitle)
                    Button("추가") {
                        addTodo()
                    }
                    .disabled(newTitle.isEmpty)
                }
                
                // 할일 목록
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
            .navigationTitle("할일 목록")
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

## 고급 쿼리

### 동적 필터링

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

### 검색

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

### FetchDescriptor (코드에서 직접 쿼리)

```swift
func fetchPendingTasks(context: ModelContext) throws -> [Task] {
    let descriptor = FetchDescriptor<Task>(
        predicate: #Predicate { !$0.isCompleted },
        sortBy: [SortDescriptor(\Task.priority, order: .reverse)]
    )
    return try context.fetch(descriptor)
}

// 개수만 조회
func countPendingTasks(context: ModelContext) throws -> Int {
    let descriptor = FetchDescriptor<Task>(
        predicate: #Predicate { !$0.isCompleted }
    )
    return try context.fetchCount(descriptor)
}
```

## 관계 (Relationships)

### 1:N 관계

```swift
@Model
final class Author {
    var name: String
    
    @Relationship(deleteRule: .cascade)  // Author 삭제 시 Book도 삭제
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

### 사용

```swift
let author = Author(name: "홍길동")
let book = Book(title: "첫 번째 책", author: author)
context.insert(author)
context.insert(book)
```

## 마이그레이션

```swift
// 스키마 버전 관리
enum SchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] {
        [Task.self]
    }
}

enum SchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)
    static var models: [any PersistentModel.Type] {
        [TaskV2.self]  // 새 필드 추가된 모델
    }
}

// 마이그레이션 플랜
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

## @Transient (저장 제외)

```swift
@Model
final class User {
    var name: String
    var email: String
    
    @Transient  // 저장되지 않음
    var isLoggedIn: Bool = false
}
```

## 주의사항

1. **@Model은 class만**: struct 불가
2. **final 권장**: 상속 시 문제 발생 가능
3. **자동 저장**: 기본적으로 자동 저장 (명시적 save() 호출 가능)
4. **메인 스레드**: UI 작업은 @MainActor 컨텍스트에서
5. **Preview**: `inMemory: true` 사용 권장

## CloudKit 동기화

```swift
let config = ModelConfiguration(
    cloudKitDatabase: .private("iCloud.com.myapp")
)
let container = try ModelContainer(for: Task.self, configurations: config)
```
