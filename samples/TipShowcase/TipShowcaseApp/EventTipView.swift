import SwiftUI
import TipKit

// MARK: - 이벤트 기반 팁 예제 뷰
// Tips.Event와 #Rule 매크로를 사용하여 특정 조건 충족 시 팁을 표시하는 방법을 시연합니다.
// 이벤트는 donate()를 통해 기록되며, 규칙에서 발생 횟수를 확인합니다.

struct EventTipView: View {
    
    // MARK: - 팁 인스턴스
    
    /// 프로 기능 팁 (3회 사용 후 표시)
    private let proTip = ProFeatureTip()
    
    /// 파워 유저 팁 (10회 사용 후 표시)
    private let powerUserTip = PowerUserTip()
    
    /// 마스터 유저 팁 (20회 사용 후 표시)
    private let masterUserTip = MasterUserTip()
    
    /// 공유 전문가 팁 (5회 공유 후 표시)
    private let shareExpertTip = ShareExpertTip()
    
    /// 고급 검색 팁 (5회 검색 후 표시)
    private let advancedSearchTip = AdvancedSearchTip()
    
    // MARK: - 상태
    
    @State private var appLaunchCount = 0
    @State private var shareCount = 0
    @State private var searchCount = 0
    @State private var selectedDemoEvent: DemoEvent = .appLaunch
    @State private var showTipActionAlert = false
    @State private var tipActionMessage = ""
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - 소개 섹션
                    introSection
                    
                    // MARK: - 이벤트 시뮬레이터
                    eventSimulatorSection
                    
                    // MARK: - 이벤트 기반 팁 표시
                    eventTipsDisplaySection
                    
                    // MARK: - 이벤트 정의 방법
                    eventDefinitionSection
                    
                    // MARK: - 규칙 작성법
                    ruleWritingSection
                    
