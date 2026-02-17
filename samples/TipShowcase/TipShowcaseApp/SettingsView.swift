import SwiftUI
import TipKit

// MARK: - 설정 뷰
// TipKit 설정 관리, 디버그 도구, API 레퍼런스를 제공합니다.
// Tips.resetDatastore(), Tips.showAllTipsForTesting() 등의 API를 시연합니다.

struct SettingsView: View {
    
    // MARK: - 환경
    
    @EnvironmentObject var configManager: TipConfigurationManager
    @EnvironmentObject var statistics: TipStatistics
    
    // MARK: - 상태
    
    @State private var selectedMode: TipConfigurationMode = .development
    @State private var showResetAlert = false
    @State private var showResetConfirmation = false
    @State private var showTestModeInfo = false
    @State private var showStatistics = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - TipKit 정보
                tipKitInfoSection
                
                // MARK: - 설정 모드
                configurationModeSection
                
                // MARK: - 디버그 도구
                debugToolsSection
                
                // MARK: - 파라미터 관리
                parameterManagementSection
                
                // MARK: - 통계
                statisticsSection
                
                // MARK: - API 레퍼런스
                apiReferenceSection
                
                // MARK: - 앱 정보
                appInfoSection
            }
            .navigationTitle("설정")
            .alert("모든 팁 초기화", isPresented: $showResetAlert) {
                Button("취소", role: .cancel) {}
                Button("초기화", role: .destructive) {
                    performReset()
                }
            } message: {
                Text("모든 팁 데이터가 초기화됩니다. 팁들이 처음 상태로 돌아갑니다.")
            }
            .alert("초기화 완료", isPresented: $showResetConfirmation) {
                Button("확인", role: .cancel) {}
            } message: {
                Text("모든 팁이 성공적으로 초기화되었습니다.")
            }
            .sheet(isPresented: $showTestModeInfo) {
                TestModeInfoSheet()
            }
            .sheet(isPresented: $showStatistics) {
                StatisticsSheet(statistics: statistics)
            }
        }
    }
    
    // MARK: - TipKit 정보 섹션
    
    private var tipKitInfoSection: some View {
        Section {
            InfoRow(
                icon: "info.circle.fill",
                title: "TipKit 버전",
                value: "iOS 17.0+",
                iconColor: .blue
            )
            
            InfoRow(
                icon: "folder.fill",
                title: "데이터 저장 위치",
                value: "앱 기본 위치",
                iconColor: .orange
            )
            
            InfoRow(
                icon: "clock.fill",
                title: "표시 빈도",
                value: configManager.currentMode.displayFrequency.description,
                iconColor: .green
            )
            
            InfoRow(
                icon: "checkmark.circle.fill",
                title: "설정 상태",
                value: configManager.isConfigured ? "완료" : "미완료",
                iconColor: configManager.isConfigured ? .green : .red
            )
        } header: {
            Text("TipKit 정보")
        }
    }
    
    // MARK: - 설정 모드 섹션
    
    private var configurationModeSection: some View {
        Section {
            ForEach(TipConfigurationMode.allCases) { mode in
                Button {
                    applyMode(mode)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: mode.iconName)
                            .foregroundStyle(modeColor(mode))
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(mode.rawValue.capitalized)
                                .foregroundStyle(.primary)
                            
                            Text(mode.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        if configManager.currentMode == mode {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                }
            }
        } header: {
            Text("설정 모드")
        } footer: {
            Text("개발 중에는 'development' 모드를, 프로덕션에서는 'production' 모드를 사용하세요.")
        }
    }
    
    // MARK: - 디버그 도구 섹션
    
    private var debugToolsSection: some View {
        Section {
            // 모든 팁 리셋
            Button(role: .destructive) {
                showResetAlert = true
            } label: {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                        .frame(width: 24)
                    Text("모든 팁 초기화")
                    Spacer()
                }
            }
            
            // 모든 팁 강제 표시
            Button {
                enableTestMode()
            } label: {
                HStack {
                    Image(systemName: "eye.fill")
                        .foregroundStyle(.purple)
                        .frame(width: 24)
                    Text("모든 팁 강제 표시")
                    Spacer()
                    Image(systemName: "info.circle")
                        .foregroundStyle(.secondary)
                }
            }
            
            // 테스트 모드 정보
            Button {
                showTestModeInfo = true
            } label: {
                HStack {
                    Image(systemName: "questionmark.circle.fill")
                        .foregroundStyle(.blue)
                        .frame(width: 24)
                    Text("테스트 모드 설명")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }
            }
            
            // 디버그 정보 출력
            #if DEBUG
            Button {
                printDebugInfo()
            } label: {
                HStack {
                    Image(systemName: "terminal.fill")
                        .foregroundStyle(.green)
                        .frame(width: 24)
                    Text("디버그 정보 출력 (콘솔)")
                    Spacer()
                }
            }
            #endif
        } header: {
            Text("디버그 도구")
        } footer: {
            Text("개발 및 테스트 목적으로 팁 상태를 관리합니다.")
        }
    }
    
    // MARK: - 파라미터 관리 섹션
    
    private var parameterManagementSection: some View {
        Section {
            // 온보딩 파라미터 리셋
            Button {
                OnboardingParameters.reset()
            } label: {
                HStack {
                    Image(systemName: "graduationcap.fill")
                        .foregroundStyle(.green)
                        .frame(width: 24)
                    Text("온보딩 파라미터 리셋")
                    Spacer()
                }
            }
            
            // 기능 발견 파라미터 리셋
            Button {
                FeatureDiscoveryParameters.reset()
            } label: {
                HStack {
                    Image(systemName: "sparkle.magnifyingglass")
                        .foregroundStyle(.orange)
                        .frame(width: 24)
                    Text("기능 발견 파라미터 리셋")
                    Spacer()
                }
            }
            
            // 사용자 설정 파라미터 리셋
            Button {
                UserSettingsParameters.reset()
            } label: {
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundStyle(.blue)
                        .frame(width: 24)
                    Text("사용자 설정 파라미터 리셋")
                    Spacer()
                }
            }
            
            // 시간 기반 파라미터 리셋
            Button {
                TimeBasedParameters.reset()
            } label: {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundStyle(.purple)
                        .frame(width: 24)
                    Text("시간 기반 파라미터 리셋")
                    Spacer()
                }
            }
            
            // 모든 파라미터 리셋
            Button(role: .destructive) {
                TipParametersManager.resetAll()
            } label: {
                HStack {
                    Image(systemName: "trash.fill")
                        .frame(width: 24)
                    Text("모든 파라미터 리셋")
                    Spacer()
                }
            }
        } header: {
            Text("파라미터 관리")
        } footer: {
            Text("@Parameter 값을 초기화합니다. 관련 팁의 규칙이 재평가됩니다.")
        }
    }
    
    // MARK: - 통계 섹션
    
    private var statisticsSection: some View {
        Section {
            HStack {
                Text("총 팁 표시 횟수")
                Spacer()
                Text("\(statistics.totalShowCount)")
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                Text("액션 클릭 횟수")
                Spacer()
                Text("\(statistics.actionClickCount)")
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                Text("닫기 횟수")
                Spacer()
                Text("\(statistics.dismissCount)")
                    .foregroundStyle(.secondary)
            }
            
            Button {
                showStatistics = true
            } label: {
                HStack {
                    Text("상세 통계 보기")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }
            }
            
            Button(role: .destructive) {
                statistics.reset()
            } label: {
                Text("통계 초기화")
            }
        } header: {
            Text("팁 통계")
        }
    }
    
    // MARK: - API 레퍼런스 섹션
    
    private var apiReferenceSection: some View {
        Section {
            NavigationLink {
                TipKitAPIReferenceView()
            } label: {
                HStack {
                    Image(systemName: "book.fill")
                        .foregroundStyle(.blue)
                        .frame(width: 24)
                    Text("TipKit API 레퍼런스")
                }
            }
            
            NavigationLink {
                TipKitBestPracticesView()
            } label: {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                        .frame(width: 24)
                    Text("베스트 프랙티스")
                }
            }
        } header: {
            Text("문서")
        }
    }
    
    // MARK: - 앱 정보 섹션
    
    private var appInfoSection: some View {
        Section {
            InfoRow(
                icon: "app.fill",
                title: "앱 버전",
                value: AppConstants.version,
                iconColor: .blue
            )
            
            InfoRow(
                icon: "hammer.fill",
                title: "빌드 번호",
                value: AppConstants.build,
                iconColor: .orange
            )
            
            InfoRow(
                icon: "iphone",
                title: "최소 iOS 버전",
                value: AppConstants.minimumIOSVersion,
                iconColor: .green
            )
        } header: {
            Text("앱 정보")
        }
    }
    
    // MARK: - 헬퍼 메서드
    
    private func modeColor(_ mode: TipConfigurationMode) -> Color {
        switch mode {
        case .development: return .orange
        case .production: return .green
        case .demo: return .purple
        case .minimal: return .gray
        }
    }
    
    private func applyMode(_ mode: TipConfigurationMode) {
        Task {
            try? await configManager.configure(with: mode)
            selectedMode = mode
        }
    }
    
    private func performReset() {
        Task {
            let success = await configManager.resetAllTips()
            if success {
                TipParametersManager.resetAll()
                showResetConfirmation = true
            }
        }
    }
    
    private func enableTestMode() {
        Tips.showAllTipsForTesting()
    }
    
    private func printDebugInfo() {
        #if DEBUG
        configManager.printDebugInfo()
        TipParametersManager.printDebugInfo()
        print(statistics.summary)
        #endif
    }
}

