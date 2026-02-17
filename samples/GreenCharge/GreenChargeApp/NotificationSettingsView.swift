// NotificationSettingsView.swift
// GreenCharge - 알림 설정 화면
// iOS 26 EnergyKit 활용

import SwiftUI

// MARK: - 알림 설정 뷰

/// 청정 에너지 알림 설정 화면
struct NotificationSettingsView: View {
    
    // MARK: - 환경 객체
    
    @Environment(NotificationService.self) private var notificationService
    
    // MARK: - 상태
    
    /// 알림 활성화 여부
    @State private var notificationsEnabled = true
    
    /// 청정 에너지 시간 알림
    @State private var cleanEnergyAlerts = true
    
    /// 최적 충전 시간 알림
    @State private var optimalChargingAlerts = true
    
    /// 일일 요약 알림
    @State private var dailySummary = false
    
    /// 리드 타임 (분)
    @State private var leadTimeMinutes = 30.0
    
    /// 청정도 임계값 (%)
    @State private var cleanThreshold = 70.0
    
    /// 방해 금지 시작 시간
    @State private var quietHoursStart = Calendar.current.date(from: DateComponents(hour: 22)) ?? Date()
    
    /// 방해 금지 종료 시간
    @State private var quietHoursEnd = Calendar.current.date(from: DateComponents(hour: 7)) ?? Date()
    
    /// 방해 금지 활성화
    @State private var quietHoursEnabled = true
    
    // MARK: - Body
    
    var body: some View {
        Form {
            // 알림 상태 섹션
            notificationStatusSection
            
            // 알림 종류 섹션
            if notificationsEnabled {
                notificationTypesSection
                
                // 알림 설정 섹션
                notificationSettingsSection
                
                // 방해 금지 섹션
                quietHoursSection
            }
        }
        .navigationTitle("알림 설정")
        .task {
            await loadSettings()
        }
    }
    
    // MARK: - 섹션
    
    /// 알림 상태 섹션
    private var notificationStatusSection: some View {
        Section {
            Toggle("알림 활성화", isOn: $notificationsEnabled)
                .onChange(of: notificationsEnabled) { _, newValue in
                    if newValue {
                        Task {
                            await notificationService.requestAuthorization()
                        }
                    }
                }
            
            // 권한 상태 표시
            HStack {
                Text("권한 상태")
                Spacer()
                Text(notificationService.authorizationStatus.displayName)
                    .foregroundStyle(notificationService.authorizationStatus.color)
            }
        } header: {
            Text("알림")
        } footer: {
            if notificationService.authorizationStatus == .denied {
                Text("알림을 받으려면 설정 앱에서 알림 권한을 허용해주세요.")
            }
        }
    }
    
    /// 알림 종류 섹션
    private var notificationTypesSection: some View {
        Section("알림 종류") {
            // 청정 에너지 알림
            Toggle(isOn: $cleanEnergyAlerts) {
                VStack(alignment: .leading, spacing: 4) {
                    Label("청정 에너지 시간 알림", systemImage: "leaf.fill")
                    Text("청정 에너지 비율이 높은 시간대가 시작될 때 알림")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // 최적 충전 시간 알림
            Toggle(isOn: $optimalChargingAlerts) {
                VStack(alignment: .leading, spacing: 4) {
                    Label("최적 충전 시간 알림", systemImage: "bolt.fill")
                    Text("오늘의 최적 충전 시간을 미리 알림")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // 일일 요약
            Toggle(isOn: $dailySummary) {
                VStack(alignment: .leading, spacing: 4) {
                    Label("일일 요약", systemImage: "chart.bar.fill")
                    Text("매일 저녁 오늘의 충전 및 절감 현황 요약")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    /// 알림 설정 섹션
    private var notificationSettingsSection: some View {
        Section("알림 설정") {
            // 리드 타임
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("미리 알림 시간")
                    Spacer()
                    Text("\(Int(leadTimeMinutes))분 전")
                        .foregroundStyle(.secondary)
                }
                
                Slider(value: $leadTimeMinutes, in: 5...60, step: 5)
            }
            
            // 청정도 임계값
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("청정도 알림 기준")
                    Spacer()
                    Text("\(Int(cleanThreshold))% 이상")
                        .foregroundStyle(.secondary)
                }
                
                Slider(value: $cleanThreshold, in: 50...90, step: 5)
            }
        }
    }
    
    /// 방해 금지 섹션
    private var quietHoursSection: some View {
        Section {
            Toggle("방해 금지 시간", isOn: $quietHoursEnabled)
            
            if quietHoursEnabled {
                DatePicker("시작", selection: $quietHoursStart, displayedComponents: .hourAndMinute)
                
                DatePicker("종료", selection: $quietHoursEnd, displayedComponents: .hourAndMinute)
            }
        } header: {
            Text("방해 금지")
        } footer: {
            Text("설정한 시간 동안에는 알림을 보내지 않습니다.")
        }
    }
    
    // MARK: - 메서드
    
    /// 설정 로드
    private func loadSettings() async {
        // UserDefaults에서 설정 로드 (구현 생략)
    }
}

// MARK: - 알림 권한 상태 확장

extension NotificationAuthorizationStatus {
    /// 표시 이름
    var displayName: String {
        switch self {
        case .notDetermined: return "미결정"
        case .authorized: return "허용됨"
        case .denied: return "거부됨"
        case .provisional: return "임시 허용"
        }
    }
    
    /// 상태 색상
    var color: Color {
        switch self {
        case .notDetermined: return .secondary
        case .authorized: return .green
        case .denied: return .red
        case .provisional: return .orange
        }
    }
}

// MARK: - 알림 미리보기 카드

/// 알림 미리보기 컴포넌트
struct NotificationPreviewCard: View {
    let title: String
    let body: String
    let time: String
    
    var body: some View {
        HStack(spacing: 12) {
            // 앱 아이콘
            Image(systemName: "bolt.fill")
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(.green.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            // 내용
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("GreenCharge")
                        .font(.caption.bold())
                    
                    Spacer()
                    
                    Text(time)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Text(title)
                    .font(.subheadline.bold())
                
                Text(body)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 2)
    }
}

// MARK: - 알림 테스트 뷰

/// 알림 테스트 및 미리보기
struct NotificationTestView: View {
    @Environment(NotificationService.self) private var notificationService
    
    var body: some View {
        VStack(spacing: 24) {
            Text("알림 미리보기")
                .font(.headline)
            
            // 청정 에너지 알림 예시
            NotificationPreviewCard(
                title: "⚡ 청정 에너지 시간 시작!",
                body: "지금부터 2시간 동안 청정 에너지 비율이 85%입니다. 충전하기 좋은 시간이에요!",
                time: "지금"
            )
            
            // 최적 충전 시간 알림 예시
            NotificationPreviewCard(
                title: "🔋 오늘의 최적 충전 시간",
                body: "오후 2시 ~ 4시가 오늘 가장 좋은 충전 시간입니다. 청정도 92%",
                time: "30분 전"
            )
            
            // 테스트 알림 전송 버튼
            Button {
                Task {
                    await notificationService.sendTestNotification()
                }
            } label: {
                Label("테스트 알림 보내기", systemImage: "bell.badge")
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
        .padding()
        .navigationTitle("알림 테스트")
    }
}

// MARK: - 미리보기

#Preview {
    NavigationStack {
        NotificationSettingsView()
            .environment(NotificationService())
    }
}
