// AlarmEditView.swift
// WakeUp - AlarmKit 샘플 프로젝트
// 알람 생성/편집 화면

import SwiftUI

// MARK: - 알람 편집 뷰

/// 새 알람 생성 또는 기존 알람 편집을 위한 시트
struct AlarmEditView: View {
    
    // MARK: - 환경 및 상태
    
    @Environment(\.dismiss) private var dismiss
    
    /// 편집 중인 알람 (nil이면 새 알람 생성)
    private let originalAlarm: Alarm?
    
    /// 저장 콜백
    private let onSave: (Alarm) -> Void
    
    /// 현재 편집 중인 알람 상태
    @State private var alarm: Alarm
    
    /// 시간 선택용 Date
    @State private var selectedTime: Date
    
    /// 사운드 피커 표시 여부
    @State private var showingSoundPicker: Bool = false
    
    /// 스누즈 설정 시트 표시 여부
    @State private var showingSnoozeSettings: Bool = false
    
    /// 반복 요일 선택 시트 표시 여부
    @State private var showingRepeatPicker: Bool = false
    
    // MARK: - 초기화
    
    init(alarm: Alarm?, onSave: @escaping (Alarm) -> Void) {
        self.originalAlarm = alarm
        self.onSave = onSave
        
        let initialAlarm = alarm ?? Alarm()
        _alarm = State(initialValue: initialAlarm)
        
        // 시간을 Date로 변환
        var components = Calendar.current.dateComponents([.year, .month, .day], from: .now)
        components.hour = initialAlarm.hour
        components.minute = initialAlarm.minute
        _selectedTime = State(initialValue: Calendar.current.date(from: components) ?? .now)
    }
    
    // MARK: - 본문
    