                    // MARK: - API 설명
                    apiExplanationSection
                }
                .padding()
            }
            .navigationTitle("이벤트 기반 팁")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        resetEventCounts()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                }
            }
            .alert("팁 액션", isPresented: $showTipActionAlert) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(tipActionMessage)
            }
        }
    }
    
    // MARK: - 소개 섹션
    
    private var introSection: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                FeatureRow(
                    icon: "bell.badge.fill",
                    title: "이벤트 기반 팁",
                    description: "특정 이벤트가 일정 횟수 발생한 후에만 팁이 표시됩니다.",
                    iconColor: .orange
                )
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("주요 구성 요소:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    BulletPoint("Tips.Event - 사용자 행동 추적")
                    BulletPoint("#Rule - 조건부 표시 규칙")
                    BulletPoint("event.donate() - 이벤트 기록")
                    BulletPoint("event.donations.count - 발생 횟수 확인")
                }
            }
        }
    }
    
    // MARK: - 이벤트 시뮬레이터 섹션
    
    private var eventSimulatorSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader("이벤트 시뮬레이터", subtitle: "이벤트를 발생시켜 팁 조건을 충족해보세요")
            
            // 이벤트 선택
            Picker("이벤트 유형", selection: $selectedDemoEvent) {
                ForEach(DemoEvent.allCases) { event in
                    Text(event.title).tag(event)
                }
            }
            .pickerStyle(.segmented)
            
            // 현재 선택된 이벤트 정보
            CardContainer {
                VStack(spacing: 20) {
                    // 이벤트 정보
                    HStack(spacing: 16) {
                        Image(systemName: selectedDemoEvent.icon)
                            .font(.title)
                            .foregroundStyle(selectedDemoEvent.color)
                            .frame(width: 60, height: 60)
                            .background(selectedDemoEvent.color.opacity(0.1))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(selectedDemoEvent.title)
                                .font(.headline)
                            
                            Text(selectedDemoEvent.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    // 현재 카운트
                    VStack(spacing: 8) {
                        Text("현재 횟수")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Text("\(currentCountForSelectedEvent)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(selectedDemoEvent.color)
                        
                        // 진행 바
                        ProgressView(
                            value: progressForSelectedEvent
                        )
                        .tint(progressForSelectedEvent >= 1.0 ? .green : selectedDemoEvent.color)
                        
                        Text(progressDescriptionForSelectedEvent)
                            .font(.caption)
                            .foregroundStyle(progressForSelectedEvent >= 1.0 ? .green : .secondary)
                    }
                    
                    // 이벤트 발생 버튼
                    Button {
                        triggerSelectedEvent()
                    } label: {
                        Label("이벤트 발생", systemImage: "plus.circle.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedDemoEvent.color)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
    }
    
    // MARK: - 이벤트 기반 팁 표시 섹션
    
    private var eventTipsDisplaySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader("활성화된 팁", subtitle: "조건이 충족되면 팁이 표시됩니다")
            
            // 프로 기능 팁 (3회)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    StatusBadge(
                        text: "3회 필요",
                        color: appLaunchCount >= 3 ? .green : .orange
                    )
                    Text("프로 기능 팁")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                TipView(proTip) { action in
                    handleTipAction(action, tipName: "프로 기능")
                }
                .tipBackground(Color.yellow.opacity(0.15))
            }
            
            // 파워 유저 팁 (10회)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    StatusBadge(
                        text: "10회 필요",
                        color: appLaunchCount >= 10 ? .green : .blue
                    )
                    Text("파워 유저 팁")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                TipView(powerUserTip)
                    .tipBackground(Color.blue.opacity(0.15))
            }
            
            // 마스터 유저 팁 (20회)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    StatusBadge(
                        text: "20회 필요",
                        color: appLaunchCount >= 20 ? .green : .purple
                    )
                    Text("마스터 유저 팁")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                TipView(masterUserTip)
                    .tipBackground(Color.purple.opacity(0.15))
            }
            
            // 공유 전문가 팁 (5회 공유)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    StatusBadge(
                        text: "공유 5회",
                        color: shareCount >= 5 ? .green : .pink
                    )
                    Text("공유 전문가 팁")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                TipView(shareExpertTip)
                    .tipBackground(Color.pink.opacity(0.15))
            }
            
            // 고급 검색 팁 (5회 검색)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    StatusBadge(
                        text: "검색 5회",
                        color: searchCount >= 5 ? .green : .indigo
                    )
                    Text("고급 검색 팁")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                TipView(advancedSearchTip)
                    .tipBackground(Color.indigo.opacity(0.15))
            }
        }
    }
    
    // MARK: - 이벤트 정의 섹션
    
    private var eventDefinitionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader("이벤트 정의 방법", subtitle: "Tips.Event 사용법")
            
            CodeSnippet(
                """
                // 이벤트 정의
                struct MyTip: Tip {
                    // 정적 이벤트 선언
                    static let featureUsedEvent = Tips.Event(
                        id: "com.app.featureUsed"
                    )
                    
                    var rules: [Rule] {
                        // 이벤트 발생 횟수 기반 규칙
                        #Rule(Self.featureUsedEvent) { event in
                            event.donations.count >= 3
                        }
                    }
                }
                
                // 이벤트 기록 (donate)
                await MyTip.featureUsedEvent.donate()
                """
            )
        }
    }
    
    // MARK: - 규칙 작성 섹션
    
    private var ruleWritingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader("#Rule 매크로 사용법", subtitle: "조건부 규칙 작성")
            
            CardContainer {
                VStack(alignment: .leading, spacing: 16) {
                    // 이벤트 기반 규칙
                    RuleExample(
                        title: "이벤트 기반 규칙",
                        code: """
                        #Rule(Self.event) { event in
                            event.donations.count >= 3
                        }
                        """,
                        description: "이벤트가 3회 이상 발생해야 표시"
                    )
                    
                    Divider()
                    
                    // 파라미터 기반 규칙
                    RuleExample(
                        title: "파라미터 기반 규칙",
                        code: """
                        #Rule(UserSettings.$isProUser) { 
                            $0 == true 
                        }
                        """,
                        description: "프로 사용자인 경우에만 표시"
                    )
                    
                    Divider()
                    
                    // 복합 규칙
                    RuleExample(
                        title: "복합 규칙 (여러 조건)",
                        code: """
                        var rules: [Rule] {
                            #Rule(Self.event) { $0.count >= 3 }
                            #Rule(Settings.$enabled) { $0 == true }
                        }
                        """,
                        description: "모든 조건이 충족되어야 표시 (AND)"
                    )
                }
            }
        }
    }
    
    // MARK: - API 설명 섹션
    
    private var apiExplanationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader("관련 TipKit API", subtitle: "이벤트 기반 팁에 사용되는 주요 API")
            
            CardContainer {
                VStack(alignment: .leading, spacing: 16) {
                    APIRow(
                        name: "Tips.Event(id:)",
                        description: "고유 식별자로 이벤트 생성"
                    )
                    
                    Divider()
                    
                    APIRow(
                        name: "event.donate()",
                        description: "이벤트 발생을 기록 (async)"
                    )
                    
                    Divider()
                    
                    APIRow(
                        name: "event.donations",
                        description: "기록된 이벤트 기부 목록"
                    )
                    
                    Divider()
                    
                    APIRow(
                        name: "#Rule",
                        description: "조건부 표시 규칙 정의 매크로"
                    )
                    
                    Divider()
                    
                    APIRow(
                        name: "@Parameter",
                        description: "팁 규칙에 사용되는 관찰 가능한 값"
                    )
                }
            }
        }
    }
    
    // MARK: - 헬퍼 계산 프로퍼티
    
    private var currentCountForSelectedEvent: Int {
        switch selectedDemoEvent {
        case .appLaunch: return appLaunchCount
        case .share: return shareCount
        case .search: return searchCount
        }
    }
    
    private var progressForSelectedEvent: Double {
        let target = selectedDemoEvent.targetCount
        let current = currentCountForSelectedEvent
        return min(Double(current) / Double(target), 1.0)
    }
    
    private var progressDescriptionForSelectedEvent: String {
        let target = selectedDemoEvent.targetCount
        let current = currentCountForSelectedEvent
        if current >= target {
            return "✅ 조건 충족! 팁이 표시됩니다."
        } else {
            return "\(target)회까지 \(target - current)번 남음"
        }
    }
    
    // MARK: - 헬퍼 메서드
    
    private func triggerSelectedEvent() {
        Task {
            switch selectedDemoEvent {
            case .appLaunch:
                await AppLifecycleEvents.appLaunched.donate()
                appLaunchCount += 1
                
            case .share:
                await FeatureUsageEvents.contentShared.donate()
                shareCount += 1
                
            case .search:
                await FeatureUsageEvents.searchPerformed.donate()
                searchCount += 1
            }
        }
    }
    
    private func resetEventCounts() {
        appLaunchCount = 0
        shareCount = 0
        searchCount = 0
    }
    
    private func handleTipAction(_ action: Tip.Action, tipName: String) {
        tipActionMessage = "\(tipName) - \(action.id) 액션 선택됨"
        showTipActionAlert = true
        TipStatistics.shared.recordActionClick()
    }
}

