import SwiftUI

// 이 파일은 독립 샘플 앱의 실제 진입점이 아니라,
// 현재 HIGPractice 프로젝트 안에서 SiriTodo 샘플 UI를 설명하기 위한 참고용 컨테이너다.
// 구성:
// - SiriTodoSampleRootView: 샘플 화면 진입용 래퍼
// - SiriTodoSampleInfoCard: 이 샘플이 어떤 구조였는지 설명하는 안내 카드
// 참고:
// - 기존 샘플의 `@main` 앱 진입점은 현재 프로젝트의 메인 앱과 충돌하므로 제거했다.
// - 실제 앱 엔트리 포인트는 HIGPractice의 기존 App 파일이 유지한다.

struct SiriTodoSampleRootView: View {
    @StateObject private var store = TodoStore.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    SiriTodoSampleInfoCard()
                    SiriTodoLearningGuideCard()
                    SiriTodoConceptCard()
                    SiriTodoStoreStatusCard(store: store)
                    SiriTodoSampleContentView()
                }
                .padding()
            }
            .navigationTitle("SiriTodo Sample")
        }
    }
}

private struct SiriTodoSampleInfoCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("샘플 앱 구조 안내")
                .font(.headline)
            Text("이 폴더의 UI 파일들은 원래 SiriTodo 독립 앱을 구성하던 화면이었지만, 현재 프로젝트에서는 App Intents 학습 참고용 샘플 뷰로만 유지합니다.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct SiriTodoLearningGuideCard: View {
    private let steps = [
        "1. Shortcuts 앱에서 HIGPractice의 App Shortcut이 보이는지 확인",
        "2. '할일 추가'를 실행해 title 파라미터를 직접 입력",
        "3. '할일 완료'와 '할일 목록'을 실행해 저장소 반영 여부 확인",
        "4. 마지막으로 '앱 열기' Intent가 포그라운드 전환을 수행하는지 확인"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("테스트 순서")
                .font(.headline)

            ForEach(steps, id: \.self) { step in
                Text(step)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct SiriTodoConceptCard: View {
    private let concepts = [
        "AppEntity: Siri/Shortcuts가 참조할 앱 내부 데이터 타입을 등록",
        "AppIntent: 외부에서 호출 가능한 앱 동작을 정의",
        "AppShortcutsProvider: 어떤 Intent를 어떤 phrase로 노출할지 결정",
        "MainActor.run: 메인 액터 저장소 접근이 필요한 순간만 안전하게 hop"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("핵심 학습 포인트")
                .font(.headline)

            ForEach(concepts, id: \.self) { concept in
                Label(concept, systemImage: "checkmark.seal")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct SiriTodoStoreStatusCard: View {
    @ObservedObject var store: TodoStore

    var body: some View {
        let stats = store.statistics

        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("현재 TodoStore 상태")
                    .font(.headline)
                Spacer()
                Button("샘플로 리셋") {
                    store.resetToSample()
                }
                .buttonStyle(.borderedProminent)
            }

            Text(stats.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                SiriTodoMetricChip(title: "전체", value: "\(stats.total)")
                SiriTodoMetricChip(title: "완료", value: "\(stats.completed)")
                SiriTodoMetricChip(title: "오늘", value: "\(stats.dueToday)")
                SiriTodoMetricChip(title: "완료율", value: stats.completionRateString)
            }

            if store.todos.isEmpty {
                Text("현재 저장된 할일이 없습니다. Shortcuts에서 AddTodoIntent를 먼저 실행해보세요.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(store.todos.prefix(3)) { todo in
                    HStack(spacing: 10) {
                        Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(todo.isCompleted ? .green : .secondary)
                        Text(todo.summary)
                            .font(.footnote)
                        Spacer()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct SiriTodoMetricChip: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline.weight(.bold))
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }
}