    var body: some View {
        NavigationStack {
            Form {
                // 시간 선택 섹션
                timePickerSection
                
                // 기본 설정 섹션
                basicSettingsSection
                
                // 반복 설정 섹션
                repeatSection
                
                // 사운드 및 스누즈 섹션
                soundAndSnoozeSection
            }
            .navigationTitle(originalAlarm == nil ? "알람 추가" : "알람 편집")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        saveAlarm()
                    }
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showingSoundPicker) {
                SoundPickerView(selectedSound: $alarm.sound)
            }
            .sheet(isPresented: $showingSnoozeSettings) {
                SnoozeSettingsView(configuration: $alarm.snoozeConfig)
            }
            .sheet(isPresented: $showingRepeatPicker) {
                RepeatDaysPicker(selectedDays: $alarm.repeatDays)
            }
        }
    }
    
    // MARK: - 시간 선택 섹션
    
    @ViewBuilder
    private var timePickerSection: some View {
        Section {
            DatePicker(
                "알람 시간",
                selection: $selectedTime,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .frame(maxWidth: .infinity)
            .onChange(of: selectedTime) { _, newValue in
                let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                alarm.hour = components.hour ?? 0
                alarm.minute = components.minute ?? 0
            }
        }
    }
    
    // MARK: - 기본 설정 섹션
    
    @ViewBuilder
    private var basicSettingsSection: some View {
        Section {
            // 레이블 입력
            HStack {
                Label("레이블", systemImage: "tag")
                Spacer()
                TextField("알람", text: $alarm.label)
                    .multilineTextAlignment(.trailing)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    // MARK: - 반복 설정 섹션
    
    @ViewBuilder
    private var repeatSection: some View {
        Section {
            Button {
                showingRepeatPicker = true
            } label: {
                HStack {
                    Label("반복", systemImage: "repeat")
                    Spacer()
                    Text(alarm.repeatSummary)
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .tint(.primary)
        } footer: {
            if !alarm.repeatDays.isEmpty {
                Text(alarm.repeatDays.detailedSummary)
            }
        }
    }
    
    // MARK: - 사운드 및 스누즈 섹션
    
    @ViewBuilder
    private var soundAndSnoozeSection: some View {
        Section {
            // 사운드 선택
            Button {
                showingSoundPicker = true
            } label: {
                HStack {
                    Label("사운드", systemImage: alarm.sound.iconName)
                    Spacer()
                    Text(alarm.sound.displayName)
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .tint(.primary)
            
            // 스누즈 설정
            Button {
                showingSnoozeSettings = true
            } label: {
                HStack {
                    Label("스누즈", systemImage: "clock.arrow.circlepath")
                    Spacer()
                    Text(alarm.snoozeConfig.summary)
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .tint(.primary)
        }
    }
    
    // MARK: - 저장
    
    private func saveAlarm() {
        onSave(alarm)
        dismiss()
    }
}

// MARK: - 반복 요일 선택 뷰

/// 반복할 요일을 선택하는 시트
struct RepeatDaysPicker: View {
    
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDays: WeekdaySet
    
    var body: some View {
        NavigationStack {
            List {
                // 프리셋 섹션
                Section("빠른 선택") {
                    presetButton("매일", days: .everyday)
                    presetButton("평일", days: .weekdays)
                    presetButton("주말", days: .weekends)
                    presetButton("반복 안 함", days: [])
                }
                
                // 개별 요일 선택
                Section("요일 선택") {
                    ForEach(Weekday.allCases) { weekday in
                        Button {
                            selectedDays.toggle(weekday)
                        } label: {
                            HStack {
                                Text(weekday.fullName)
                                Spacer()
                                if selectedDays.contains(weekday) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.orange)
                                }
                            }
                        }
                        .tint(.primary)
                    }
                }
            }
            .navigationTitle("반복")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    @ViewBuilder
    private func presetButton(_ title: String, days: WeekdaySet) -> some View {
        Button {
            selectedDays = days
        } label: {
            HStack {
                Text(title)
                Spacer()
                if selectedDays == days {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.orange)
                }
            }
        }
        .tint(.primary)
    }
}

// MARK: - 스누즈 설정 뷰

/// 스누즈 동작을 설정하는 시트
struct SnoozeSettingsView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Binding var configuration: SnoozeConfiguration
    
    var body: some View {
        NavigationStack {
            Form {
                // 활성화 토글
                Section {
                    Toggle("스누즈 사용", isOn: $configuration.isEnabled)
                        .tint(.orange)
                }
                
                // 상세 설정
                if configuration.isEnabled {
                    Section("스누즈 간격") {
                        Picker("간격", selection: $configuration.durationMinutes) {
                            ForEach(SnoozeConfiguration.availableDurations, id: \.self) { minutes in
                                Text("\(minutes)분").tag(minutes)
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                    
                    Section("최대 횟수") {
                        Picker("횟수", selection: $configuration.maxCount) {
                            ForEach([1, 2, 3, 5, 10], id: \.self) { count in
                                Text("\(count)회").tag(count)
                            }
                            Text("무제한").tag(Int.max)
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    // 프리셋
                    Section("프리셋") {
                        ForEach([SnoozePreset.standard, .short, .long], id: \.id) { preset in
                            Button {
                                configuration = preset.configuration
                            } label: {
                                HStack {
                                    Image(systemName: preset.iconName)
                                        .frame(width: 24)
                                    VStack(alignment: .leading) {
                                        Text(preset.displayName)
                                        Text(preset.description)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    if SnoozePreset.preset(for: configuration) == preset {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.orange)
                                    }
                                }
                            }
                            .tint(.primary)
                        }
                    }
                }
            }
            .navigationTitle("스누즈 설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - 미리보기

#Preview("새 알람") {
    AlarmEditView(alarm: nil) { _ in }
}

#Preview("알람 편집") {
    AlarmEditView(alarm: .preview) { _ in }
}

#Preview("반복 선택") {
    @Previewable @State var days: WeekdaySet = .weekdays
    RepeatDaysPicker(selectedDays: $days)
}

#Preview("스누즈 설정") {
    @Previewable @State var config = SnoozeConfiguration.default
    SnoozeSettingsView(configuration: $config)
}
