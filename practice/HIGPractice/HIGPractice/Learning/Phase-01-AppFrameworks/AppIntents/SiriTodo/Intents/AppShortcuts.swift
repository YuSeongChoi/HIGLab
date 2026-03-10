// 이 파일은 Siri/Shortcuts에 노출할 "진입 문구 모음"을 정의한다.
// 구성:
// - SiriTodoShortcuts: 앱이 자동 등록할 App Shortcut 목록
// - SiriTipView, SiriMiniTipView: 앱 안에서 보여줄 Siri 사용 예시 UI
// - TipCategory: 문구 카테고리 분류
// 참고:
// - 실제 실행 로직은 각 Intent 파일에 있고, 이 파일은 어떤 Intent를 어떤 phrase로 노출할지만 결정한다.
import AppIntents
import SwiftUI

// MARK: - 앱 단축어 정의
/// Siri에서 사용할 수 있는 단축어 문구 정의
/// 사용자가 별도 설정 없이 바로 사용 가능한 기본 단축어
///
/// ## 지원하는 기능
/// - 할일 추가 (일반/빠른/오늘/긴급)
/// - 할일 완료 (선택/다음/전체)
/// - 할일 조회 (목록/오늘/긴급/통계)
/// - 할일 검색
/// - 할일 삭제
/// - 앱 열기
struct SiriTodoShortcuts: AppShortcutsProvider {
    
    // MARK: - 앱 아이콘 색상
    
    /// 단축어 앱에서 표시할 배경색
    nonisolated static let shortcutTileColor: ShortcutTileColor = .blue
    
    // MARK: - 단축어 목록
    
    /// 앱에서 제공하는 모든 단축어 정의
    @AppShortcutsBuilder
    nonisolated static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddTodoIntent(),
            phrases: [
                "Add a todo in \(.applicationName)",
                "Create a task in \(.applicationName)",
                "할일 앱 \(.applicationName)에서 추가"
            ],
            shortTitle: "할일 추가",
            systemImageName: "plus.circle.fill"
        )

        AppShortcut(
            intent: CompleteTodoIntent(),
            phrases: [
                "Complete a todo in \(.applicationName)",
                "Mark a task done in \(.applicationName)",
                "할일 앱 \(.applicationName)에서 완료 처리"
            ],
            shortTitle: "할일 완료",
            systemImageName: "checkmark.circle.fill"
        )

        AppShortcut(
            intent: ListTodosIntent(),
            phrases: [
                "Show todos in \(.applicationName)",
                "List tasks in \(.applicationName)",
                "할일 앱 \(.applicationName) 목록 보기"
            ],
            shortTitle: "할일 목록",
            systemImageName: "list.bullet"
        )

        AppShortcut(
            intent: SearchTodosIntent(),
            phrases: [
                "Search todos in \(.applicationName)",
                "Find tasks in \(.applicationName)",
                "할일 앱 \(.applicationName)에서 검색"
            ],
            shortTitle: "검색",
            systemImageName: "magnifyingglass"
        )

        AppShortcut(
            intent: OpenSiriTodoIntent(),
            phrases: [
                "Open \(.applicationName)",
                "Launch \(.applicationName)",
                "앱 \(.applicationName) 열기"
            ],
            shortTitle: "앱 열기",
            systemImageName: "arrow.up.forward.app"
        )
    }
}

// MARK: - Siri Tip 뷰 (SwiftUI에서 사용)
/// Siri 사용 팁을 표시하는 뷰
/// ContentView 등에서 사용하여 사용자에게 음성 명령 안내
struct SiriTipView: View {
    
    // MARK: - 상태
    
    @State private var selectedCategory: TipCategory = .add
    
    // MARK: - 본문
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 헤더
            Label("Siri로 할일 관리", systemImage: "waveform.circle.fill")
                .font(.headline)
                .foregroundStyle(.primary)
            
            // 카테고리 선택
            Picker("카테고리", selection: $selectedCategory) {
                ForEach(TipCategory.allCases) { category in
                    Text(category.title).tag(category)
                }
            }
            .pickerStyle(.segmented)
            
            // 선택된 카테고리의 팁
            VStack(alignment: .leading, spacing: 10) {
                ForEach(selectedCategory.tips, id: \.self) { tip in
                    tipRow(tip)
                }
            }
            .animation(.easeInOut, value: selectedCategory)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - 팁 행
    
    private func tipRow(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "quote.bubble.fill")
                .foregroundStyle(.blue)
                .font(.caption)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - 팁 카테고리
enum TipCategory: String, CaseIterable, Identifiable {
    case add = "추가"
    case complete = "완료"
    case view = "조회"
    case manage = "관리"
    
    var id: String { rawValue }
    
    var title: String { rawValue }
    
    var tips: [String] {
        switch self {
        case .add:
            return [
                "\"할일에 장보기 추가해줘\"",
                "\"긴급 할일 보고서 작성\"",
                "\"오늘 할일 운동하기 추가\""
            ]
        case .complete:
            return [
                "\"장보기 완료해줘\"",
                "\"다음 할일 완료\"",
                "\"오늘 할일 다 완료\""
            ]
        case .view:
            return [
                "\"할일 목록 보여줘\"",
                "\"오늘 할일 뭐야\"",
                "\"긴급 할일 알려줘\""
            ]
        case .manage:
            return [
                "\"장보기 긴급으로 설정\"",
                "\"완료된 할일 정리\"",
                "\"할일 통계 보여줘\""
            ]
        }
    }
}

// MARK: - 미니 팁 뷰
/// 작은 공간에 표시하는 간단한 팁 뷰
struct SiriMiniTipView: View {
    
    let tip: String
    
    init(_ tip: String = "\"할일에 장보기 추가해줘\"") {
        self.tip = tip
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "waveform")
                .foregroundStyle(.blue)
            Text("Siri:")
                .fontWeight(.medium)
            Text(tip)
                .foregroundStyle(.secondary)
        }
        .font(.caption)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: Capsule())
    }
}