// MARK: - 정보 행 뷰

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    let iconColor: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(iconColor)
                .frame(width: 24)
            
            Text(title)
            
            Spacer()
            
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - 표시 빈도 설명 확장

extension Tips.ConfigurationOption.DisplayFrequency {
    var description: String {
        switch self {
        case .immediate:
            return "즉시"
        case .hourly:
            return "시간당"
        case .daily:
            return "일간"
        case .weekly:
            return "주간"
        case .monthly:
            return "월간"
        default:
            return "알 수 없음"
        }
    }
}

// MARK: - 테스트 모드 정보 시트

struct TestModeInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // 헤더
                    VStack(spacing: 12) {
                        Image(systemName: "eye.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(.purple)
                        
                        Text("테스트 모드")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top)
                    
                    // 설명
                    VStack(alignment: .leading, spacing: 16) {
                        InfoBlock(
                            title: "Tips.showAllTipsForTesting()",
                            description: "모든 팁의 규칙을 무시하고 강제로 표시합니다. 개발 및 QA 테스트에 유용합니다."
                        )
                        
                        InfoBlock(
                            title: "사용 시기",
                            description: """
                            • UI/UX 검토 시 모든 팁 확인
                            • 스크린샷 촬영
                            • QA 테스트
                            • 팁 디자인 확인
                            """
                        )
                        
                        InfoBlock(
                            title: "주의사항",
                            description: """
                            • 프로덕션에서는 사용하지 마세요
                            • 앱 재시작 시 원래 상태로 복원
                            • 규칙 로직은 테스트되지 않음
                            """
                        )
                    }
                    .padding()
                    
                    // 코드 예제
                    CodeSnippet(
                        """
                        #if DEBUG
                        // 테스트 모드 활성화
                        Tips.showAllTipsForTesting()
                        #endif
                        """
                    )
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("테스트 모드")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - 정보 블록

struct InfoBlock: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 통계 시트

struct StatisticsSheet: View {
    @Environment(\.dismiss) private var dismiss
    let statistics: TipStatistics
    
    var body: some View {
        NavigationStack {
            List {
                Section("전체 통계") {
                    StatRow(title: "총 표시", value: statistics.totalShowCount)
                    StatRow(title: "액션 클릭", value: statistics.actionClickCount)
                    StatRow(title: "닫기", value: statistics.dismissCount)
                }
                
                Section("카테고리별 통계") {
                    ForEach(TipCategory.allCases) { category in
                        StatRow(
                            title: category.displayName,
                            value: statistics.categoryShowCounts[category] ?? 0
                        )
                    }
                }
            }
            .navigationTitle("팁 통계")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - 통계 행

struct StatRow: View {
    let title: String
    let value: Int
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text("\(value)")
                .fontWeight(.semibold)
                .foregroundStyle(.blue)
        }
    }
}

// MARK: - TipKit API 레퍼런스 뷰

struct TipKitAPIReferenceView: View {
    var body: some View {
        List {
            Section("핵심 타입") {
                APIReferenceRow(
                    name: "Tip",
                    description: "팁을 정의하는 프로토콜"
                )
                APIReferenceRow(
                    name: "TipView",
                    description: "팁을 인라인으로 표시하는 뷰"
                )
                APIReferenceRow(
                    name: "Tips.Event",
                    description: "사용자 행동을 추적하는 이벤트"
                )
            }
            
            Section("수정자") {
                APIReferenceRow(
                    name: ".popoverTip()",
                    description: "뷰에 팝오버 팁 연결"
                )
                APIReferenceRow(
                    name: ".tipBackground()",
                    description: "팁 배경 스타일 커스터마이징"
                )
            }
            
            Section("설정") {
                APIReferenceRow(
                    name: "Tips.configure()",
                    description: "TipKit 전역 설정"
                )
                APIReferenceRow(
                    name: "Tips.resetDatastore()",
                    description: "모든 팁 데이터 초기화"
                )
                APIReferenceRow(
                    name: "Tips.showAllTipsForTesting()",
                    description: "테스트용 모든 팁 표시"
                )
            }
            
            Section("규칙") {
                APIReferenceRow(
                    name: "@Parameter",
                    description: "규칙에 사용되는 관찰 가능한 값"
                )
                APIReferenceRow(
                    name: "#Rule",
                    description: "조건부 표시 규칙 매크로"
                )
                APIReferenceRow(
                    name: "MaxDisplayCount",
                    description: "최대 표시 횟수 옵션"
                )
            }
            
            Section("무효화") {
                APIReferenceRow(
                    name: "tip.invalidate(reason:)",
                    description: "팁 프로그래매틱 닫기"
                )
                APIReferenceRow(
                    name: "InvalidationReason",
                    description: "무효화 이유 열거형"
                )
            }
        }
        .navigationTitle("API 레퍼런스")
    }
}

// MARK: - API 레퍼런스 행

struct APIReferenceRow: View {
    let name: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .font(.system(.subheadline, design: .monospaced))
                .fontWeight(.semibold)
            
            Text(description)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 베스트 프랙티스 뷰

struct TipKitBestPracticesView: View {
    var body: some View {
        List {
            Section("팁 설계") {
                BestPracticeRow(
                    icon: "lightbulb.fill",
                    title: "간결하게 유지",
                    description: "팁은 짧고 명확해야 합니다. 한 문장으로 핵심을 전달하세요."
                )
                
                BestPracticeRow(
                    icon: "scope",
                    title: "컨텍스트에 맞게",
                    description: "사용자가 해당 기능을 필요로 할 때 팁을 표시하세요."
                )
                
                BestPracticeRow(
                    icon: "hand.tap.fill",
                    title: "액션 연결",
                    description: "가능하면 팁에서 바로 액션을 수행할 수 있게 하세요."
                )
            }
            
            Section("표시 전략") {
                BestPracticeRow(
                    icon: "clock.fill",
                    title: "적절한 빈도",
                    description: "팁을 너무 자주 표시하면 사용자 경험이 저하됩니다."
                )
                
                BestPracticeRow(
                    icon: "line.3.horizontal.decrease",
                    title: "우선순위 설정",
                    description: "중요한 팁이 먼저 표시되도록 우선순위를 설정하세요."
                )
                
                BestPracticeRow(
                    icon: "person.fill",
                    title: "개인화",
                    description: "사용자의 경험 수준과 행동에 따라 팁을 조절하세요."
                )
            }
            
            Section("기술적 고려사항") {
                BestPracticeRow(
                    icon: "memorychip.fill",
                    title: "성능",
                    description: "팁 규칙은 자주 평가되므로 복잡한 로직은 피하세요."
                )
                
                BestPracticeRow(
                    icon: "testtube.2",
                    title: "테스트",
                    description: "showAllTipsForTesting()으로 모든 팁을 테스트하세요."
                )
                
                BestPracticeRow(
                    icon: "arrow.triangle.2.circlepath",
                    title: "리셋 옵션",
                    description: "사용자가 팁을 다시 볼 수 있는 옵션을 제공하세요."
                )
            }
        }
        .navigationTitle("베스트 프랙티스")
    }
}

// MARK: - 베스트 프랙티스 행

struct BestPracticeRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 프리뷰

#Preview {
    SettingsView()
        .environmentObject(TipConfigurationManager.shared)
        .environmentObject(TipStatistics.shared)
}
