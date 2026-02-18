# AlarmKit AI Reference

> 알람 시계 앱 구현 가이드. 이 문서를 읽고 AlarmKit 코드를 생성할 수 있습니다.

## 개요

AlarmKit은 iOS 18+에서 제공하는 알람 앱 개발 프레임워크입니다.
시스템 알람 앱과 동일한 신뢰성 있는 알람 기능을 제공하며, 배터리 최적화 상태에서도 정확한 시간에 알람이 울립니다.

## 필수 Import

```swift
import AlarmKit
```

## 프로젝트 설정

### 1. Capability 추가
Xcode > Signing & Capabilities > Background Modes > Background processing

### 2. Info.plist

```xml
<!-- 알람 권한 설명 -->
<key>NSAlarmUsageDescription</key>
<string>지정한 시간에 알람을 울리기 위해 필요합니다.</string>
```

## 핵심 구성요소

### 1. AlarmManager

```swift
import AlarmKit

// 알람 매니저 인스턴스
let alarmManager = AlarmManager.shared

// 권한 요청
func requestPermission() async -> Bool {
    await alarmManager.requestAuthorization()
}

// 권한 상태 확인
let status = alarmManager.authorizationStatus
```

### 2. Alarm (알람 생성)

```swift
// 단일 알람
let alarm = Alarm(
    id: UUID(),
    time: DateComponents(hour: 7, minute: 30),
    label: "기상 알람",
    sound: .default,
    isEnabled: true
)

// 반복 알람
let weekdayAlarm = Alarm(
    id: UUID(),
    time: DateComponents(hour: 7, minute: 0),
    label: "출근 알람",
    sound: .custom(named: "morning"),
    repeatDays: [.monday, .tuesday, .wednesday, .thursday, .friday],
    isEnabled: true
)
```

### 3. AlarmSound (알람 소리)

```swift
// 기본 소리
AlarmSound.default

// 시스템 소리
AlarmSound.system(.radar)
AlarmSound.system(.beacon)

// 커스텀 소리 (번들에 포함된 오디오 파일)
AlarmSound.custom(named: "rooster")
```

## 전체 작동 예제

