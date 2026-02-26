# SwiftUI AI Reference

> Declarative UI framework core guide. Read this document to generate SwiftUI code.

## Overview

SwiftUI is Apple's declarative UI framework.
UI automatically updates based on state and works across all Apple platforms.

## Required Import

```swift
import SwiftUI
```

## Core Components

### 1. Basic View Structure

```swift
struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Hello, World!")
                .font(.title)
                .foregroundStyle(.primary)
            
            Button("Tap me") {
                print("Tapped")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
```

### 2. State Management (@State, @Binding)

```swift
struct CounterView: View {
    @State private var count = 0
    
    var body: some View {
        VStack {
            Text("\(count)")
                .font(.largeTitle)
            
            HStack {
                Button("-") { count -= 1 }
                Button("+") { count += 1 }
            }
            
            // Pass binding to child
            StepperView(value: $count)
        }
    }
}

struct StepperView: View {
    @Binding var value: Int
    
    var body: some View {
        Stepper("Value: \(value)", value: $value)
    }
}
```

### 3. @Observable (iOS 17+)

```swift
@Observable
class UserViewModel {
    var name = ""
    var email = ""
    var isLoggedIn = false
    
    func login() async {
        // Login logic
        isLoggedIn = true
    }
}

struct ProfileView: View {
    @State private var viewModel = UserViewModel()
    
    var body: some View {
        Form {
            TextField("Name", text: $viewModel.name)
            TextField("Email", text: $viewModel.email)
            
            Button("Login") {
                Task { await viewModel.login() }
            }
            .disabled(viewModel.name.isEmpty)
        }
    }
}
```

### 4. Navigation (iOS 16+)

```swift
struct MainView: View {
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                NavigationLink("View Details", value: "detail")
                NavigationLink(value: 42) {
                    Text("Navigate with number")
                }
            }
            .navigationTitle("Main")
            .navigationDestination(for: String.self) { value in
                Text("String: \(value)")
            }
            .navigationDestination(for: Int.self) { number in
                Text("Number: \(number)")
            }
        }
    }
}
```

## Complete Working Example

```swift
import SwiftUI

// MARK: - Model
struct Task: Identifiable {
    let id = UUID()
    var title: String
    var isCompleted: Bool
}

// MARK: - ViewModel
@Observable
class TaskListViewModel {
    var tasks: [Task] = []
    var newTaskTitle = ""
    
    var incompleteTasks: [Task] {
        tasks.filter { !$0.isCompleted }
    }
    
    func addTask() {
        guard !newTaskTitle.isEmpty else { return }
        tasks.append(Task(title: newTaskTitle, isCompleted: false))
        newTaskTitle = ""
    }
    
    func toggle(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
        }
    }
    
    func delete(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
}

// MARK: - Views
struct TaskListView: View {
    @State private var viewModel = TaskListViewModel()
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.tasks) { task in
                    TaskRowView(task: task) {
                        viewModel.toggle(task)
                    }
                }
                .onDelete(perform: viewModel.delete)
            }
            .navigationTitle("Tasks (\(viewModel.incompleteTasks.count))")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add", systemImage: "plus") {
                        showingAddSheet = true
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddTaskSheet(title: $viewModel.newTaskTitle) {
                    viewModel.addTask()
                    showingAddSheet = false
                }
            }
            .overlay {
                if viewModel.tasks.isEmpty {
                    ContentUnavailableView(
                        "No Tasks",
                        systemImage: "checklist",
                        description: Text("Tap + to add a task")
                    )
                }
            }
        }
    }
}

struct TaskRowView: View {
    let task: Task
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(task.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)
            
            Text(task.title)
                .strikethrough(task.isCompleted)
                .foregroundStyle(task.isCompleted ? .secondary : .primary)
        }
    }
}

struct AddTaskSheet: View {
    @Binding var title: String
    let onAdd: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Task title", text: $title)
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { onAdd() }
                        .disabled(title.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
```

## Advanced Patterns

### 1. Custom ViewModifier

```swift
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 2)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}

// Usage
Text("Card").cardStyle()
```

### 2. Animation

```swift
struct AnimatedView: View {
    @State private var isExpanded = false
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(.blue)
                .frame(width: isExpanded ? 200 : 100, 
                       height: isExpanded ? 200 : 100)
            
            Button("Toggle") {
                withAnimation(.spring(duration: 0.5, bounce: 0.3)) {
                    isExpanded.toggle()
                }
            }
        }
    }
}
```

### 3. Gestures

```swift
struct GestureView: View {
    @State private var offset = CGSize.zero
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Image(systemName: "star.fill")
            .font(.system(size: 50))
            .offset(offset)
            .scaleEffect(scale)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        offset = value.translation
                    }
                    .onEnded { _ in
                        withAnimation { offset = .zero }
                    }
            )
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        scale = value
                    }
            )
    }
}
```

### 4. Environment Values

```swift
// Custom environment key
struct ThemeKey: EnvironmentKey {
    static let defaultValue: Theme = .light
}

extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

// Usage
struct App: View {
    var body: some View {
        ContentView()
            .environment(\.theme, .dark)
    }
}

struct ChildView: View {
    @Environment(\.theme) var theme
}
```

## Important Notes

1. **State Management**
   - `@State`: Simple values inside View
   - `@Binding`: Values received from parent
   - `@Observable`: Complex objects (iOS 17+)
   - `@Environment`: Environment value injection

2. **Performance**
   - `body` is called frequently → keep it lightweight
   - Move heavy computations to ViewModel
   - Use `id()` modifier for forced recreation

3. **Layout**
   - Combine VStack/HStack/ZStack
   - `frame()`, `padding()` order matters
   - Use `GeometryReader` only when necessary

4. **iOS 17+ Recommended APIs**
   - `@Observable` > `ObservableObject`
   - `NavigationStack` > `NavigationView`
   - Use `ContentUnavailableView`
