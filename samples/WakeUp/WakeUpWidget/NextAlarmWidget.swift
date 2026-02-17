// NextAlarmWidget.swift
// WakeUp - AlarmKit 샘플 프로젝트
// 다음 알람 표시 위젯

import SwiftUI
import WidgetKit
import AppIntents

// MARK: - 위젯 타임라인 항목

/// 위젯에 표시할 데이터를 담는 타임라인 항목
struct NextAlarmEntry: TimelineEntry {
    /// 표시 시각
    let date: Date
    
    /// 다음 알람 정보 (없으면 nil)
    let nextAlarm: AlarmInfo?
    
    /// 활성화된 알람 개수
    let enabledCount: Int
    
    /// 위젯용 알람 정보
    struct AlarmInfo {
        let hour: Int
        let minute: Int
        let label: String
        let triggerDate: Date
        let repeatDays: String
    }
}

// MARK: - 위젯 프로바이더

/// 위젯 타임라인을 제공하는 프로바이더
struct NextAlarmProvider: TimelineProvider {
    
    /// 플레이스홀더 (위젯 갤러리용)
    func placeholder(in context: Context) -> NextAlarmEntry {
        NextAlarmEntry(
            date: .now,
            nextAlarm: .init(
                hour: 7,
                minute: 30,
                label: "기상",
                triggerDate: .now.addingTimeInterval(3600 * 8),
                repeatDays: "평일"
            ),
            enabledCount: 3
        )
    }
    
    /// 스냅샷 (빠른 미리보기용)
    func getSnapshot(in context: Context, completion: @escaping (NextAlarmEntry) -> Void) {
        let entry = placeholder(in: context)
        completion(entry)
    }
    
    /// 타임라인 생성
    func getTimeline(in context: Context, completion: @escaping (Timeline<NextAlarmEntry>) -> Void) {
        // 저장된 알람 데이터 로드
        let alarms = loadAlarms()
        
        // 다음 알람 찾기
        let nextAlarm = findNextAlarm(from: alarms)
        let enabledCount = alarms.filter { $0.isEnabled }.count
        
        let entry = NextAlarmEntry(
            date: .now,
            nextAlarm: nextAlarm.map { alarm in
                .init(
                    hour: alarm.hour,
                    minute: alarm.minute,
                    label: alarm.label,
                    triggerDate: alarm.nextTriggerDate ?? .now,
                    repeatDays: alarm.repeatSummary
                )
            },
            enabledCount: enabledCount
        )
        
        // 다음 업데이트 시간 계산 (알람 발생 후 또는 1시간 후)
        let nextUpdate: Date
        if let triggerDate = nextAlarm?.nextTriggerDate {
            nextUpdate = triggerDate.addingTimeInterval(60) // 알람 1분 후 업데이트
        } else {
            nextUpdate = .now.addingTimeInterval(3600) // 1시간 후
        }
        
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    // MARK: - 데이터 로드
    
    /// 저장된 알람 목록 로드
    private func loadAlarms() -> [Alarm] {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("alarms.json")
        
        guard let data = try? Data(contentsOf: url) else {
            return []
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return (try? decoder.decode([Alarm].self, from: data)) ?? []
    }
    
    /// 다음에 울릴 알람 찾기
    private func findNextAlarm(from alarms: [Alarm]) -> Alarm? {
        alarms
            .filter { $0.isEnabled }
            .compactMap { alarm -> (Alarm, Date)? in
                guard let date = alarm.nextTriggerDate else { return nil }
                return (alarm, date)
            }
            .min { $0.1 < $1.1 }
            .map { $0.0 }
    }
}

// MARK: - 위젯 뷰

/// 다음 알람 위젯 메인 뷰
struct NextAlarmWidgetView: View {
    
    let entry: NextAlarmEntry
    
    @Environment(\.widgetFamily) private var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            smallWidget
        case .systemMedium:
            mediumWidget
        case .accessoryRectangular:
            rectangularAccessory
        case .accessoryCircular:
            circularAccessory
        default:
            smallWidget
        }
    }
    
    // MARK: - 작은 위젯
    
