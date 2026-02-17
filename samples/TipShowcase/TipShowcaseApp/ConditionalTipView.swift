import SwiftUI
import TipKit

// MARK: - 조건부 팁 뷰
// @Parameter 기반의 조건부 팁 표시를 시연합니다.
// 사용자 설정, 시간, 경험 수준 등에 따라 다른 팁이 표시됩니다.

struct ConditionalTipView: View {
    
    // MARK: - 팁 인스턴스
    
    private let proUserTip = ProUserExclusiveTip()
    private let beginnerTip = BeginnerTip()
    private let returningUserTip = ReturningUserTip()
    private let morningTip = MorningTip()
    private let eveningTip = EveningTip()
    private let weekendTip = WeekendTip()
    private let loyalUserTip = LoyalUserTip()
    
    // MARK: - 상태
    
    @State private var isProUser = UserSettingsParameters.isProUser
    @State private var advancedFeaturesEnabled = UserSettingsParameters.advancedFeaturesEnabled
    @State private var experienceLevel = UserSettingsParameters.userExperienceLevel
    @State private var daysSinceInstall = TimeBasedParameters.daysSinceInstall
    @State private var currentHour = TimeBasedParameters.currentHour
    @State private var isWeekday = TimeBasedParameters.isWeekday
    @State private var showTipActionAlert = false
    @State private var tipActionMessage = ""
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - 소개 섹션
                    introSection
                    
                    // MARK: - 사용자 설정 기반 팁
                    userSettingsSection
                    
                    // MARK: - 시간 기반 팁
                    timeBasedSection
                    
                    // MARK: - 경험 수준 기반 팁
                    experienceLevelSection
                    
                    // MARK: - 파라미터 시뮬레이터
                    parameterSimulatorSection
                    
                    // MARK: - 활성화된 조건부 팁
                    activeConditionalTipsSection
                    