```swift
import SwiftUI
import AlarmKit

// MARK: - Alarm Model (앱 내부용)
struct AlarmItem: Identifiable, Codable {
    let id: UUID
    var hour: Int
    var minute: Int
    var label: String
    var isEnabled: Bool
    var repeatDays: Set<Weekday>
    var soundName: String
    
    var timeString: String {
        String(format: "%02d:%02d", hour, minute)
    }
    
    var repeatDescription: String {
        if repeatDays.isEmpty {
            return "반복 안 함"
        } else if repeatDays.count == 7 {
            return "매일"
        } else if repeatDays == [.monday, .tuesday, .wednesday, .thursday, .friday] {
            return "주중"
        } else if repeatDays == [.saturday, .sunday] {
            return "주말"
        } else {
            return repeatDays.sorted(by: { $0.rawValue < $1.rawValue })
                .map { $0.shortName }
                .joined(separator: ", ")
        }
    }
}

enum Weekday: Int, Codable, CaseIterable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
    
    var shortName: String {
        switch self {
        case .sunday: return "일"
        case .monday: return "월"
        case .tuesday: return "화"
        case .wednesday: return "수"
        case .thursday: return "목"
        case .friday: return "금"
        case .saturday: return "토"
        }
    }
}

// MARK: - Alarm Manager
@Observable
class AlarmViewModel {
    var alarms: [AlarmItem] = []
    var isAuthorized = false
    var showingAddAlarm = false
    
    private let alarmManager = AlarmManager.shared
    private let userDefaults = UserDefaults.standard
    private let alarmsKey = "savedAlarms"
    
    init() {
        loadAlarms()
        checkAuthorization()
    }
    
    func checkAuthorization() {
        isAuthorized = alarmManager.authorizationStatus == .authorized
    }
    
    func requestAuthorization() async {
        isAuthorized = await alarmManager.requestAuthorization()
    }
    
    // MARK: - CRUD
    func addAlarm(_ alarm: AlarmItem) {
        alarms.append(alarm)
        if alarm.isEnabled {
            scheduleAlarm(alarm)
        }
        saveAlarms()
    }
    
    func updateAlarm(_ alarm: AlarmItem) {
        guard let index = alarms.firstIndex(where: { $0.id == alarm.id }) else { return }
        
        // 기존 알람 취소
        cancelAlarm(alarms[index])
        
        // 새 알람 설정
        alarms[index] = alarm
        if alarm.isEnabled {
            scheduleAlarm(alarm)
        }
        saveAlarms()
    }
    
    func deleteAlarm(_ alarm: AlarmItem) {
        cancelAlarm(alarm)
        alarms.removeAll { $0.id == alarm.id }
        saveAlarms()
    }
    
    func toggleAlarm(_ alarm: AlarmItem) {
        guard let index = alarms.firstIndex(where: { $0.id == alarm.id }) else { return }
        alarms[index].isEnabled.toggle()
        
        if alarms[index].isEnabled {
            scheduleAlarm(alarms[index])
        } else {
            cancelAlarm(alarms[index])
        }
        saveAlarms()
    }
    
    // MARK: - AlarmKit 연동
    private func scheduleAlarm(_ alarm: AlarmItem) {
        Task {
            do {
                let alarmKitAlarm = Alarm(
                    id: alarm.id,
                    time: DateComponents(hour: alarm.hour, minute: alarm.minute),
                    label: alarm.label,
                    sound: alarm.soundName == "default" ? .default : .custom(named: alarm.soundName),
                    repeatDays: Set(alarm.repeatDays.map { AlarmRepeatDay(rawValue: $0.rawValue)! }),
                    isEnabled: true
                )
                
                try await alarmManager.schedule(alarmKitAlarm)
            } catch {
                print("알람 예약 실패: \(error)")
            }
        }
    }
    
    private func cancelAlarm(_ alarm: AlarmItem) {
        Task {
            try? await alarmManager.cancel(alarmWithId: alarm.id)
        }
    }
    
    // MARK: - Persistence
    private func saveAlarms() {
        if let data = try? JSONEncoder().encode(alarms) {
            userDefaults.set(data, forKey: alarmsKey)
        }
    }
    
    private func loadAlarms() {
        if let data = userDefaults.data(forKey: alarmsKey),
           let saved = try? JSONDecoder().decode([AlarmItem].self, from: data) {
            alarms = saved
        }
    }
}

// MARK: - Main View
struct AlarmListView: View {
    @State private var viewModel = AlarmViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if !viewModel.isAuthorized {
                    ContentUnavailableView(
                        "알람 권한 필요",
                        systemImage: "alarm.fill",
                        description: Text("알람을 설정하려면 권한이 필요합니다")
                    )
                    .overlay(alignment: .bottom) {
                        Button("권한 허용") {
                            Task {
                                await viewModel.requestAuthorization()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.bottom, 50)
                    }
                } else if viewModel.alarms.isEmpty {
                    ContentUnavailableView(
                        "알람 없음",
                        systemImage: "alarm",
                        description: Text("새 알람을 추가하세요")
                    )
                } else {
                    List {
                        ForEach(viewModel.alarms) { alarm in
                            AlarmRow(alarm: alarm, viewModel: viewModel)
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                viewModel.deleteAlarm(viewModel.alarms[index])
                            }
                        }
                    }
                }
            }
            .navigationTitle("알람")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showingAddAlarm = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddAlarm) {
                AddAlarmView(viewModel: viewModel)
            }
        }
    }
}

// MARK: - Alarm Row
struct AlarmRow: View {
    let alarm: AlarmItem
    let viewModel: AlarmViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(alarm.timeString)
                    .font(.system(size: 48, weight: .light, design: .rounded))
                    .foregroundStyle(alarm.isEnabled ? .primary : .secondary)
                
                HStack {
                    Text(alarm.label)
                    if !alarm.repeatDays.isEmpty {
                        Text("• \(alarm.repeatDescription)")
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { alarm.isEnabled },
                set: { _ in viewModel.toggleAlarm(alarm) }
            ))
            .labelsHidden()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Add Alarm View
struct AddAlarmView: View {
    let viewModel: AlarmViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedTime = Date()
    @State private var label = "알람"
    @State private var repeatDays: Set<Weekday> = []
    @State private var selectedSound = "default"
    
    let sounds = ["default", "radar", "beacon", "chimes", "signal"]
    
    var body: some View {
        NavigationStack {
            Form {
                DatePicker("시간", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                
                Section {
                    TextField("라벨", text: $label)
                    
                    NavigationLink {
                        RepeatDayPicker(selectedDays: $repeatDays)
                    } label: {
                        HStack {
                            Text("반복")
                            Spacer()
                            Text(repeatDescription)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Picker("소리", selection: $selectedSound) {
                        ForEach(sounds, id: \.self) { sound in
                            Text(sound.capitalized).tag(sound)
                        }
                    }
                }
            }
            .navigationTitle("알람 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        let components = Calendar.current.dateComponents([.hour, .minute], from: selectedTime)
                        let newAlarm = AlarmItem(
                            id: UUID(),
                            hour: components.hour ?? 7,
                            minute: components.minute ?? 0,
                            label: label,
                            isEnabled: true,
                            repeatDays: repeatDays,
                            soundName: selectedSound
                        )
                        viewModel.addAlarm(newAlarm)
                        dismiss()
                    }
                }
            }
        }
    }
    
    var repeatDescription: String {
        if repeatDays.isEmpty { return "안 함" }
        if repeatDays.count == 7 { return "매일" }
        return repeatDays.sorted { $0.rawValue < $1.rawValue }
            .map { $0.shortName }
            .joined(separator: " ")
    }
}

// MARK: - Repeat Day Picker
struct RepeatDayPicker: View {
    @Binding var selectedDays: Set<Weekday>
    
    var body: some View {
        List {
            ForEach(Weekday.allCases, id: \.self) { day in
                HStack {
                    Text(dayName(day))
                    Spacer()
                    if selectedDays.contains(day) {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if selectedDays.contains(day) {
                        selectedDays.remove(day)
                    } else {
                        selectedDays.insert(day)
                    }
                }
            }
        }
        .navigationTitle("반복")
    }
    
    func dayName(_ day: Weekday) -> String {
        switch day {
        case .sunday: return "일요일마다"
        case .monday: return "월요일마다"
        case .tuesday: return "화요일마다"
        case .wednesday: return "수요일마다"
        case .thursday: return "목요일마다"
        case .friday: return "금요일마다"
        case .saturday: return "토요일마다"
        }
    }
}

#Preview {
    AlarmListView()
}
```

