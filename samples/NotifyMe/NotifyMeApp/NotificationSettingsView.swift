import SwiftUI
import UserNotifications

// MARK: - 알림 설정 뷰
// 앱의 알림 동작을 세밀하게 제어할 수 있는 설정 화면입니다.
// 사운드, 배지, 배너 스타일, 조용한 시간, 카테고리별 설정 등을 관리합니다.

struct NotificationSettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var authorizationStatus: UNAuthorizationStatus = .authorized
    @State private var showingResetConfirmation = false
    
    var body: some View {
        List {
            // 권한 상태 섹션
            authorizationSection
            
            // 기본 설정 섹션
            basicSettingsSection
            
            // 사운드 설정 섹션
            soundSettingsSection
            
            // 배너 설정 섹션
            bannerSettingsSection
            
            // 조용한 시간 섹션
            quietHoursSection
            
            // 카테고리별 설정 섹션
            categorySettingsSection
            
            // 초기화 섹션
            resetSection
        }
        .navigationTitle("설정")
        .task {
            await checkAuthorizationStatus()
        }
        .confirmationDialog(
            "모든 설정을 초기화하시겠습니까?",
            isPresented: $showingResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("초기화", role: .destructive) {
                settingsManager.resetToDefaults()
            }
        } message: {
            Text("알림 설정이 기본값으로 돌아갑니다.")
        }
    }
    
    // MARK: - 권한 상태 섹션
    
    private var authorizationSection: some View {
        Section {
            HStack {
                Label {
                    Text("알림 권한")
                } icon: {
                    Image(systemName: authorizationStatus == .authorized ? "checkmark.shield.fill" : "exclamationmark.shield")
                        .foregroundStyle(authorizationStatus == .authorized ? .green : .orange)
                }
                
                Spacer()
                
                Text(authorizationStatusText)
                    .foregroundStyle(.secondary)
            }
            
            if authorizationStatus != .authorized {
                Button {
                    openSettings()
                } label: {
                    Label("시스템 설정에서 변경", systemImage: "arrow.up.forward.app")
                }
            }
        } header: {
            Text("권한")
        }
    }
    
    private var authorizationStatusText: String {
        switch authorizationStatus {
        case .authorized: "허용됨"
        case .denied: "거부됨"
        case .notDetermined: "설정 안 됨"
        case .provisional: "임시 허용"
        case .ephemeral: "일시적"
        @unknown default: "알 수 없음"
        }
    }
    
    // MARK: - 기본 설정 섹션
    
    private var basicSettingsSection: some View {
        Section {
            Toggle(isOn: $settingsManager.settings.isEnabled) {
                Label("알림 활성화", systemImage: "bell.fill")
            }
            
            Toggle(isOn: $settingsManager.settings.showBadge) {
                Label("배지 표시", systemImage: "app.badge")
            }
            .disabled(!settingsManager.settings.isEnabled)
            
            Toggle(isOn: $settingsManager.settings.showOnLockScreen) {
                Label("잠금 화면에 표시", systemImage: "lock.rectangle")
            }
            .disabled(!settingsManager.settings.isEnabled)
            
            Toggle(isOn: $settingsManager.settings.showInNotificationCenter) {
                Label("알림 센터에 표시", systemImage: "list.bullet.rectangle")
            }
            .disabled(!settingsManager.settings.isEnabled)
        } header: {
            Text("기본 설정")
        }
    }
    
    // MARK: - 사운드 설정 섹션
    
    private var soundSettingsSection: some View {
        Section {
            Toggle(isOn: $settingsManager.settings.playSound) {
                Label("알림 사운드", systemImage: "speaker.wave.2.fill")
            }
            .disabled(!settingsManager.settings.isEnabled)
            
            if settingsManager.settings.playSound {
                Picker(selection: $settingsManager.settings.soundType) {
                    ForEach(SoundType.allCases, id: \.self) { sound in
                        Label(sound.rawValue, systemImage: sound.symbol)
                            .tag(sound)
                    }
                } label: {
                    Label("사운드 종류", systemImage: "music.note")
                }
                .disabled(!settingsManager.settings.isEnabled)
            }
        } header: {
            Text("사운드")
        } footer: {
            if settingsManager.settings.playSound && settingsManager.settings.soundType != .none {
                Text("선택한 사운드로 알림을 받습니다.")
            }
        }
    }
    
    // MARK: - 배너 설정 섹션
    
    private var bannerSettingsSection: some View {
        Section {
            Picker(selection: $settingsManager.settings.bannerStyle) {
                ForEach(BannerStyle.allCases, id: \.self) { style in
                    VStack(alignment: .leading) {
                        Label(style.rawValue, systemImage: style.symbol)
                    }
                    .tag(style)
                }
            } label: {
                Label("배너 스타일", systemImage: "rectangle.topthird.inset.filled")
            }
            .disabled(!settingsManager.settings.isEnabled)
        } header: {
            Text("배너")
        } footer: {
            Text(settingsManager.settings.bannerStyle.description)
        }
    }
    
    // MARK: - 조용한 시간 섹션
    
    private var quietHoursSection: some View {
        Section {
            Toggle(isOn: $settingsManager.settings.quietHoursEnabled.animation()) {
                Label("조용한 시간", systemImage: "moon.fill")
            }
            .disabled(!settingsManager.settings.isEnabled)
            
            if settingsManager.settings.quietHoursEnabled {
                HStack {
                    Text("시작")
                    Spacer()
                    DatePicker(
                        "",
                        selection: quietHoursStartBinding,
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                }
                .disabled(!settingsManager.settings.isEnabled)
                
                HStack {
                    Text("종료")
                    Spacer()
                    DatePicker(
                        "",
                        selection: quietHoursEndBinding,
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                }
                .disabled(!settingsManager.settings.isEnabled)
            }
        } header: {
            Text("방해 금지")
        } footer: {
            if settingsManager.settings.quietHoursEnabled {
                Text("조용한 시간 동안에는 알림 사운드가 꺼집니다.")
            }
        }
    }
    
    // MARK: - 카테고리별 설정 섹션
    
    private var categorySettingsSection: some View {
        Section {
            ForEach(NotificationCategory.allCases, id: \.self) { category in
                Toggle(isOn: categoryBinding(for: category)) {
                    Label(category.displayName, systemImage: category.symbol)
                        .foregroundStyle(categoryColor(category))
                }
                .disabled(!settingsManager.settings.isEnabled)
            }
        } header: {
            Text("카테고리별 알림")
        } footer: {
            Text("개별 카테고리의 알림을 켜거나 끌 수 있습니다.")
        }
    }
    
    // MARK: - 초기화 섹션
    
    private var resetSection: some View {
        Section {
            Button(role: .destructive) {
                showingResetConfirmation = true
            } label: {
                HStack {
                    Spacer()
                    Label("설정 초기화", systemImage: "arrow.counterclockwise")
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Bindings & Helpers
    
    private var quietHoursStartBinding: Binding<Date> {
        Binding(
            get: {
                var components = DateComponents()
                components.hour = settingsManager.settings.quietHoursStart.hour ?? 22
                components.minute = settingsManager.settings.quietHoursStart.minute ?? 0
                return Calendar.current.date(from: components) ?? Date()
            },
            set: { newDate in
                let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                settingsManager.settings.quietHoursStart = components
            }
        )
    }
    
    private var quietHoursEndBinding: Binding<Date> {
        Binding(
            get: {
                var components = DateComponents()
                components.hour = settingsManager.settings.quietHoursEnd.hour ?? 7
                components.minute = settingsManager.settings.quietHoursEnd.minute ?? 0
                return Calendar.current.date(from: components) ?? Date()
            },
            set: { newDate in
                let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                settingsManager.settings.quietHoursEnd = components
            }
        )
    }
    
    private func categoryBinding(for category: NotificationCategory) -> Binding<Bool> {
        Binding(
            get: {
                settingsManager.settings.categorySettings[category] ?? true
            },
            set: { newValue in
                settingsManager.settings.categorySettings[category] = newValue
            }
        )
    }
    
    private func categoryColor(_ category: NotificationCategory) -> Color {
        switch category {
        case .reminder: .blue
        case .health: .red
        case .work: .purple
        case .social: .green
        case .location: .orange
        }
    }
    
    private func checkAuthorizationStatus() async {
        authorizationStatus = await NotificationService.shared.checkAuthorizationStatus()
    }
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        NotificationSettingsView()
            .environmentObject(SettingsManager.shared)
    }
}