                    // MARK: - 구현 패턴
                    implementationPatternsSection
                }
                .padding()
            }
            .navigationTitle("조건부 팁")
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
                    icon: "switch.2",
                    title: "조건부 팁",
                    description: "사용자의 상태, 설정, 시간 등에 따라 팁을 조건부로 표시합니다.",
                    iconColor: .purple
                )
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("조건 유형:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    BulletPoint("사용자 설정 (프로 사용자, 알림 등)")
                    BulletPoint("경험 수준 (초보, 중급, 고급)")
                    BulletPoint("시간대 (아침, 저녁, 주말)")
                    BulletPoint("사용 기간 (신규, 복귀, 장기)")
                }
            }
        }
    }
    
    // MARK: - 사용자 설정 섹션
    
    private var userSettingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader("사용자 설정 기반", subtitle: "설정에 따라 다른 팁 표시")
            
            CardContainer {
                VStack(spacing: 16) {
                    // 프로 사용자 토글
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("프로 사용자")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("프로 전용 팁이 표시됩니다")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $isProUser)
                            .labelsHidden()
                            .onChange(of: isProUser) { _, newValue in
                                UserSettingsParameters.isProUser = newValue
                            }
                    }
                    
                    Divider()
                    
                    // 고급 기능 토글
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("고급 기능 활성화")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("고급 기능 관련 팁이 표시됩니다")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $advancedFeaturesEnabled)
                            .labelsHidden()
                            .disabled(!isProUser)
                            .onChange(of: advancedFeaturesEnabled) { _, newValue in
                                UserSettingsParameters.advancedFeaturesEnabled = newValue
                            }
                    }
                    .opacity(isProUser ? 1 : 0.5)
                }
            }
            
            // 현재 상태 표시
            HStack(spacing: 12) {
                StatusIndicator(
                    title: "프로 사용자",
                    isActive: isProUser,
                    activeColor: .blue
                )
                
                StatusIndicator(
                    title: "고급 기능",
                    isActive: advancedFeaturesEnabled,
                    activeColor: .purple
                )
            }
        }
    }
    
    // MARK: - 시간 기반 섹션
    
    private var timeBasedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader("시간 기반 팁", subtitle: "시간대에 따라 다른 팁 표시")
            
            CardContainer {
                VStack(spacing: 16) {
                    // 현재 시간 슬라이더
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("시뮬레이션 시간")
                                .font(.subheadline)
                            Spacer()
                            Text("\(currentHour):00")
                                .font(.headline)
                                .monospacedDigit()
                        }
                        
                        Slider(value: Binding(
                            get: { Double(currentHour) },
                            set: { currentHour = Int($0) }
                        ), in: 0...23, step: 1)
                        .onChange(of: currentHour) { _, newValue in
                            TimeBasedParameters.currentHour = newValue
                        }
                    }
                    
                    // 시간대 표시
                    HStack(spacing: 8) {
                        TimeZoneIndicator(
                            title: "아침",
                            icon: "sunrise.fill",
                            isActive: currentHour >= 6 && currentHour < 12,
                            color: .orange
                        )
                        
                        TimeZoneIndicator(
                            title: "오후",
                            icon: "sun.max.fill",
                            isActive: currentHour >= 12 && currentHour < 18,
                            color: .yellow
                        )
                        
                        TimeZoneIndicator(
                            title: "저녁",
                            icon: "moon.stars.fill",
                            isActive: currentHour >= 18 && currentHour < 22,
                            color: .indigo
                        )
                        
                        TimeZoneIndicator(
                            title: "밤",
                            icon: "moon.fill",
                            isActive: currentHour >= 22 || currentHour < 6,
                            color: .gray
                        )
                    }
                    
                    Divider()
                    
                    // 주중/주말 토글
                    HStack {
                        Text("주중/주말")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Picker("", selection: $isWeekday) {
                            Text("주중").tag(true)
                            Text("주말").tag(false)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 150)
                        .onChange(of: isWeekday) { _, newValue in
                            TimeBasedParameters.isWeekday = newValue
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 경험 수준 섹션
    
    private var experienceLevelSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader("경험 수준 기반", subtitle: "사용자 경험에 따라 다른 팁")
            
            CardContainer {
                VStack(alignment: .leading, spacing: 16) {
                    Text("경험 수준 선택")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    // 경험 수준 선택
                    HStack(spacing: 12) {
                        ExperienceLevelButton(
                            title: "초보",
                            icon: "leaf.fill",
                            level: 0,
                            currentLevel: $experienceLevel,
                            color: .green
                        )
                        
                        ExperienceLevelButton(
                            title: "중급",
                            icon: "star.fill",
                            level: 1,
                            currentLevel: $experienceLevel,
                            color: .orange
                        )
                        
                        ExperienceLevelButton(
                            title: "고급",
                            icon: "crown.fill",
                            level: 2,
                            currentLevel: $experienceLevel,
                            color: .purple
                        )
                    }
                    
                    Divider()
                    
                    // 설치 후 일수
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("설치 후 일수")
                                .font(.subheadline)
                            Spacer()
                            Text("\(daysSinceInstall)일")
                                .font(.headline)
                                .monospacedDigit()
                        }
                        
                        Slider(value: Binding(
                            get: { Double(daysSinceInstall) },
                            set: { daysSinceInstall = Int($0) }
                        ), in: 0...60, step: 1)
                        .onChange(of: daysSinceInstall) { _, newValue in
                            TimeBasedParameters.daysSinceInstall = newValue
                        }
                        
                        // 사용자 유형 표시
                        HStack {
                            if daysSinceInstall < 7 {
                                StatusBadge(text: "신규 사용자", color: .green)
                            } else if daysSinceInstall < 30 {
                                StatusBadge(text: "일반 사용자", color: .blue)
                            } else {
                                StatusBadge(text: "장기 사용자", color: .purple)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 파라미터 시뮬레이터 섹션
    
    private var parameterSimulatorSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader("현재 파라미터 상태", subtitle: "@Parameter 값 확인")
            
            CardContainer {
                VStack(alignment: .leading, spacing: 12) {
                    ParameterRow(
                        name: "isProUser",
                        value: "\(isProUser)",
                        valueColor: isProUser ? .green : .red
                    )
                    
                    Divider()
                    
                    ParameterRow(
                        name: "advancedFeaturesEnabled",
                        value: "\(advancedFeaturesEnabled)",
                        valueColor: advancedFeaturesEnabled ? .green : .red
                    )
                    
                    Divider()
                    
                    ParameterRow(
                        name: "userExperienceLevel",
                        value: "\(experienceLevel)",
                        valueColor: .blue
                    )
                    
                    Divider()
                    
                    ParameterRow(
                        name: "currentHour",
                        value: "\(currentHour)",
                        valueColor: .orange
                    )
                    
                    Divider()
                    
                    ParameterRow(
                        name: "isWeekday",
                        value: "\(isWeekday)",
                        valueColor: isWeekday ? .green : .purple
                    )
                    
                    Divider()
                    
                    ParameterRow(
                        name: "daysSinceInstall",
                        value: "\(daysSinceInstall)",
                        valueColor: .indigo
                    )
                }
            }
        }
    }
    
    // MARK: - 활성화된 조건부 팁 섹션
    
    private var activeConditionalTipsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader("조건부 팁 표시", subtitle: "현재 조건에 맞는 팁")
            
            // 프로 사용자 팁
            if isProUser && advancedFeaturesEnabled {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        StatusBadge(text: "프로 전용", color: .blue)
                        Text("프로 사용자 팁")
                            .font(.caption)
                    }
                    
                    TipView(proUserTip)
                        .tipBackground(Color.blue.opacity(0.1))
                }
            }
            
            // 초보 사용자 팁
            if experienceLevel == 0 {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        StatusBadge(text: "초보", color: .green)
                        Text("초보 사용자 팁")
                            .font(.caption)
                    }
                    
                    TipView(beginnerTip) { action in
                        handleBeginnerTipAction(action)
                    }
                    .tipBackground(Color.green.opacity(0.1))
                }
            }
            
            // 아침 팁
            if currentHour >= 6 && currentHour < 12 {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        StatusBadge(text: "아침", color: .orange)
                        Text("아침 인사 팁")
                            .font(.caption)
                    }
                    
                    TipView(morningTip)
                        .tipBackground(Color.orange.opacity(0.1))
                }
            }
            
            // 저녁 팁
            if currentHour >= 18 && currentHour < 22 {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        StatusBadge(text: "저녁", color: .indigo)
                        Text("저녁 리마인더 팁")
                            .font(.caption)
                    }
                    
                    TipView(eveningTip)
                        .tipBackground(Color.indigo.opacity(0.1))
                }
            }
            
            // 주말 팁
            if !isWeekday {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        StatusBadge(text: "주말", color: .pink)
                        Text("주말 특별 팁")
                            .font(.caption)
                    }
                    
                    TipView(weekendTip)
                        .tipBackground(Color.pink.opacity(0.1))
                }
            }
            
            // 장기 사용자 팁
            if daysSinceInstall >= 30 {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        StatusBadge(text: "30일+", color: .purple)
                        Text("장기 사용자 감사 팁")
                            .font(.caption)
                    }
                    
                    TipView(loyalUserTip) { action in
                        handleLoyalUserTipAction(action)
                    }
                    .tipBackground(Color.purple.opacity(0.1))
                }
            }
            
            // 조건 미충족 시
            if !hasAnyActiveTip {
                CardContainer {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.title)
                            .foregroundStyle(.orange)
                        
                        Text("현재 조건에 맞는 팁이 없습니다")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Text("위의 설정을 조절하여 다른 조건의 팁을 확인해보세요.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
            }
        }
    }
    
    // MARK: - 구현 패턴 섹션
    
    private var implementationPatternsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader("구현 패턴", subtitle: "조건부 규칙 작성 방법")
            
            // 단일 조건
            CodeSnippet(
                """
                // 단일 조건
                struct ProUserTip: Tip {
                    var rules: [Rule] {
                        #Rule(UserSettings.$isProUser) { 
                            $0 == true 
                        }
                    }
                }
                """
            )
            
            // 복합 조건
            CodeSnippet(
                """
                // 복합 조건 (AND)
                struct AdvancedTip: Tip {
                    var rules: [Rule] {
                        #Rule(UserSettings.$isProUser) { $0 == true }
                        #Rule(UserSettings.$level) { $0 >= 2 }
                    }
                }
                """
            )
            
            // 시간 기반 조건
            CodeSnippet(
                """
                // 시간 기반 조건
                struct MorningTip: Tip {
                    var rules: [Rule] {
                        #Rule(TimeParams.$currentHour) { hour in
                            hour >= 6 && hour < 12
                        }
                    }
                }
                """
            )
        }
    }
    
    // MARK: - 헬퍼 계산 프로퍼티
    
    private var hasAnyActiveTip: Bool {
        (isProUser && advancedFeaturesEnabled) ||
        experienceLevel == 0 ||
        (currentHour >= 6 && currentHour < 12) ||
        (currentHour >= 18 && currentHour < 22) ||
        !isWeekday ||
        daysSinceInstall >= 30
    }
    
    // MARK: - 헬퍼 메서드
    
    private func handleBeginnerTipAction(_ action: Tip.Action) {
        switch action.id {
        case "start-tutorial":
            tipActionMessage = "튜토리얼을 시작합니다!"
        case "skip":
            tipActionMessage = "튜토리얼을 건너뜁니다."
        default:
            break
        }
        showTipActionAlert = true
        beginnerTip.invalidate(reason: .actionPerformed)
    }
    
    private func handleLoyalUserTipAction(_ action: Tip.Action) {
        if action.id == "claim" {
            tipActionMessage = "특별 테마를 받았습니다! 🎁"
            showTipActionAlert = true
            loyalUserTip.invalidate(reason: .actionPerformed)
        }
    }
}

