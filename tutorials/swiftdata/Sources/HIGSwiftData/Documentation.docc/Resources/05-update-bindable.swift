import SwiftUI
import SwiftData

// @Bindable로 직접 수정

struct TaskEditView: View {
    // @Bindable: SwiftData 객체를 SwiftUI에 바인딩
    @Bindable var task: TaskItem
    
    var body: some View {
        Form {
            // TextField에 직접 바인딩!
            // 입력할 때마다 task.title이 자동으로 변경됨
            TextField("제목", text: $task.title)
            
            TextField("메모", text: $task.note, axis: .vertical)
                .lineLimit(3...6)
            
            // Picker도 직접 바인딩
            Picker("우선순위", selection: $task.priority) {
                ForEach(Priority.allCases) { priority in
                    Text(priority.title).tag(priority)
                }
            }
            
            // Toggle도 직접 바인딩
            Toggle("완료", isOn: $task.isCompleted)
        }
    }
}

// ─────────────────────────────────────────

// @Bindable vs @Binding vs @State

/*
 @Bindable: SwiftData/Observable 객체의 프로퍼티 바인딩
 - @Model 클래스에 사용
 - 객체 자체를 받고, $로 프로퍼티 접근
 
 @Binding: 부모에서 전달받은 값 바인딩
 - 값 타입에 사용
 - 부모의 @State와 연결
 
 @State: 뷰 로컬 상태
 - 값 타입에 사용
 - 뷰 내부에서만 사용
*/

struct BindableExampleView: View {
    // SwiftData 객체는 @Bindable
    @Bindable var task: TaskItem
    
    // 로컬 상태는 @State
    @State private var showDetail = false
    
    var body: some View {
        VStack {
            // $task.title로 바인딩
            TextField("제목", text: $task.title)
            
            // $showDetail로 바인딩
            Toggle("상세 보기", isOn: $showDetail)
            
            if showDetail {
                Text(task.note)
            }
        }
    }
}

// ─────────────────────────────────────────

// 💡 @Bindable 동작 원리
// 1. @Model 객체는 Observable 프로토콜 자동 채택
// 2. @Bindable이 Observable 객체를 래핑
// 3. $로 프로퍼티 접근 시 Binding<T> 반환
// 4. 프로퍼티 변경 → 자동 추적 → autosave

// 주의: @Bindable은 class에만 사용 가능!
// struct는 @Binding 사용