// MARK: - 데모 이벤트 열거형

enum DemoEvent: String, CaseIterable, Identifiable {
    case appLaunch
    case share
    case search
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .appLaunch: return "앱 실행"
        case .share: return "공유"
        case .search: return "검색"
        }
    }
    
    var description: String {
        switch self {
        case .appLaunch: return "앱이 실행될 때 발생하는 이벤트"
        case .share: return "콘텐츠를 공유할 때 발생하는 이벤트"
        case .search: return "검색을 수행할 때 발생하는 이벤트"
        }
    }
    
    var icon: String {
        switch self {
        case .appLaunch: return "app.badge.fill"
        case .share: return "square.and.arrow.up.fill"
        case .search: return "magnifyingglass"
        }
    }
    
    var color: Color {
        switch self {
        case .appLaunch: return .orange
        case .share: return .pink
        case .search: return .indigo
        }
    }
    
    var targetCount: Int {
        switch self {
        case .appLaunch: return 3
        case .share: return 5
        case .search: return 5
        }
    }
}

// MARK: - 불릿 포인트 뷰

struct BulletPoint: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundStyle(.blue)
            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - 규칙 예제 뷰

struct RuleExample: View {
    let title: String
    let code: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Text(code)
                .font(.system(.caption, design: .monospaced))
                .padding(8)
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            
            Text(description)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - 프리뷰

#Preview {
    EventTipView()
        .task {
            try? Tips.configure([
                .displayFrequency(.immediate),
                .datastoreLocation(.applicationDefault)
            ])
        }
}
