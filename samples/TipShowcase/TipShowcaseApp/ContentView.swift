import SwiftUI
import TipKit

// MARK: - 메인 콘텐츠 뷰
// 앱의 메인 탭 뷰입니다.
// 각 탭에서 TipKit의 다양한 기능을 시연합니다.

struct ContentView: View {
    
    // MARK: - 환경
    
    @EnvironmentObject var configManager: TipConfigurationManager
    @EnvironmentObject var groupManager: TipGroupManager
    @EnvironmentObject var statistics: TipStatistics
    
    // MARK: - 상태
    
    /// 현재 선택된 탭
    @State private var selectedTab: TabItem = .inline
    
    // MARK: - Body
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // MARK: - 인라인 팁 탭
            InlineTipView()
                .tabItem {
                    Label(TabItem.inline.title, systemImage: TabItem.inline.icon)
                }
                .tag(TabItem.inline)
            
            // MARK: - 팝오버 팁 탭
            PopoverTipView()
                .tabItem {
                    Label(TabItem.popover.title, systemImage: TabItem.popover.icon)
                }
                .tag(TabItem.popover)
            
            // MARK: - 이벤트 기반 팁 탭
            EventTipView()
                .tabItem {
                    Label(TabItem.event.title, systemImage: TabItem.event.icon)
                }
                .tag(TabItem.event)
            
            // MARK: - 온보딩 탭
            OnboardingView()
                .tabItem {
                    Label(TabItem.onboarding.title, systemImage: TabItem.onboarding.icon)
                }
                .tag(TabItem.onboarding)
            
            // MARK: - 조건부 팁 탭
            ConditionalTipView()
                .tabItem {
                    Label(TabItem.conditional.title, systemImage: TabItem.conditional.icon)
                }
                .tag(TabItem.conditional)
            
            // MARK: - 설정 탭
            SettingsView()
                .tabItem {
                    Label(TabItem.settings.title, systemImage: TabItem.settings.icon)
                }
                .tag(TabItem.settings)
        }
        .onChange(of: selectedTab) { _, newTab in
            // 탭 전환 이벤트 기록
            Task {
                await TipEventRecorder.recordTabSwitched()
            }
        }
    }
}

// MARK: - 탭 아이템 정의

/// 탭 바 아이템 열거형
enum TabItem: String, CaseIterable, Identifiable {
    case inline
    case popover
    case event
    case onboarding
    case conditional
    case settings
    
    var id: String { rawValue }
    
    /// 탭 제목
    var title: String {
        switch self {
        case .inline: return "인라인"
        case .popover: return "팝오버"
        case .event: return "이벤트"
        case .onboarding: return "온보딩"
        case .conditional: return "조건부"
        case .settings: return "설정"
        }
    }
    
    /// 탭 아이콘
    var icon: String {
        switch self {
        case .inline: return "text.bubble"
        case .popover: return "bubble.left.and.bubble.right"
        case .event: return "bell.badge"
        case .onboarding: return "graduationcap"
        case .conditional: return "switch.2"
        case .settings: return "gear"
        }
    }
    
    /// 탭 설명
    var description: String {
        switch self {
        case .inline:
            return "화면에 직접 삽입되는 인라인 팁"
        case .popover:
            return "UI 요소에 연결되는 팝오버 팁"
        case .event:
            return "이벤트 기반으로 표시되는 팁"
        case .onboarding:
            return "순차적 온보딩 시퀀스"
        case .conditional:
            return "조건에 따라 표시되는 팁"
        case .settings:
            return "팁 설정 및 디버그 도구"
        }
    }
}

// MARK: - 공통 뷰 컴포넌트

/// 섹션 헤더 뷰
struct SectionHeader: View {
    let title: String
    let subtitle: String?
    
    init(_ title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
            
            if let subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// 카드 스타일 컨테이너
struct CardContainer<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

/// 기능 설명 행
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let iconColor: Color
    
    init(
        icon: String,
        title: String,
        description: String,
        iconColor: Color = .blue
    ) {
        self.icon = icon
        self.title = title
        self.description = description
        self.iconColor = iconColor
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(iconColor)
                .frame(width: 40, height: 40)
                .background(iconColor.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

/// 코드 스니펫 뷰
struct CodeSnippet: View {
    let code: String
    let language: String
    
    init(_ code: String, language: String = "swift") {
        self.code = code
        self.language = language
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 언어 라벨
            HStack {
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                    .font(.caption2)
                Text(language)
                    .font(.caption2)
                    .textCase(.uppercase)
                Spacer()
                
                // 복사 버튼
                Button {
                    UIPasteboard.general.string = code
                } label: {
                    Image(systemName: "doc.on.doc")
                        .font(.caption)
                }
            }
            .foregroundStyle(.secondary)
            
            // 코드
            Text(code)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.primary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

/// 상태 뱃지 뷰
struct StatusBadge: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

/// 진행 표시기 뷰
struct ProgressIndicator: View {
    let progress: Double
    let label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.subheadline)
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            ProgressView(value: progress)
                .tint(progress >= 1.0 ? .green : .blue)
        }
    }
}

// MARK: - 프리뷰

#Preview {
    ContentView()
        .environmentObject(TipConfigurationManager.shared)
        .environmentObject(TipGroupManager.shared)
        .environmentObject(TipStatistics.shared)
}
