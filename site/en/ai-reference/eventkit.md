# EventKit AI Reference

> 캘린더 및 리마인더 접근 가이드. 이 문서를 읽고 EventKit 코드를 생성할 수 있습니다.

## 개요

EventKit은 사용자의 캘린더 이벤트와 리마인더에 접근하는 프레임워크입니다.
일정 생성, 조회, 수정, 삭제 및 리마인더 관리를 지원합니다.

## 필수 Import

```swift
import EventKit
import EventKitUI  // UI 컴포넌트 사용 시
```

## 프로젝트 설정 (Info.plist)

```xml
<key>NSCalendarsUsageDescription</key>
<string>일정을 관리하기 위해 캘린더 접근이 필요합니다.</string>

<key>NSRemindersUsageDescription</key>
<string>할 일을 관리하기 위해 미리 알림 접근이 필요합니다.</string>
```

## 핵심 구성요소

### 1. EKEventStore (진입점)

```swift
let eventStore = EKEventStore()

// 권한 요청 (iOS 17+)
func requestCalendarAccess() async -> Bool {
    do {
        return try await eventStore.requestFullAccessToEvents()
    } catch {
        return false
    }
}

func requestReminderAccess() async -> Bool {
    do {
        return try await eventStore.requestFullAccessToReminders()
    } catch {
        return false
    }
}

// iOS 16 이하
func requestAccessLegacy() async -> Bool {
    await withCheckedContinuation { continuation in
        eventStore.requestAccess(to: .event) { granted, _ in
            continuation.resume(returning: granted)
        }
    }
}
```

### 2. 이벤트 생성

```swift
func createEvent(title: String, startDate: Date, endDate: Date) throws {
    let event = EKEvent(eventStore: eventStore)
    event.title = title
    event.startDate = startDate
    event.endDate = endDate
    event.calendar = eventStore.defaultCalendarForNewEvents
    
    // 알림 추가
    let alarm = EKAlarm(relativeOffset: -3600)  // 1시간 전
    event.addAlarm(alarm)
    
    try eventStore.save(event, span: .thisEvent)
}
```

### 3. 이벤트 조회

```swift
func fetchEvents(from startDate: Date, to endDate: Date) -> [EKEvent] {
    let predicate = eventStore.predicateForEvents(
        withStart: startDate,
        end: endDate,
        calendars: nil  // nil이면 모든 캘린더
    )
    
    return eventStore.events(matching: predicate)
}
```

## 전체 작동 예제

```swift
import SwiftUI
import EventKit
import EventKitUI

// MARK: - Calendar Manager
@Observable
class CalendarManager {
    let eventStore = EKEventStore()
    var events: [EKEvent] = []
    var calendars: [EKCalendar] = []
    var authorizationStatus: EKAuthorizationStatus = .notDetermined
    
    init() {
        checkAuthorizationStatus()
    }
    
    func checkAuthorizationStatus() {
        authorizationStatus = EKEventStore.authorizationStatus(for: .event)
    }
    
    func requestAccess() async -> Bool {
        if #available(iOS 17.0, *) {
            do {
                let granted = try await eventStore.requestFullAccessToEvents()
                await MainActor.run {
                    checkAuthorizationStatus()
                    if granted { loadCalendars() }
                }
                return granted
            } catch {
                return false
            }
        } else {
            return await withCheckedContinuation { continuation in
                eventStore.requestAccess(to: .event) { granted, _ in
                    DispatchQueue.main.async {
                        self.checkAuthorizationStatus()
                        if granted { self.loadCalendars() }
                    }
                    continuation.resume(returning: granted)
                }
            }
        }
    }
    
    func loadCalendars() {
        calendars = eventStore.calendars(for: .event)
    }
    
    func fetchEvents(for date: Date) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = eventStore.predicateForEvents(
            withStart: startOfDay,
            end: endOfDay,
            calendars: nil
        )
        
        events = eventStore.events(matching: predicate)
            .sorted { $0.startDate < $1.startDate }
    }
    
    func createEvent(title: String, startDate: Date, endDate: Date, calendar: EKCalendar? = nil) throws {
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = calendar ?? eventStore.defaultCalendarForNewEvents
        
        try eventStore.save(event, span: .thisEvent)
        fetchEvents(for: startDate)
    }
    
    func deleteEvent(_ event: EKEvent) throws {
        try eventStore.remove(event, span: .thisEvent)
        if let index = events.firstIndex(of: event) {
            events.remove(at: index)
        }
    }
}

// MARK: - Views
struct CalendarView: View {
    @State private var manager = CalendarManager()
    @State private var selectedDate = Date()
    @State private var showingAddEvent = false
    
    var body: some View {
        NavigationStack {
            Group {
                switch manager.authorizationStatus {
                case .fullAccess, .authorized:
                    eventListView
                case .notDetermined:
                    requestAccessView
                default:
                    deniedView
                }
            }
            .navigationTitle("캘린더")
            .toolbar {
                if manager.authorizationStatus == .fullAccess || manager.authorizationStatus == .authorized {
                    Button("추가", systemImage: "plus") {
                        showingAddEvent = true
                    }
                }
            }
            .sheet(isPresented: $showingAddEvent) {
                AddEventView(manager: manager, date: selectedDate)
            }
        }
    }
    
    var eventListView: some View {
        VStack {
            DatePicker("날짜", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .padding()
            
            List {
                if manager.events.isEmpty {
                    ContentUnavailableView("일정 없음", systemImage: "calendar", description: Text("이 날에 일정이 없습니다"))
                } else {
                    ForEach(manager.events, id: \.eventIdentifier) { event in
                        EventRow(event: event)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            try? manager.deleteEvent(manager.events[index])
                        }
                    }
                }
            }
        }
        .onChange(of: selectedDate) { _, newDate in
            manager.fetchEvents(for: newDate)
        }
        .onAppear {
            manager.fetchEvents(for: selectedDate)
        }
    }
    
    var requestAccessView: some View {
        ContentUnavailableView {
            Label("캘린더 접근 필요", systemImage: "calendar.badge.exclamationmark")
        } description: {
            Text("일정을 관리하려면 캘린더 접근 권한이 필요합니다")
        } actions: {
            Button("권한 요청") {
                Task { await manager.requestAccess() }
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    var deniedView: some View {
        ContentUnavailableView {
            Label("접근 거부됨", systemImage: "calendar.badge.minus")
        } description: {
            Text("설정에서 캘린더 접근을 허용해주세요")
        } actions: {
            Button("설정 열기") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
}

struct EventRow: View {
    let event: EKEvent
    
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(cgColor: event.calendar.cgColor))
                .frame(width: 4)
            
            VStack(alignment: .leading) {
                Text(event.title)
                    .font(.headline)
                
                if event.isAllDay {
                    Text("하루 종일")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("\(event.startDate.formatted(date: .omitted, time: .shortened)) - \(event.endDate.formatted(date: .omitted, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

struct AddEventView: View {
    let manager: CalendarManager
    let date: Date
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var isAllDay = false
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("제목", text: $title)
                
                Toggle("하루 종일", isOn: $isAllDay)
                
                DatePicker("시작", selection: $startDate, displayedComponents: isAllDay ? .date : [.date, .hourAndMinute])
                
                DatePicker("종료", selection: $endDate, displayedComponents: isAllDay ? .date : [.date, .hourAndMinute])
            }
            .navigationTitle("새 이벤트")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("추가") {
                        try? manager.createEvent(title: title, startDate: startDate, endDate: endDate)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .onAppear {
                startDate = date
                endDate = Calendar.current.date(byAdding: .hour, value: 1, to: date) ?? date
            }
        }
    }
}
```

