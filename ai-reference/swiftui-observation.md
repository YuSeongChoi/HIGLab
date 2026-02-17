# SwiftUI + Observation AI Reference

> @Observable 상태 관리 패턴 가이드. 이 문서를 읽고 현대적인 SwiftUI 앱을 구현할 수 있습니다.

## 개요

iOS 17부터 `@Observable` 매크로를 사용해 상태 관리를 단순화할 수 있습니다.
기존 `ObservableObject` + `@Published` 조합을 대체합니다.

## 필수 Import

```swift
import SwiftUI
import Observation  // @Observable 사용 시
```

## @Observable vs ObservableObject

### 이전 방식 (ObservableObject)

```swift
// ❌ 구식 패턴
class OldViewModel: ObservableObject {
    @Published var count = 0
    @Published var name = ""
}

struct OldView: View {
    @StateObject var viewModel = OldViewModel()  // 또는 @ObservedObject
    
    var body: some View {
        Text("\(viewModel.count)")
    }
}
```

### 현재 권장 방식 (@Observable)

```swift
// ✅ iOS 17+ 권장 패턴
@Observable
class ViewModel {
    var count = 0
    var name = ""
}

struct ModernView: View {
    @State var viewModel = ViewModel()  // @State 사용!
    
    var body: some View {
        Text("\(viewModel.count)")
    }
}
```

## 핵심 차이점

| 항목 | ObservableObject | @Observable |
|------|------------------|-------------|
| 프로퍼티 래퍼 | @Published 필요 | 불필요 (자동) |
| 뷰 연결 | @StateObject/@ObservedObject | @State |
| 환경 주입 | @EnvironmentObject | @Environment |
| 변경 추적 | 모든 @Published 변경 시 뷰 갱신 | 사용된 프로퍼티만 추적 |

## 전체 작동 예제

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
                        TextField("새 할일", text: $viewModel.newTaskTitle)
                        Button("추가", action: viewModel.addTask)
                            .disabled(viewModel.newTaskTitle.isEmpty)
                    }
                }
                
                Section("할일 (\(viewModel.pendingCount)개 남음)") {
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
    let viewModel: TaskViewModel  // 참조 전달 (Bindable 불필요)
    
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

## @Bindable (양방향 바인딩)

```swift
@Observable
class Settings {
    var username = ""
    var notificationsEnabled = true
}

struct SettingsView: View {
    @Bindable var settings: Settings  // 바인딩 가능하게 래핑
    
    var body: some View {
        Form {
            TextField("사용자명", text: $settings.username)
            Toggle("알림", isOn: $settings.notificationsEnabled)
        }
    }
}

// 사용
struct ParentView: View {
    @State var settings = Settings()
    
    var body: some View {
        SettingsView(settings: settings)
    }
}
```

## @Environment로 주입

```swift
// 환경에 등록
@main
struct MyApp: App {
    @State var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)  // EnvironmentObject가 아님!
        }
    }
}

// 환경에서 읽기
struct SomeView: View {
    @Environment(AppState.self) var appState  // 타입으로 접근
    
    var body: some View {
        Text(appState.username)
    }
}
```

## 네트워크 로딩 패턴

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
                Text("오류: \(error)")
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
    var visibleProperty = ""  // 추적됨
    
    @ObservationIgnored
    var ignoredProperty = ""  // 추적 안 됨 (변경해도 뷰 갱신 X)
}
```

## 주의사항

1. **iOS 17+ 전용**: 이전 버전은 ObservableObject 사용
2. **class만 가능**: struct에 @Observable 불가
3. **@State 사용**: @StateObject 아님
4. **성능 향상**: 사용된 프로퍼티만 추적하므로 불필요한 뷰 갱신 감소
5. **Sendable**: @Observable 클래스는 기본적으로 Sendable 아님

## 마이그레이션 가이드

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
    var data: [Item] = []  // @Published 제거
}

struct MyView: View {
    @State var viewModel = ViewModel()  // @StateObject → @State
}
```
