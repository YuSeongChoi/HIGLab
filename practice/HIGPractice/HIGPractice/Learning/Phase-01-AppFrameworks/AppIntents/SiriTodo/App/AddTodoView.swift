import SwiftUI

// 이 파일은 SiriTodo 샘플의 "할일 추가 화면 개념"을 단순화한 참고용 뷰다.
// 구성:
// - SiriTodoSampleAddTodoView: 제목/우선순위/마감일 정도만 확인하는 간단한 폼
// 참고:
// - 원래 샘플의 실제 입력 화면은 독립 앱 UI와 상태 객체에 강하게 의존했기 때문에,
//   현재 HIGPractice 프로젝트에서는 학습용 미니 폼으로 축소했다.

struct SiriTodoSampleAddTodoView: View {
    @State private var title = ""
    @State private var priority: Priority = .normal
    @State private var dueDatePreset: DueDatePreset = .none

    var body: some View {
        Form {
            Section("기본 정보") {
                TextField("할일 제목", text: $title)
                Picker("우선순위", selection: $priority) {
                    ForEach(Priority.allCases, id: \.self) { priority in
                        Text("\(priority.emoji) \(priority.displayName)").tag(priority)
                    }
                }
            }

            Section("마감일") {
                Picker("프리셋", selection: $dueDatePreset) {
                    ForEach(DueDatePreset.allCases, id: \.self) { preset in
                        Text(label(for: preset)).tag(preset)
                    }
                }
            }

            Section("학습 포인트") {
                Text("이 화면은 실제 앱 저장 로직보다, AddTodoIntent가 어떤 입력값을 받을지 확인하기 위한 참고용 UI입니다.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Sample Add Todo")
    }

    private func label(for preset: DueDatePreset) -> String {
        switch preset {
        case .today: return "오늘"
        case .tomorrow: return "내일"
        case .thisWeekend: return "이번 주말"
        case .nextWeek: return "다음 주"
        case .nextMonth: return "다음 달"
        case .none: return "없음"
        }
    }
}
