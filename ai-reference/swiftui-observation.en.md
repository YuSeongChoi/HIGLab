# SwiftUI + Observation AI Reference

> @Observable state management pattern guide. Read this document to implement modern SwiftUI apps.

## Overview

Starting from iOS 17, you can simplify state management using the `@Observable` macro.
It replaces the previous `ObservableObject` + `@Published` combination.

## Required Import

```swift
import SwiftUI
import Observation  // When using @Observable
```

## @Observable vs ObservableObject

### Previous Approach (ObservableObject)

```swift
// ❌ Legacy pattern
class OldViewModel: ObservableObject {
    @Published var count = 0
    @Published var name = ""
}

struct OldView: View {
    @StateObject var viewModel = OldViewModel()  // or @ObservedObject
    
    var body: some View {
        Text("\(viewModel.count)")
    }
}
```

### Current Recommended Approach (@Observable)

```swift
// ✅ iOS 17+ recommended pattern
@Observable
class ViewModel {
    var count = 0
    var name = ""
}

struct ModernView: View {
    @State var viewModel = ViewModel()  // Use @State!
    
    var body: some View {
        Text("\(viewModel.count)")
    }
}
```

## Key Differences

| Item | ObservableObject | @Observable |
|------|------------------|-------------|
| Property wrapper | @Published required | Not required (automatic) |
| View connection | @StateObject/@ObservedObject | @State |
| Environment injection | @EnvironmentObject | @Environment |
| Change tracking | View updates on all @Published changes | Only tracks used properties |

## Complete Working Example

```swift
import SwiftUI
import Observation

// MARK: - Model
struct Task: Identifiable {
    let id = UUID()
    var title: String
    var isCompleted: Bool
}

// MARK: - ViewModel
@Observable
class TaskViewModel {
    var tasks: [Task] = []
    var newTaskTitle = ""
    
    var pendingCount: Int {
        tasks.filter { !$0.isCompleted }.count
    }
    
    func addTask() {
        guard !newTaskTitle.isEmpty else { return }
        tasks.append(Task(title: newTaskTitle, isCompleted: false))
        newTaskTitle = ""
    }
    
    func toggleTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
        }
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
    }
}

// MARK: - View
struct ContentView: View {
    @State private var viewModel = TaskViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        TextField("New task", text: $viewModel.newTaskTitle)
                        Button("Add", action: viewModel.addTask)
                            .disabled(viewModel.newTaskTitle.isEmpty)
                    }
                }
                
                Section("Tasks (\(viewModel.pendingCount) remaining)") {
                    ForEach(viewModel.tasks) { task in
                        TaskRow(task: task, viewModel: viewModel)
                    }
                }
            }
            .navigationTitle("Tasks")
        }
    }
}

struct TaskRow: View {
    let task: Task
    let viewModel: TaskViewModel  // Pass by reference (Bindable not required)
    
    var body: some View {
        HStack {
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(task.isCompleted ? .green : .gray)
                .onTapGesture {
                    viewModel.toggleTask(task)
                }
            
            Text(task.title)
                .strikethrough(task.isCompleted)
            
            Spacer()
            
            Button(role: .destructive) {
                viewModel.deleteTask(task)
            } label: {
                Image(systemName: "trash")
            }
        }
    }
}

#Preview {
    ContentView()
}
```

## @Bindable (Two-way Binding)

```swift
@Observable
class Settings {
    var username = ""
    var notificationsEnabled = true
}

struct SettingsView: View {
    @Bindable var settings: Settings  // Wrap to enable binding
    
    var body: some View {
        Form {
            TextField("Username", text: $settings.username)
            Toggle("Notifications", isOn: $settings.notificationsEnabled)
        }
    }
}

// Usage
struct ParentView: View {
    @State var settings = Settings()
    
    var body: some View {
        SettingsView(settings: settings)
    }
}
```

## Injection with @Environment

```swift
// Register in environment
@main
struct MyApp: App {
    @State var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)  // Not EnvironmentObject!
        }
    }
}

// Read from environment
struct SomeView: View {
    @Environment(AppState.self) var appState  // Access by type
    
    var body: some View {
        Text(appState.username)
    }
}
```

## Network Loading Pattern

```swift
@Observable
class DataViewModel {
    var items: [Item] = []
    var isLoading = false
    var errorMessage: String?
    
    func loadData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            items = try await APIService.fetchItems()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

struct DataView: View {
    @State var viewModel = DataViewModel()
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if let error = viewModel.errorMessage {
                Text("Error: \(error)")
            } else {
                List(viewModel.items) { item in
                    Text(item.name)
                }
            }
        }
        .task {
            await viewModel.loadData()
        }
    }
}
```

## @ObservationIgnored

```swift
@Observable
class ViewModel {
    var visibleProperty = ""  // Tracked
    
    @ObservationIgnored
    var ignoredProperty = ""  // Not tracked (changes don't update view)
}
```

## Important Notes

1. **iOS 17+ only**: Use ObservableObject for earlier versions
2. **class only**: @Observable cannot be applied to struct
3. **Use @State**: Not @StateObject
4. **Performance improvement**: Only tracks used properties, reducing unnecessary view updates
5. **Sendable**: @Observable classes are not Sendable by default

## Migration Guide

```swift
// Before
class ViewModel: ObservableObject {
    @Published var data: [Item] = []
}

struct MyView: View {
    @StateObject var viewModel = ViewModel()
}

// After
@Observable
class ViewModel {
    var data: [Item] = []  // Remove @Published
}

struct MyView: View {
    @State var viewModel = ViewModel()  // @StateObject → @State
}
```