    @ViewBuilder
    private var smallWidget: some View {
        if let alarm = entry.nextAlarm {
            VStack(alignment: .leading, spacing: 8) {
                // 헤더
                HStack {
                    Image(systemName: "alarm.fill")
                        .foregroundStyle(.orange)
                    Text("다음 알람")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // 시간
                Text(formattedTime(hour: alarm.hour, minute: alarm.minute))
                    .font(.system(size: 32, weight: .light, design: .rounded))
                    .minimumScaleFactor(0.8)
                
                // 레이블
                Text(alarm.label)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                // 남은 시간
                Text(timeUntil(alarm.triggerDate))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .containerBackground(.fill.tertiary, for: .widget)
        } else {
            emptyState
        }
    }
    
    // MARK: - 중간 위젯
    
    @ViewBuilder
    private var mediumWidget: some View {
        if let alarm = entry.nextAlarm {
            HStack(spacing: 16) {
                // 왼쪽: 시간 정보
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "alarm.fill")
                            .foregroundStyle(.orange)
                        Text("다음 알람")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text(formattedTime(hour: alarm.hour, minute: alarm.minute))
                        .font(.system(size: 44, weight: .light, design: .rounded))
                    
                    Text(alarm.label)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // 오른쪽: 추가 정보
                VStack(alignment: .trailing, spacing: 12) {
                    // 남은 시간
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(timeUntil(alarm.triggerDate))
                            .font(.headline)
                        Text("후 알람")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    // 반복 정보
                    if !alarm.repeatDays.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "repeat")
                                .font(.caption2)
                            Text(alarm.repeatDays)
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                    }
                    
                    // 활성화된 알람 수
                    Text("총 \(entry.enabledCount)개 알람")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .containerBackground(.fill.tertiary, for: .widget)
        } else {
            emptyState
        }
    }
    
    // MARK: - 잠금화면 사각형 위젯
    
    @ViewBuilder
    private var rectangularAccessory: some View {
        if let alarm = entry.nextAlarm {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(formattedTime(hour: alarm.hour, minute: alarm.minute))
                        .font(.headline)
                        .widgetAccentable()
                    
                    Text(alarm.label)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text(timeUntil(alarm.triggerDate))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        } else {
            Text("알람 없음")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - 잠금화면 원형 위젯
    
    @ViewBuilder
    private var circularAccessory: some View {
        if let alarm = entry.nextAlarm {
            VStack(spacing: 2) {
                Image(systemName: "alarm.fill")
                    .font(.caption)
                    .widgetAccentable()
                
                Text(formattedTime(hour: alarm.hour, minute: alarm.minute))
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.medium)
            }
        } else {
            Image(systemName: "alarm")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - 빈 상태
    
    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "alarm")
                .font(.title)
                .foregroundStyle(.secondary)
            
            Text("알람 없음")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text("앱에서 알람을 추가하세요")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(.fill.tertiary, for: .widget)
    }
    
    // MARK: - 헬퍼
    
    /// 시간 포맷팅
    private func formattedTime(hour: Int, minute: Int) -> String {
        let period = hour < 12 ? "오전" : "오후"
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        return "\(period) \(displayHour):\(String(format: "%02d", minute))"
    }
    
    /// 남은 시간 계산
    private func timeUntil(_ date: Date) -> String {
        let interval = date.timeIntervalSince(.now)
        guard interval > 0 else { return "곧 울림" }
        
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)시간 \(minutes)분"
        } else if minutes > 0 {
            return "\(minutes)분"
        } else {
            return "1분 미만"
        }
    }
}

// MARK: - 위젯 정의

/// 다음 알람 위젯
@main
struct NextAlarmWidget: Widget {
    
    let kind: String = "NextAlarmWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NextAlarmProvider()) { entry in
            NextAlarmWidgetView(entry: entry)
        }
        .configurationDisplayName("다음 알람")
        .description("다음에 울릴 알람을 표시합니다")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryRectangular,
            .accessoryCircular
        ])
    }
}

// MARK: - 위젯 새로고침 인텐트

/// 위젯 새로고침 앱 인텐트
struct RefreshAlarmWidget: AppIntent {
    static var title: LocalizedStringResource = "알람 위젯 새로고침"
    static var description = IntentDescription("알람 위젯을 최신 상태로 업데이트합니다")
    
    func perform() async throws -> some IntentResult {
        WidgetCenter.shared.reloadTimelines(ofKind: "NextAlarmWidget")
        return .result()
    }
}

// MARK: - 미리보기

#Preview("작은 위젯", as: .systemSmall) {
    NextAlarmWidget()
} timeline: {
    NextAlarmEntry(
        date: .now,
        nextAlarm: .init(
            hour: 7,
            minute: 30,
            label: "기상",
            triggerDate: .now.addingTimeInterval(3600 * 8),
            repeatDays: "평일"
        ),
        enabledCount: 3
    )
    NextAlarmEntry(date: .now, nextAlarm: nil, enabledCount: 0)
}

#Preview("중간 위젯", as: .systemMedium) {
    NextAlarmWidget()
} timeline: {
    NextAlarmEntry(
        date: .now,
        nextAlarm: .init(
            hour: 6,
            minute: 0,
            label: "아침 운동",
            triggerDate: .now.addingTimeInterval(3600 * 5),
            repeatDays: "월, 수, 금"
        ),
        enabledCount: 5
    )
}

#Preview("잠금화면", as: .accessoryRectangular) {
    NextAlarmWidget()
} timeline: {
    NextAlarmEntry(
        date: .now,
        nextAlarm: .init(
            hour: 7,
            minute: 0,
            label: "기상",
            triggerDate: .now.addingTimeInterval(3600 * 6),
            repeatDays: ""
        ),
        enabledCount: 2
    )
}
