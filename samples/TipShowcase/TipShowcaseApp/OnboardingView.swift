import SwiftUI
import TipKit

// MARK: - 온보딩 뷰
// 순차적 온보딩 시퀀스를 구현합니다.
// @Parameter를 사용하여 각 단계의 완료 상태를 추적하고,
// 이전 단계 완료 시 다음 팁이 자동으로 표시됩니다.

struct OnboardingView: View {
    
    // MARK: - 팁 인스턴스
    
    private let welcomeTip = WelcomeTip()
    private let firstFeatureTip = FirstFeatureTip()
    private let secondFeatureTip = SecondFeatureTip()
    private let thirdFeatureTip = ThirdFeatureTip()
    private let onboardingCompleteTip = OnboardingCompleteTip()
    
    // MARK: - 상태
    
    @State private var currentStep = 0
    @State private var showCompletionCelebration = false
    @State private var tipActionMessage = ""
    @State private var showTipActionAlert = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - 소개 섹션
                    introSection
                    
                    // MARK: - 진행 상황
                    progressSection
                    
                    // MARK: - 온보딩 팁 시퀀스
                    onboardingSequenceSection
                    
                    // MARK: - 시퀀스 제어
                    sequenceControlSection
                    
                    // MARK: - 구현 방법
                    implementationSection
                    
