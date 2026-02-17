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
    static var shortcutTileColor: ShortcutTileColor = .blue
    
    // MARK: - 단축어 목록
    
    /// 앱에서 제공하는 모든 단축어 정의
    @AppShortcutsBuilder
    static var appShortcuts: [AppShortcut] {
        
        // MARK: ─────────────────────────────────────────────
        // MARK: 📝 할일 추가 단축어
        // MARK: ─────────────────────────────────────────────
        
        /// 기본 할일 추가
        AppShortcut(
            intent: AddTodoIntent(),
            phrases: [
                // 한국어 기본 문구
                "할일에 \(\.$title) 추가해줘",
                "\(.applicationName)에 \(\.$title) 추가",
                "\(\.$title) 할일 만들어줘",
                "새 할일 \(\.$title)",
                "\(\.$title) 추가해줘 \(.applicationName)",
                
                // 한국어 변형
                "\(\.$title) 할일 등록",
                "할일 추가 \(\.$title)",
                "\(.applicationName) 할일 추가 \(\.$title)",
                
                // 영어 지원
                "Add \(\.$title) to \(.applicationName)",
                "Create todo \(\.$title)"
            ],
            shortTitle: "할일 추가",
            systemImageName: "plus.circle.fill"
        )
        
        /// 빠른 할일 추가
        AppShortcut(
            intent: QuickAddTodoIntent(),
            phrases: [
                "빨리 \(\.$title) 추가",
                "간단히 \(\.$title) 추가",
                "\(.applicationName) 빠른 추가 \(\.$title)",
                "Quick add \(\.$title) to \(.applicationName)"
            ],
            shortTitle: "빠른 추가",
            systemImageName: "bolt.circle.fill"
        )
        
        /// 오늘 할일 추가
        AppShortcut(
            intent: AddTodayTodoIntent(),
            phrases: [
                "오늘 할일 \(\.$title) 추가",
                "\(\.$title) 오늘까지",
                "\(.applicationName)에 오늘 할일 \(\.$title)",
                "Add \(\.$title) for today"
            ],
            shortTitle: "오늘 할일",
            systemImageName: "calendar.badge.plus"
        )
        
        /// 긴급 할일 추가
        AppShortcut(
            intent: AddUrgentTodoIntent(),
            phrases: [
                "긴급 할일 \(\.$title)",
                "\(\.$title) 긴급으로 추가",
                "급한 할일 \(\.$title)",
                "Urgent todo \(\.$title)"
            ],
            shortTitle: "긴급 할일",
            systemImageName: "exclamationmark.circle.fill"
        )
        
        // MARK: ─────────────────────────────────────────────
        // MARK: ✅ 할일 완료 단축어
        // MARK: ─────────────────────────────────────────────
        
        /// 할일 완료
        AppShortcut(
            intent: CompleteTodoIntent(),
            phrases: [
                "\(\.$todo) 완료해줘",
                "\(\.$todo) 끝났어",
                "\(\.$todo) 했어",
                "\(\.$todo) 체크해줘",
                "\(.applicationName)에서 \(\.$todo) 완료",
                "Complete \(\.$todo)"
            ],
            shortTitle: "할일 완료",
            systemImageName: "checkmark.circle.fill"
        )
        
        /// 다음 할일 완료
        AppShortcut(
            intent: CompleteNextTodoIntent(),
            phrases: [
                "다음 할일 완료",
                "할일 하나 완료",
                "방금 한 거 완료",
                "가장 중요한 할일 완료",
                "\(.applicationName) 다음 완료",
                "Complete next \(.applicationName)"
            ],
            shortTitle: "다음 완료",
            systemImageName: "arrow.right.circle.fill"
        )
        
        /// 오늘 할일 모두 완료
        AppShortcut(
            intent: CompleteTodayTodosIntent(),
            phrases: [
                "오늘 할일 다 완료",
                "오늘 할일 모두 끝",
                "\(.applicationName) 오늘 다 완료"
            ],
            shortTitle: "오늘 모두 완료",
            systemImageName: "star.fill"
        )
        
        // MARK: ─────────────────────────────────────────────
        // MARK: 📋 할일 조회 단축어
        // MARK: ─────────────────────────────────────────────
        
        /// 할일 목록 보기
        AppShortcut(
            intent: ListTodosIntent(),
            phrases: [
                "\(.applicationName) 보여줘",
                "할일 목록 보여줘",
                "할일 뭐 있어",
                "할일 알려줘",
                "할일 리스트",
                "\(.applicationName) 목록",
                "Show my \(.applicationName)",
                "List todos"
            ],
            shortTitle: "할일 목록",
            systemImageName: "list.bullet"
        )
        
        /// 오늘 할일 보기
        AppShortcut(
            intent: GetTodayTodosIntent(),
            phrases: [
                "오늘 할일 보여줘",
                "오늘 뭐 해야 해",
                "오늘 할 거 알려줘",
                "\(.applicationName) 오늘 할일",
                "What's due today"
            ],
            shortTitle: "오늘 할일",
            systemImageName: "calendar"
        )
        
        /// 긴급 할일 보기
        AppShortcut(
            intent: GetUrgentTodosIntent(),
            phrases: [
                "긴급 할일 보여줘",
                "급한 할일 뭐 있어",
                "중요한 할일 알려줘",
                "\(.applicationName) 긴급 할일",
                "Show urgent todos"
            ],
            shortTitle: "긴급 할일",
            systemImageName: "exclamationmark.triangle"
        )
        
        /// 통계 보기
        AppShortcut(
            intent: GetTodoStatisticsIntent(),
            phrases: [
                "할일 통계 보여줘",
                "\(.applicationName) 통계",
                "할일 현황 알려줘",
                "완료율 알려줘",
                "Todo statistics"
            ],
            shortTitle: "통계",
            systemImageName: "chart.pie.fill"
        )
        
        // MARK: ─────────────────────────────────────────────
        // MARK: 🔍 검색 단축어
        // MARK: ─────────────────────────────────────────────
        
        /// 할일 검색
        AppShortcut(
            intent: SearchTodosIntent(),
            phrases: [
                "\(\.$query) 할일 찾아줘",
                "할일에서 \(\.$query) 검색",
                "\(.applicationName)에서 \(\.$query) 찾기",
                "Search \(\.$query) in \(.applicationName)"
            ],
            shortTitle: "검색",
            systemImageName: "magnifyingglass"
        )
        
        // MARK: ─────────────────────────────────────────────
        // MARK: ⚙️ 관리 단축어
        // MARK: ─────────────────────────────────────────────
        
        /// 우선순위 설정
        AppShortcut(
            intent: SetPriorityIntent(),
            phrases: [
                "\(\.$todo) 우선순위 \(\.$priority)",
                "\(\.$todo) \(\.$priority)으로 설정",
                "Set \(\.$todo) priority to \(\.$priority)"
            ],
            shortTitle: "우선순위 설정",
            systemImageName: "arrow.up.arrow.down.circle"
        )
        
        /// 긴급으로 설정
        AppShortcut(
            intent: SetUrgentIntent(),
            phrases: [
                "\(\.$todo) 긴급으로",
                "\(\.$todo) 급하게 설정",
                "Make \(\.$todo) urgent"
            ],
            shortTitle: "긴급 설정",
            systemImageName: "exclamationmark.circle"
        )
        
        /// 마감일 설정
        AppShortcut(
            intent: SetDueDateIntent(),
            phrases: [
                "\(\.$todo) 마감일 \(\.$dueDate)",
                "\(\.$todo) \(\.$dueDate)까지",
                "Set due date for \(\.$todo)"
            ],
            shortTitle: "마감일 설정",
            systemImageName: "calendar.badge.clock"
        )
        
        // MARK: ─────────────────────────────────────────────
        // MARK: 🗑️ 삭제 단축어
        // MARK: ─────────────────────────────────────────────
        
        /// 할일 삭제
        AppShortcut(
            intent: DeleteTodoIntent(),
            phrases: [
                "\(\.$todo) 삭제해줘",
                "\(\.$todo) 지워줘",
                "\(.applicationName)에서 \(\.$todo) 삭제",
                "Delete \(\.$todo)"
            ],
            shortTitle: "삭제",
            systemImageName: "trash"
        )
        
        /// 완료된 할일 정리
        AppShortcut(
            intent: DeleteCompletedTodosIntent(),
            phrases: [
                "완료된 할일 정리",
                "끝난 할일 삭제",
                "\(.applicationName) 정리",
                "Clean up completed todos"
            ],
            shortTitle: "완료 정리",
            systemImageName: "trash.circle"
        )
        
        // MARK: ─────────────────────────────────────────────
        // MARK: 📱 앱 열기 단축어
        // MARK: ─────────────────────────────────────────────
        
        /// 앱 열기
        AppShortcut(
            intent: OpenSiriTodoIntent(),
            phrases: [
                "\(.applicationName) 열어줘",
                "할일 앱 실행",
                "\(.applicationName) 실행",
                "Open \(.applicationName)"
            ],
            shortTitle: "앱 열기",
            systemImageName: "arrow.up.forward.app"
        )
        
        /// 새 할일 화면 열기
        AppShortcut(
            intent: OpenAddTodoIntent(),
            phrases: [
                "새 할일 화면 열어",
                "할일 추가 화면",
                "\(.applicationName) 추가 화면"
            ],
            shortTitle: "추가 화면",
            systemImageName: "plus.rectangle"
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

// MARK: - 프리뷰
#Preview("Siri Tip") {
    SiriTipView()
        .padding()
}

#Preview("Mini Tip") {
    SiriMiniTipView()
        .padding()
}
