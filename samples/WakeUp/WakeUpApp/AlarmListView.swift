// AlarmListView.swift
// WakeUp - AlarmKit 샘플 프로젝트
// 알람 목록 화면

import SwiftUI
import AlarmKit

// MARK: - 알람 목록 뷰

/// 등록된 알람 목록을 표시하는 메인 화면
struct AlarmListView: View {
    
    // MARK: - 환경 및 상태
    
    @Environment(AlarmManager.self) private var alarmManager
    
    /// 편집 중인 알람 (nil이면 새 알람)
    @State private var editingAlarm: Alarm?
    
    /// 알람 편집 시트 표시 여부
    @State private var showingEditSheet: Bool = false
    
    /// 알람 추가 시트 표시 여부
    @State private var showingAddSheet: Bool = false
    
    /// 설정 화면 표시 여부
    @State private var showingSettings: Bool = false
    
    // MARK: - 본문
    
    var body: some View {
        NavigationStack {
            Group {
                if alarmManager.alarms.isEmpty {
                    emptyStateView
                } else {
                    alarmListContent
                }
            }
            .navigationTitle("알람")
            .toolbar {
                toolbarContent
            }
            .sheet(isPresented: $showingAddSheet) {
                AlarmEditView(alarm: nil) { newAlarm in
                    Task {
                        await alarmManager.addAlarm(newAlarm)
                    }
                }
            }
            .sheet(item: $editingAlarm) { alarm in
                AlarmEditView(alarm: alarm) { updatedAlarm in
                    Task {
                        await alarmManager.updateAlarm(updatedAlarm)
                    }
                }
            }
            .alert("오류", isPresented: .init(
                get: { alarmManager.errorMessage != nil },
                set: { if !$0 { alarmManager.clearError() } }
            )) {
                Button("확인", role: .cancel) {}
            } message: {
                if let message = alarmManager.errorMessage {
                    Text(message)
                }
            }
        }
    }
    
    // MARK: - 알람 목록
    
    /// 알람 목록 컨텐츠
    @ViewBuilder
    private var alarmListContent: some View {
        List {
            // 다음 알람 섹션
            if let nextAlarm = alarmManager.nextAlarm {
                Section {
                    NextAlarmCard(alarm: nextAlarm)
                }
            }
            
            // 알람 목록 섹션
            Section {
                ForEach(alarmManager.alarms) { alarm in
                    AlarmRowView(
                        alarm: alarm,
                        onToggle: {
                            Task {
                                await alarmManager.toggleAlarm(alarm)
                            }
                        }
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        editingAlarm = alarm
                    }
                }
                .onDelete { offsets in
                    Task {
                        await alarmManager.deleteAlarms(at: offsets)
                    }
                }
            } header: {
                Text("모든 알람 (\(alarmManager.alarms.count))")
            }
        }
        .listStyle(.insetGrouped)
        .refreshable {
            await alarmManager.loadAlarms()
        }
    }
    
    // MARK: - 빈 상태
    
    /// 알람이 없을 때 표시되는 뷰
    @ViewBuilder
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("알람 없음", systemImage: "alarm")
        } description: {
            Text("새로운 알람을 추가해보세요")
        } actions: {
            Button {
                showingAddSheet = true
            } label: {
                Text("알람 추가")
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    // MARK: - 툴바
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            if !alarmManager.alarms.isEmpty {
                EditButton()
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showingAddSheet = true
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}

// MARK: - 다음 알람 카드

/// 다음에 울릴 알람을 강조하여 표시하는 카드
struct NextAlarmCard: View {
    let alarm: Alarm
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 헤더
            HStack {
                Image(systemName: "alarm.fill")
                    .foregroundStyle(.orange)
                Text("다음 알람")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            // 시간
            Text(alarm.formattedTime12Hour)
                .font(.system(size: 42, weight: .light, design: .rounded))
            
            // 상세 정보
            HStack {
                // 레이블
                Label(alarm.label, systemImage: "tag.fill")
                    .font(.subheadline)
                
                Spacer()
                
                // 남은 시간
                if let remaining = alarm.timeUntilNextTrigger {
                    Text(remaining)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            // 반복 요일
            if !alarm.repeatDays.isEmpty {
                Text(alarm.repeatSummary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - 미리보기

#Preview("알람 목록") {
    @Previewable @State var manager = AlarmManager()
    
    AlarmListView()
        .environment(manager)
        .task {
            await manager.loadSampleData()
        }
}

#Preview("빈 목록") {
    @Previewable @State var manager = AlarmManager()
    
    AlarmListView()
        .environment(manager)
}