                    // MARK: - 파라미터 상태
                    parameterStateSection
                }
                .padding()
            }
            .navigationTitle("온보딩 시퀀스")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        resetOnboarding()
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
            .overlay {
                if showCompletionCelebration {
                    completionOverlay
                }
            }
        }
    }
    
    // MARK: - 소개 섹션
    
    private var introSection: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                FeatureRow(
                    icon: "graduationcap.fill",
                    title: "온보딩 시퀀스",
                    description: "@Parameter와 #Rule을 사용하여 순차적 팁 시퀀스를 구현합니다.",
                    iconColor: .green
                )
                
                Divider()
                
                Text("""
                온보딩 시퀀스는 사용자가 앱을 처음 사용할 때 주요 기능을 단계별로 소개합니다. 
                각 단계는 이전 단계가 완료되어야 다음 단계로 진행됩니다.
                """)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    // MARK: - 진행 상황 섹션
    
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader("진행 상황", subtitle: "현재 온보딩 진행 상태")
            
            CardContainer {
                VStack(spacing: 20) {
                    // 전체 진행률
                    VStack(spacing: 8) {
                        HStack {
                            Text("전체 진행률")
                                .font(.subheadline)
                            Spacer()
                            Text("\(Int(OnboardingParameters.progress * 100))%")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(
                                    OnboardingParameters.progress >= 1.0 ? .green : .blue
                                )
                        }
                        
                        ProgressView(value: OnboardingParameters.progress)
                            .tint(OnboardingParameters.progress >= 1.0 ? .green : .blue)
                    }
                    
                    // 단계별 상태
                    HStack(spacing: 8) {
                        ForEach(0..<5) { index in
                            OnboardingStepIndicator(
                                step: index + 1,
                                isCompleted: isStepCompleted(index),
                                isCurrent: currentStep == index
                            )
                            
                            if index < 4 {
                                Rectangle()
                                    .fill(isStepCompleted(index) ? Color.green : Color.gray.opacity(0.3))
                                    .frame(height: 2)
                            }
                        }
                    }
                    
                    // 현재 단계 설명
                    VStack(spacing: 4) {
                        Text(currentStepTitle)
                            .font(.headline)
                        
                        Text(currentStepDescription)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
            }
        }
    }
    
    // MARK: - 온보딩 시퀀스 섹션
    
    private var onboardingSequenceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader("팁 시퀀스", subtitle: "단계별 팁이 순차적으로 표시됩니다")
            
            // 단계 1: 환영 팁
            OnboardingStepCard(
                step: 1,
                title: "환영 메시지",
                isActive: currentStep == 0,
                isCompleted: OnboardingParameters.hasSeenWelcome
            ) {
                TipView(welcomeTip)
                    .tipBackground(Color.blue.opacity(0.1))
            } actionButton: {
                Button("다음 단계로") {
                    completeStep(0)
                }
                .buttonStyle(.borderedProminent)
                .disabled(OnboardingParameters.hasSeenWelcome)
            }
            
            // 단계 2: 첫 번째 기능
            OnboardingStepCard(
                step: 2,
                title: "즐겨찾기 기능",
                isActive: currentStep == 1,
                isCompleted: OnboardingParameters.hasSeenFirstFeature
            ) {
                TipView(firstFeatureTip) { action in
                    handleFirstFeatureTipAction(action)
                }
                .tipBackground(Color.orange.opacity(0.1))
            } actionButton: {
                Button("즐겨찾기 해보기") {
                    completeStep(1)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .disabled(!OnboardingParameters.hasSeenWelcome || OnboardingParameters.hasSeenFirstFeature)
            }
            
            // 단계 3: 두 번째 기능
            OnboardingStepCard(
                step: 3,
                title: "공유 기능",
                isActive: currentStep == 2,
                isCompleted: OnboardingParameters.hasSeenSecondFeature
            ) {
                TipView(secondFeatureTip)
                    .tipBackground(Color.pink.opacity(0.1))
            } actionButton: {
                Button("공유 해보기") {
                    completeStep(2)
                }
                .buttonStyle(.borderedProminent)
                .tint(.pink)
                .disabled(!OnboardingParameters.hasSeenFirstFeature || OnboardingParameters.hasSeenSecondFeature)
            }
            
            // 단계 4: 세 번째 기능
            OnboardingStepCard(
                step: 4,
                title: "검색 기능",
                isActive: currentStep == 3,
                isCompleted: OnboardingParameters.hasSeenThirdFeature
            ) {
                TipView(thirdFeatureTip)
                    .tipBackground(Color.purple.opacity(0.1))
            } actionButton: {
                Button("검색 해보기") {
                    completeStep(3)
                }
                .buttonStyle(.borderedProminent)
                .tint(.purple)
                .disabled(!OnboardingParameters.hasSeenSecondFeature || OnboardingParameters.hasSeenThirdFeature)
            }
            
            // 단계 5: 완료
            OnboardingStepCard(
                step: 5,
                title: "온보딩 완료",
                isActive: currentStep == 4,
                isCompleted: OnboardingParameters.hasCompletedOnboarding
            ) {
                TipView(onboardingCompleteTip) { action in
                    handleCompleteTipAction(action)
                }
                .tipBackground(Color.green.opacity(0.1))
            } actionButton: {
                Button("완료하기") {
                    completeOnboarding()
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .disabled(!OnboardingParameters.hasSeenThirdFeature || OnboardingParameters.hasCompletedOnboarding)
            }
        }
    }
    
    // MARK: - 시퀀스 제어 섹션
    
    private var sequenceControlSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader("시퀀스 제어", subtitle: "온보딩 상태 관리")
            
            CardContainer {
                VStack(spacing: 16) {
                    // 전체 리셋
                    Button {
                        resetOnboarding()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("온보딩 처음부터 다시 시작")
                        }
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .foregroundStyle(.red)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    // 건너뛰기
                    Button {
                        skipOnboarding()
                    } label: {
                        HStack {
                            Image(systemName: "forward.fill")
                            Text("온보딩 건너뛰기 (전체 완료)")
                        }
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .foregroundStyle(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .disabled(OnboardingParameters.hasCompletedOnboarding)
                }
            }
        }
    }
    
    // MARK: - 구현 방법 섹션
    
    private var implementationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader("구현 방법", subtitle: "@Parameter 기반 시퀀스")
            
            CodeSnippet(
                """
                // 파라미터 정의
                struct OnboardingParameters {
                    @Parameter
                    static var hasSeenWelcome: Bool = false
                    
                    @Parameter
                    static var hasSeenFirstFeature: Bool = false
                }
                
                // 팁 정의 (순차적 규칙)
                struct FirstFeatureTip: Tip {
                    var rules: [Rule] {
                        // 환영 팁을 봐야 표시됨
                        #Rule(OnboardingParameters.$hasSeenWelcome) { 
                            $0 == true 
                        }
                        // 이 팁은 아직 안 봤어야 함
                        #Rule(OnboardingParameters.$hasSeenFirstFeature) { 
                            $0 == false 
                        }
                    }
                }
                """
            )
        }
    }
    
    // MARK: - 파라미터 상태 섹션
    
    private var parameterStateSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader("파라미터 상태", subtitle: "현재 @Parameter 값")
            
            CardContainer {
                VStack(alignment: .leading, spacing: 12) {
                    ParameterStateRow(
                        name: "hasSeenWelcome",
                        value: OnboardingParameters.hasSeenWelcome
                    )
                    
                    Divider()
                    
                    ParameterStateRow(
                        name: "hasSeenFirstFeature",
                        value: OnboardingParameters.hasSeenFirstFeature
                    )
                    
                    Divider()
                    
                    ParameterStateRow(
                        name: "hasSeenSecondFeature",
                        value: OnboardingParameters.hasSeenSecondFeature
                    )
                    
                    Divider()
                    
                    ParameterStateRow(
                        name: "hasSeenThirdFeature",
                        value: OnboardingParameters.hasSeenThirdFeature
                    )
                    
                    Divider()
                    
                    ParameterStateRow(
                        name: "hasCompletedOnboarding",
                        value: OnboardingParameters.hasCompletedOnboarding
                    )
                }
            }
        }
    }
    
    // MARK: - 완료 오버레이
    
    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: "party.popper.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.yellow)
                
                Text("온보딩 완료! 🎉")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                Text("이제 앱의 모든 기능을 자유롭게 사용하세요.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                
                Button("시작하기") {
                    withAnimation {
                        showCompletionCelebration = false
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
            .padding(40)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .padding()
        }
        .transition(.opacity)
    }
    
    // MARK: - 헬퍼 계산 프로퍼티
    
    private var currentStepTitle: String {
        switch currentStep {
        case 0: return "환영합니다!"
        case 1: return "즐겨찾기 기능"
        case 2: return "공유 기능"
        case 3: return "검색 기능"
        case 4: return "준비 완료!"
        default: return "온보딩 완료"
        }
    }
    
    private var currentStepDescription: String {
        switch currentStep {
        case 0: return "TipShowcase 앱을 시작합니다."
        case 1: return "좋아하는 항목을 즐겨찾기에 추가하세요."
        case 2: return "콘텐츠를 친구와 공유하세요."
        case 3: return "원하는 것을 빠르게 찾아보세요."
        case 4: return "모든 기본 기능을 배웠습니다!"
        default: return "앱을 자유롭게 사용하세요."
        }
    }
    
    // MARK: - 헬퍼 메서드
    
    private func isStepCompleted(_ index: Int) -> Bool {
        switch index {
        case 0: return OnboardingParameters.hasSeenWelcome
        case 1: return OnboardingParameters.hasSeenFirstFeature
        case 2: return OnboardingParameters.hasSeenSecondFeature
        case 3: return OnboardingParameters.hasSeenThirdFeature
        case 4: return OnboardingParameters.hasCompletedOnboarding
        default: return false
        }
    }
    
    private func completeStep(_ step: Int) {
        switch step {
        case 0:
            OnboardingParameters.hasSeenWelcome = true
            welcomeTip.invalidate(reason: .actionPerformed)
            
        case 1:
            OnboardingParameters.hasSeenFirstFeature = true
            firstFeatureTip.invalidate(reason: .actionPerformed)
            
        case 2:
            OnboardingParameters.hasSeenSecondFeature = true
            secondFeatureTip.invalidate(reason: .actionPerformed)
            
        case 3:
            OnboardingParameters.hasSeenThirdFeature = true
            thirdFeatureTip.invalidate(reason: .actionPerformed)
            
        default:
            break
        }
        
        // 다음 단계로 이동
        currentStep = step + 1
        
        // 이벤트 기록
        Task {
            await TipEventRecorder.recordOnboardingStepCompleted(step: step + 1)
        }
    }
    
    private func completeOnboarding() {
        OnboardingParameters.hasCompletedOnboarding = true
        onboardingCompleteTip.invalidate(reason: .actionPerformed)
        currentStep = 5
        
        // 축하 화면 표시
        withAnimation(.spring()) {
            showCompletionCelebration = true
        }
        
        // 이벤트 기록
        Task {
            await TipEventRecorder.recordOnboardingCompleted()
        }
        
        // 팁 그룹 전환
        TipGroupManager.shared.completeOnboarding()
    }
    
    private func resetOnboarding() {
        OnboardingParameters.reset()
        currentStep = 0
        showCompletionCelebration = false
    }
    
    private func skipOnboarding() {
        OnboardingParameters.hasSeenWelcome = true
        OnboardingParameters.hasSeenFirstFeature = true
        OnboardingParameters.hasSeenSecondFeature = true
        OnboardingParameters.hasSeenThirdFeature = true
        completeOnboarding()
    }
    
    private func handleFirstFeatureTipAction(_ action: Tip.Action) {
        switch action.id {
        case "try-now":
            completeStep(1)
        case "later":
            tipActionMessage = "나중에 즐겨찾기 기능을 사용해보세요!"
            showTipActionAlert = true
        default:
            break
        }
    }
    
    private func handleCompleteTipAction(_ action: Tip.Action) {
        if action.id == "complete" {
            completeOnboarding()
        }
    }
}

