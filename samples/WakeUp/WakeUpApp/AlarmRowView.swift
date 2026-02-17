// AlarmRowView.swift
// WakeUp - AlarmKit 샘플 프로젝트
// 알람 목록의 개별 행 뷰

import SwiftUI

// MARK: - 알람 행 뷰

/// 알람 목록에서 개별 알람을 표시하는 행
struct AlarmRowView: View {
    
    // MARK: - 속성
    
    /// 표시할 알람
    let alarm: Alarm
    
    /// 토글 액션
    let onToggle: () -> Void
    
    // MARK: - 본문
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            // 시간 및 정보
            VStack(alignment: .leading, spacing: 4) {
                // 시간 표시
                timeDisplay
                
                // 레이블 및 반복 정보
                detailsDisplay
            }
            
            Spacer()
            
            // 활성화 토글
            Toggle("", isOn: .init(
                get: { alarm.isEnabled },
                set: { _ in onToggle() }
            ))
            .labelsHidden()
            .tint(.orange)
        }
        .padding(.vertical, 8)
        .opacity(alarm.isEnabled ? 1.0 : 0.5)
    }
    
    // MARK: - 시간 표시
    
    @ViewBuilder
    private var timeDisplay: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            // 시간
            Text(alarm.formattedTime)
                .font(.system(size: 44, weight: .light, design: .rounded))
                .monospacedDigit()
            
            // AM/PM
            Text(alarm.hour < 12 ? "AM" : "PM")
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - 상세 정보
    
    @ViewBuilder
    private var detailsDisplay: some View {
        HStack(spacing: 8) {
            // 레이블
            Text(alarm.label)
                .font(.subheadline)
                .foregroundStyle(.primary)
            
            // 반복 요일 (있는 경우)
            if !alarm.repeatDays.isEmpty {
                Text("•")
                    .foregroundStyle(.tertiary)
                
                Text(alarm.repeatSummary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            // 사운드 아이콘 (기본이 아닌 경우)
            if alarm.sound != .sunrise {
                Image(systemName: alarm.sound.iconName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // 스누즈 비활성화 표시
            if !alarm.snoozeConfig.isEnabled {
                Image(systemName: "moon.zzz.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - 컴팩트 알람 행

/// 위젯 등에서 사용할 컴팩트한 알람 행
struct CompactAlarmRow: View {
    
    let alarm: Alarm
    
    var body: some View {
        HStack(spacing: 12) {
            // 활성화 상태 인디케이터
            Circle()
                .fill(alarm.isEnabled ? Color.orange : Color.gray.opacity(0.3))
                .frame(width: 8, height: 8)
            
            // 시간
            Text(alarm.formattedTime12Hour)
                .font(.system(.body, design: .rounded))
                .fontWeight(.medium)
            
            Spacer()
            
            // 레이블
            Text(alarm.label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 알람 요약 뷰

/// 알람의 상세 정보를 요약하여 표시
struct AlarmSummaryView: View {
    
    let alarm: Alarm
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 시간
            HStack(alignment: .firstTextBaseline) {
                Text(alarm.formattedTime12Hour)
                    .font(.system(size: 56, weight: .light, design: .rounded))
                
                Spacer()
                
                // 활성화 상태 뱃지
                statusBadge
            }
            
            Divider()
            
            // 상세 정보 그리드
            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
                GridRow {
                    Label("레이블", systemImage: "tag")
                        .foregroundStyle(.secondary)
                    Text(alarm.label)
                }
                
                GridRow {
                    Label("반복", systemImage: "repeat")
                        .foregroundStyle(.secondary)
                    Text(alarm.repeatSummary)
                }
                
                GridRow {
                    Label("사운드", systemImage: alarm.sound.iconName)
                        .foregroundStyle(.secondary)
                    Text(alarm.sound.displayName)
                }
                
                GridRow {
                    Label("스누즈", systemImage: "clock.arrow.circlepath")
                        .foregroundStyle(.secondary)
                    Text(alarm.snoozeConfig.summary)
                }
            }
            .font(.subheadline)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    @ViewBuilder
    private var statusBadge: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(alarm.isEnabled ? Color.green : Color.gray)
                .frame(width: 8, height: 8)
            Text(alarm.isEnabled ? "활성화" : "비활성화")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(.quaternary, in: Capsule())
    }
}

// MARK: - 미리보기

#Preview("알람 행") {
    List {
        AlarmRowView(alarm: .preview) {}
        AlarmRowView(alarm: Alarm(
            hour: 14,
            minute: 30,
            label: "회의",
            isEnabled: false,
            repeatDays: [],
            sound: .radar
        )) {}
        AlarmRowView(alarm: Alarm(
            hour: 22,
            minute: 0,
            label: "취침 준비",
            isEnabled: true,
            repeatDays: .everyday,
            snoozeConfig: .disabled,
            sound: .gentle
        )) {}
    }
}

#Preview("컴팩트 행") {
    List {
        CompactAlarmRow(alarm: .preview)
        CompactAlarmRow(alarm: Alarm(hour: 8, minute: 0, label: "출근", isEnabled: false))
    }
}

#Preview("알람 요약") {
    AlarmSummaryView(alarm: .preview)
        .padding()
}
