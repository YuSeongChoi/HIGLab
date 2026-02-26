# AlarmKit AI Reference

> Alarm clock app implementation guide. Read this document to generate AlarmKit code.

## Overview

AlarmKit is an alarm app development framework available on iOS 18+.
It provides the same reliable alarm functionality as the system Clock app, ensuring alarms trigger at the exact time even under battery optimization.

## Required Import

```swift
import AlarmKit
```

## Project Setup

### 1. Add Capability
Xcode > Signing & Capabilities > Background Modes > Background processing

### 2. Info.plist

```xml
<!-- Alarm Permission Description -->
<key>NSAlarmUsageDescription</key>
<string>Required to ring alarms at the specified time.</string>
```

## Core Components

### 1. AlarmManager

```swift
import AlarmKit

// Alarm manager instance
let alarmManager = AlarmManager.shared

// Request permission
func requestPermission() async -> Bool {
    await alarmManager.requestAuthorization()
}

// Check permission status
let status = alarmManager.authorizationStatus
```

### 2. Alarm (Creating Alarms)

```swift
// Single alarm
let alarm = Alarm(
    id: UUID(),
    time: DateComponents(hour: 7, minute: 30),
    label: "Wake Up Alarm",
    sound: .default,
    isEnabled: true
)

// Repeating alarm
let weekdayAlarm = Alarm(
    id: UUID(),
    time: DateComponents(hour: 7, minute: 0),
    label: "Work Alarm",
    sound: .custom(named: "morning"),
    repeatDays: [.monday, .tuesday, .wednesday, .thursday, .friday],
    isEnabled: true
)
```

### 3. AlarmSound (Alarm Sounds)

```swift
// Default sound
AlarmSound.default

// System sounds
AlarmSound.system(.radar)
AlarmSound.system(.beacon)

// Custom sound (audio file included in bundle)
AlarmSound.custom(named: "rooster")
```

## Complete Working Example

```swift
import SwiftUI
import AlarmKit

// MARK: - Alarm Model (for internal app use)
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
            return "Never"
        } else if repeatDays.count == 7 {
            return "Every Day"
        } else if repeatDays == [.monday, .tuesday, .wednesday, .thursday, .friday] {
            return "Weekdays"
        } else if repeatDays == [.saturday, .sunday] {
            return "Weekends"
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
        case .sunday: return "Sun"
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
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
        
        // Cancel existing alarm
        cancelAlarm(alarms[index])
        
        // Set new alarm
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
    
    // MARK: - AlarmKit Integration
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
                print("Alarm scheduling failed: \(error)")
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
                        "Alarm Permission Required",
                        systemImage: "alarm.fill",
                        description: Text("Permission is required to set alarms")
                    )
                    .overlay(alignment: .bottom) {
                        Button("Allow Permission") {
                            Task {
                                await viewModel.requestAuthorization()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.bottom, 50)
                    }
                } else if viewModel.alarms.isEmpty {
                    ContentUnavailableView(
                        "No Alarms",
                        systemImage: "alarm",
                        description: Text("Add a new alarm")
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
            .navigationTitle("Alarms")
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
    @State private var label = "Alarm"
    @State private var repeatDays: Set<Weekday> = []
    @State private var selectedSound = "default"
    
    let sounds = ["default", "radar", "beacon", "chimes", "signal"]
    
    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                
                Section {
                    TextField("Label", text: $label)
                    
                    NavigationLink {
                        RepeatDayPicker(selectedDays: $repeatDays)
                    } label: {
                        HStack {
                            Text("Repeat")
                            Spacer()
                            Text(repeatDescription)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Picker("Sound", selection: $selectedSound) {
                        ForEach(sounds, id: \.self) { sound in
                            Text(sound.capitalized).tag(sound)
                        }
                    }
                }
            }
            .navigationTitle("Add Alarm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
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
        if repeatDays.isEmpty { return "Never" }
        if repeatDays.count == 7 { return "Every Day" }
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
        .navigationTitle("Repeat")
    }
    
    func dayName(_ day: Weekday) -> String {
        switch day {
        case .sunday: return "Every Sunday"
        case .monday: return "Every Monday"
        case .tuesday: return "Every Tuesday"
        case .wednesday: return "Every Wednesday"
        case .thursday: return "Every Thursday"
        case .friday: return "Every Friday"
        case .saturday: return "Every Saturday"
        }
    }
}

#Preview {
    AlarmListView()
}
```

## Advanced Patterns

### 1. Snooze Handling

```swift
// Alarm response handling
func handleAlarmResponse(_ response: AlarmResponse) {
    switch response.action {
    case .dismiss:
        // Alarm ended
        break
    case .snooze:
        // Snooze - alarm again after 9 minutes
        scheduleSnoozeAlarm(originalAlarm: response.alarm)
    }
}

func scheduleSnoozeAlarm(originalAlarm: Alarm) {
    let snoozeTime = Calendar.current.date(byAdding: .minute, value: 9, to: Date())!
    let components = Calendar.current.dateComponents([.hour, .minute], from: snoozeTime)
    
    let snoozeAlarm = Alarm(
        id: UUID(),
        time: components,
        label: "\(originalAlarm.label) (Snooze)",
        sound: originalAlarm.sound,
        isEnabled: true
    )
    
    Task {
        try? await alarmManager.schedule(snoozeAlarm)
    }
}
```

### 2. Calculate Next Alarm Time

```swift
func nextAlarmTime(for alarm: AlarmItem) -> Date? {
    let calendar = Calendar.current
    var components = DateComponents()
    components.hour = alarm.hour
    components.minute = alarm.minute
    
    let now = Date()
    
    if alarm.repeatDays.isEmpty {
        // Single alarm
        var nextDate = calendar.nextDate(after: now, matching: components, matchingPolicy: .nextTime)!
        if nextDate <= now {
            nextDate = calendar.date(byAdding: .day, value: 1, to: nextDate)!
        }
        return nextDate
    } else {
        // Repeating alarm
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

### 3. Widget Integration

```swift
import WidgetKit

struct AlarmWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "AlarmWidget", provider: AlarmTimelineProvider()) { entry in
            AlarmWidgetView(entry: entry)
        }
        .configurationDisplayName("Next Alarm")
        .description("Displays the next alarm time")
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

## Important Notes

1. **iOS Version**
   - AlarmKit: Requires iOS 18+
   - Use UNNotificationRequest for earlier versions

2. **Permission**
   - Separate alarm permission request required
   - Different from notification permission

3. **Battery Optimization**
   - AlarmKit alarms work even in battery saver mode
   - Higher priority than regular notifications

4. **Simulator**
   - Alarm features are limited
   - Real device testing recommended

5. **Foreground Limitation**
   - System alarm UI displays even when app is in foreground