// MARK: - 온보딩 단계 표시기

struct OnboardingStepIndicator: View {
    let step: Int
    let isCompleted: Bool
    let isCurrent: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor)
                .frame(width: 36, height: 36)
            
            if isCompleted {
                Image(systemName: "checkmark")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            } else {
                Text("\(step)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(isCurrent ? .white : .secondary)
            }
        }
        .overlay {
            if isCurrent && !isCompleted {
                Circle()
                    .stroke(Color.blue, lineWidth: 2)
                    .frame(width: 42, height: 42)
            }
        }
    }
    
    private var backgroundColor: Color {
        if isCompleted {
            return .green
        } else if isCurrent {
            return .blue
        } else {
            return Color(.systemGray5)
        }
    }
}

// MARK: - 온보딩 단계 카드

struct OnboardingStepCard<TipContent: View, ActionButton: View>: View {
    let step: Int
    let title: String
    let isActive: Bool
    let isCompleted: Bool
    let tipContent: () -> TipContent
    let actionButton: () -> ActionButton
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 헤더
            HStack {
                Text("단계 \(step)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(isActive ? .blue : .secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        isActive ? Color.blue.opacity(0.1) : Color(.systemGray6)
                    )
                    .clipShape(Capsule())
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }
            
            // 팁 콘텐츠
            tipContent()
            
            // 액션 버튼
            HStack {
                Spacer()
                actionButton()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isActive ? Color(.systemBackground) : Color(.secondarySystemBackground))
                .shadow(
                    color: isActive ? Color.blue.opacity(0.2) : .clear,
                    radius: 8
                )
        )
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isActive ? Color.blue.opacity(0.5) : Color.clear,
                    lineWidth: 2
                )
        }
        .opacity(isCompleted && !isActive ? 0.6 : 1.0)
    }
}

// MARK: - 파라미터 상태 행

struct ParameterStateRow: View {
    let name: String
    let value: Bool
    
    var body: some View {
        HStack {
            Text(name)
                .font(.system(.caption, design: .monospaced))
            
            Spacer()
            
            Text(value ? "true" : "false")
                .font(.system(.caption, design: .monospaced))
                .fontWeight(.semibold)
                .foregroundStyle(value ? .green : .red)
        }
    }
}

// MARK: - 프리뷰

#Preview {
    OnboardingView()
        .task {
            try? Tips.configure([
                .displayFrequency(.immediate),
                .datastoreLocation(.applicationDefault)
            ])
        }
}
