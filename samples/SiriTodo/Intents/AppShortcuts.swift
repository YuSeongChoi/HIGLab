import AppIntents

// MARK: - 앱 단축어 정의
/// Siri에서 사용할 수 있는 단축어 문구 정의
/// 사용자가 별도 설정 없이 바로 사용 가능한 기본 단축어
struct SiriTodoShortcuts: AppShortcutsProvider {
    
    // MARK: - 단축어 목록
    
    /// 앱에서 제공하는 단축어 정의
    static var appShortcuts: [AppShortcut] {
        
        // MARK: 할일 추가 단축어
        AppShortcut(
            intent: AddTodoIntent(),
            phrases: [
                // 기본 문구
                "할일에 \(\.$title) 추가해줘",
                "\(.applicationName)에 \(\.$title) 추가",
                "\(\.$title) 할일 만들어줘",
                
                // 한국어 변형
                "\(\.$title) 추가해줘 \(.applicationName)",
                "새 할일 \(\.$title)",
                
                // 영어 지원 (선택)
                "Add \(\.$title) to \(.applicationName)"
            ],
            shortTitle: "할일 추가",
            systemImageName: "plus.circle.fill"
        )
        
        // MARK: 할일 목록 단축어
        AppShortcut(
            intent: ListTodosIntent(),
            phrases: [
                // 기본 문구
                "\(.applicationName) 보여줘",
                "할일 목록 보여줘",
                "할일 뭐 있어",
                "오늘 할일 알려줘",
                
                // 필터 포함
                "미완료 할일 보여줘",
                "완료된 할일 보여줘",
                
                // 영어 지원
                "Show my \(.applicationName)"
            ],
            shortTitle: "할일 목록",
            systemImageName: "list.bullet"
        )
        
        // MARK: 할일 완료 단축어
        AppShortcut(
            intent: CompleteTodoIntent(),
            phrases: [
                // 기본 문구
                "\(\.$todo) 완료해줘",
                "\(\.$todo) 끝났어",
                "\(\.$todo) 했어",
                
                // 변형
                "\(.applicationName)에서 \(\.$todo) 체크"
            ],
            shortTitle: "할일 완료",
            systemImageName: "checkmark.circle.fill"
        )
        
        // MARK: 다음 할일 완료 단축어
        AppShortcut(
            intent: CompleteNextTodoIntent(),
            phrases: [
                // 간편 완료
                "다음 할일 완료",
                "할일 하나 완료",
                "방금 한 거 완료",
                
                // 영어 지원
                "Complete next \(.applicationName)"
            ],
            shortTitle: "다음 할일 완료",
            systemImageName: "arrow.right.circle.fill"
        )
    }
}

// MARK: - Siri Tip 뷰 (SwiftUI에서 사용)
import SwiftUI

/// Siri 사용 팁을 표시하는 뷰
/// ContentView 등에서 사용하여 사용자에게 음성 명령 안내
struct SiriTipView: View {
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Siri로 할일 관리", systemImage: "waveform.circle.fill")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                tipRow("\"할일에 장보기 추가해줘\"")
                tipRow("\"할일 목록 보여줘\"")
                tipRow("\"다음 할일 완료\"")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private func tipRow(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "quote.bubble")
                .foregroundStyle(.blue)
            Text(text)
        }
    }
}

#Preview {
    SiriTipView()
        .padding()
}
