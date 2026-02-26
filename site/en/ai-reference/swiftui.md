# SwiftUI AI Reference

> 선언적 UI 프레임워크 핵심 가이드. 이 문서를 읽고 SwiftUI 코드를 생성할 수 있습니다.

## 개요

SwiftUI는 Apple의 선언적 UI 프레임워크입니다.
상태 기반으로 UI가 자동 업데이트되며, 모든 Apple 플랫폼에서 동작합니다.

## 필수 Import

```swift
import SwiftUI
```

## 핵심 구성요소

### 1. View 기본 구조

```swift
struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Hello, World!")
                .font(.title)
                .foregroundStyle(.primary)
            
            Button("탭하기") {
                print("탭됨")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
```

### 2. 상태 관리 (@State, @Binding)

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
            
            // 자식에게 바인딩 전달
            StepperView(value: $count)
        }
    }
}

struct StepperView: View {
    @Binding var value: Int
    
    var body: some View {
        Stepper("값: \(value)", value: $value)
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
        // 로그인 로직
        isLoggedIn = true
    }
}

struct ProfileView: View {
    @State private var viewModel = UserViewModel()
    
    var body: some View {
        Form {
            TextField("이름", text: $viewModel.name)
            TextField("이메일", text: $viewModel.email)
            
            Button("로그인") {
                Task { await viewModel.login() }
            }
            .disabled(viewModel.name.isEmpty)
        }
    }
}
```

### 4. 네비게이션 (iOS 16+)

```swift
struct MainView: View {
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                NavigationLink("상세 보기", value: "detail")
                NavigationLink(value: 42) {
                    Text("숫자로 이동")
                }
            }
            .navigationTitle("메인")
            .navigationDestination(for: String.self) { value in
                Text("문자열: \(value)")
            }
            .navigationDestination(for: Int.self) { number in
                Text("숫자: \(number)")
            }
        }
    }
}
```

## 전체 작동 예제

```swift
import SwiftUI

// MARK: - 모델
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
            .navigationTitle("할 일 (\(viewModel.incompleteTasks.count))")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("추가", systemImage: "plus") {
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
                        "할 일이 없습니다",
                        systemImage: "checklist",
                        description: Text("+ 버튼을 눌러 추가하세요")
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
                TextField("할 일 제목", text: $title)
            }
            .navigationTitle("새 할 일")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("추가") { onAdd() }
                        .disabled(title.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
```

## 고급 패턴

### 1. 커스텀 ViewModifier

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

// 사용
Text("카드").cardStyle()
```

### 2. 애니메이션

```swift
struct AnimatedView: View {
    @State private var isExpanded = false
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(.blue)
                .frame(width: isExpanded ? 200 : 100, 
                       height: isExpanded ? 200 : 100)
            
            Button("토글") {
                withAnimation(.spring(duration: 0.5, bounce: 0.3)) {
                    isExpanded.toggle()
                }
            }
        }
    }
}
```

### 3. 제스처

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

### 4. 환경 값

```swift
// 커스텀 환경 키
struct ThemeKey: EnvironmentKey {
    static let defaultValue: Theme = .light
}

extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

// 사용
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

## 주의사항

1. **상태 관리**
   - `@State`: View 내부 단순 값
   - `@Binding`: 부모로부터 받은 값
   - `@Observable`: 복잡한 객체 (iOS 17+)
   - `@Environment`: 환경 값 주입

2. **성능**
   - `body`는 자주 호출됨 → 가볍게 유지
   - 무거운 연산은 ViewModel로 분리
   - `id()` 수정자로 강제 재생성

3. **레이아웃**
   - VStack/HStack/ZStack 조합
   - `frame()`, `padding()` 순서 중요
   - `GeometryReader`는 꼭 필요할 때만

4. **iOS 17+ 권장 API**
   - `@Observable` > `ObservableObject`
   - `NavigationStack` > `NavigationView`
   - `ContentUnavailableView` 활용