// MARK: - 상태 표시기

struct StatusIndicator: View {
    let title: String
    let isActive: Bool
    let activeColor: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(isActive ? activeColor : .gray)
                .frame(width: 8, height: 8)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(isActive ? .primary : .secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(isActive ? activeColor.opacity(0.1) : Color(.systemGray6))
        )
    }
}

// MARK: - 시간대 표시기

struct TimeZoneIndicator: View {
    let title: String
    let icon: String
    let isActive: Bool
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(isActive ? color : .gray)
            
            Text(title)
                .font(.caption2)
                .foregroundStyle(isActive ? .primary : .secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isActive ? color.opacity(0.1) : Color(.systemGray6))
        )
        .overlay {
            if isActive {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(color, lineWidth: 2)
            }
        }
    }
}

// MARK: - 경험 수준 버튼

struct ExperienceLevelButton: View {
    let title: String
    let icon: String
    let level: Int
    @Binding var currentLevel: Int
    let color: Color
    
    var isSelected: Bool { currentLevel == level }
    
    var body: some View {
        Button {
            currentLevel = level
            UserSettingsParameters.userExperienceLevel = level
        } label: {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title2)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? color.opacity(0.15) : Color(.systemGray6))
            )
            .foregroundStyle(isSelected ? color : .secondary)
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color, lineWidth: 2)
                }
            }
        }
    }
}

// MARK: - 파라미터 행

struct ParameterRow: View {
    let name: String
    let value: String
    let valueColor: Color
    
    var body: some View {
        HStack {
            Text(name)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.system(.caption, design: .monospaced))
                .fontWeight(.semibold)
                .foregroundStyle(valueColor)
        }
    }
}

// MARK: - 프리뷰

#Preview {
    ConditionalTipView()
        .task {
            try? Tips.configure([
                .displayFrequency(.immediate),
                .datastoreLocation(.applicationDefault)
            ])
        }
}