## 고급 패턴

### 1. 스누즈 처리

```swift
// 알람 응답 처리
func handleAlarmResponse(_ response: AlarmResponse) {
    switch response.action {
    case .dismiss:
        // 알람 종료
        break
    case .snooze:
        // 스누즈 - 9분 후 다시 알람
        scheduleSnoozeAlarm(originalAlarm: response.alarm)
    }
}

func scheduleSnoozeAlarm(originalAlarm: Alarm) {
    let snoozeTime = Calendar.current.date(byAdding: .minute, value: 9, to: Date())!
    let components = Calendar.current.dateComponents([.hour, .minute], from: snoozeTime)
    
    let snoozeAlarm = Alarm(
        id: UUID(),
        time: components,
        label: "\(originalAlarm.label) (스누즈)",
        sound: originalAlarm.sound,
        isEnabled: true
    )
    
    Task {
        try? await alarmManager.schedule(snoozeAlarm)
    }
}
```

### 2. 다음 알람 시간 계산

```swift
func nextAlarmTime(for alarm: AlarmItem) -> Date? {
    let calendar = Calendar.current
    var components = DateComponents()
    components.hour = alarm.hour
    components.minute = alarm.minute
    
    let now = Date()
    
    if alarm.repeatDays.isEmpty {
        // 단일 알람
        var nextDate = calendar.nextDate(after: now, matching: components, matchingPolicy: .nextTime)!
        if nextDate <= now {
            nextDate = calendar.date(byAdding: .day, value: 1, to: nextDate)!
        }
        return nextDate
    } else {
        // 반복 알람
        var nextDates: [Date] = []
        
        for day in alarm.repeatDays {
            components.weekday = day.rawValue
            if let date = calendar.nextDate(after: now, matching: components, matchingPolicy: .nextTime) {
                nextDates.append(date)
            }
        }
        
        return nextDates.min()
    }
}
```

### 3. 위젯 연동

```swift
import WidgetKit

struct AlarmWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "AlarmWidget", provider: AlarmTimelineProvider()) { entry in
            AlarmWidgetView(entry: entry)
        }
        .configurationDisplayName("다음 알람")
        .description("다음 알람 시간을 표시합니다")
        .supportedFamilies([.systemSmall])
    }
}

struct AlarmTimelineProvider: TimelineProvider {
    func getTimeline(in context: Context, completion: @escaping (Timeline<AlarmEntry>) -> Void) {
        let entry = AlarmEntry(date: Date(), nextAlarm: getNextAlarm())
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(60)))
        completion(timeline)
    }
}
```

## 주의사항

1. **iOS 버전**
   - AlarmKit: iOS 18+ 필요
   - 이전 버전은 UNNotificationRequest 사용

2. **권한**
   - 알람 권한 별도 요청 필요
   - 알림 권한과 다름

3. **배터리 최적화**
   - AlarmKit 알람은 배터리 절약 모드에서도 동작
   - 일반 알림보다 높은 우선순위

4. **시뮬레이터**
   - 알람 기능 제한적
   - 실기기 테스트 권장

5. **포그라운드 제한**
   - 앱이 포그라운드일 때도 시스템 알람 UI 표시