## 고급 패턴

### 1. 리마인더 (미리 알림)

```swift
func fetchReminders() async -> [EKReminder] {
    let predicate = eventStore.predicateForReminders(in: nil)
    
    return await withCheckedContinuation { continuation in
        eventStore.fetchReminders(matching: predicate) { reminders in
            continuation.resume(returning: reminders ?? [])
        }
    }
}

func createReminder(title: String, dueDate: Date?) throws {
    let reminder = EKReminder(eventStore: eventStore)
    reminder.title = title
    reminder.calendar = eventStore.defaultCalendarForNewReminders()
    
    if let dueDate {
        reminder.dueDateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: dueDate
        )
    }
    
    try eventStore.save(reminder, commit: true)
}

func completeReminder(_ reminder: EKReminder) throws {
    reminder.isCompleted = true
    try eventStore.save(reminder, commit: true)
}
```

### 2. 반복 이벤트

```swift
func createRecurringEvent(title: String, startDate: Date, recurrence: EKRecurrenceRule) throws {
    let event = EKEvent(eventStore: eventStore)
    event.title = title
    event.startDate = startDate
    event.endDate = Calendar.current.date(byAdding: .hour, value: 1, to: startDate)
    event.calendar = eventStore.defaultCalendarForNewEvents
    event.addRecurrenceRule(recurrence)
    
    try eventStore.save(event, span: .futureEvents)
}

// 매주 월요일 반복
let weeklyRule = EKRecurrenceRule(
    recurrenceWith: .weekly,
    interval: 1,
    daysOfTheWeek: [EKRecurrenceDayOfWeek(.monday)],
    daysOfTheMonth: nil,
    monthsOfTheYear: nil,
    weeksOfTheYear: nil,
    daysOfTheYear: nil,
    setPositions: nil,
    end: nil  // 무한 반복
)

// 매월 15일 반복, 10회
let monthlyRule = EKRecurrenceRule(
    recurrenceWith: .monthly,
    interval: 1,
    daysOfTheWeek: nil,
    daysOfTheMonth: [15],
    monthsOfTheYear: nil,
    weeksOfTheYear: nil,
    daysOfTheYear: nil,
    setPositions: nil,
    end: EKRecurrenceEnd(occurrenceCount: 10)
)
```

### 3. EventKitUI 사용

```swift
struct EventEditViewWrapper: UIViewControllerRepresentable {
    let eventStore: EKEventStore
    let event: EKEvent?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> EKEventEditViewController {
        let controller = EKEventEditViewController()
        controller.eventStore = eventStore
        controller.event = event ?? EKEvent(eventStore: eventStore)
        controller.editViewDelegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: EKEventEditViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: dismiss)
    }
    
    class Coordinator: NSObject, EKEventEditViewDelegate {
        let dismiss: DismissAction
        
        init(dismiss: DismissAction) {
            self.dismiss = dismiss
        }
        
        func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
            dismiss()
        }
    }
}
```

## 주의사항

1. **iOS 17 권한 변경**
   - `.fullAccess`: 전체 접근
   - `.writeOnly`: 쓰기만 (읽기 불가)
   - 기존 `.authorized`는 deprecated

2. **변경 감지**
   ```swift
   NotificationCenter.default.addObserver(
       forName: .EKEventStoreChanged,
       object: eventStore,
       queue: .main
   ) { _ in
       // 캘린더 데이터 새로고침
   }
   ```

3. **캘린더 색상**
   ```swift
   let color = Color(cgColor: event.calendar.cgColor)
   ```

4. **시간대 처리**
   - `EKEvent`는 시간대 정보 포함
   - `startDate`, `endDate`는 UTC 기준
