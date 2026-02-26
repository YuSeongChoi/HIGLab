# EventKit AI Reference

> Calendar and reminders access guide. Read this document to generate EventKit code.

## Overview

EventKit is a framework for accessing user calendar events and reminders.
It supports creating, querying, modifying, and deleting events as well as reminder management.

## Required Imports

```swift
import EventKit
import EventKitUI  // When using UI components
```

## Project Setup (Info.plist)

```xml
<key>NSCalendarsUsageDescription</key>
<string>Calendar access is needed to manage your schedule.</string>

<key>NSRemindersUsageDescription</key>
<string>Reminders access is needed to manage your tasks.</string>
```

## Core Components

### 1. EKEventStore (Entry Point)

```swift
let eventStore = EKEventStore()

// Request authorization (iOS 17+)
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

// iOS 16 and earlier
func requestAccessLegacy() async -> Bool {
    await withCheckedContinuation { continuation in
        eventStore.requestAccess(to: .event) { granted, _ in
            continuation.resume(returning: granted)
        }
    }
}
```

### 2. Creating Events

```swift
func createEvent(title: String, startDate: Date, endDate: Date) throws {
    let event = EKEvent(eventStore: eventStore)
    event.title = title
    event.startDate = startDate
    event.endDate = endDate
    event.calendar = eventStore.defaultCalendarForNewEvents
    
    // Add alarm
    let alarm = EKAlarm(relativeOffset: -3600)  // 1 hour before
    event.addAlarm(alarm)
    
    try eventStore.save(event, span: .thisEvent)
}
```

### 3. Fetching Events

```swift
func fetchEvents(from startDate: Date, to endDate: Date) -> [EKEvent] {
    let predicate = eventStore.predicateForEvents(
        withStart: startDate,
        end: endDate,
        calendars: nil  // nil for all calendars
    )
    
    return eventStore.events(matching: predicate)
}
```

## Complete Working Example

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
            .navigationTitle("Calendar")
            .toolbar {
                if manager.authorizationStatus == .fullAccess || manager.authorizationStatus == .authorized {
                    Button("Add", systemImage: "plus") {
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
            DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .padding()
            
            List {
                if manager.events.isEmpty {
                    ContentUnavailableView("No Events", systemImage: "calendar", description: Text("No events on this day"))
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
            Label("Calendar Access Required", systemImage: "calendar.badge.exclamationmark")
        } description: {
            Text("Permission is required to manage your schedule")
        } actions: {
            Button("Request Permission") {
                Task { await manager.requestAccess() }
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    var deniedView: some View {
        ContentUnavailableView {
            Label("Access Denied", systemImage: "calendar.badge.minus")
        } description: {
            Text("Please allow calendar access in Settings")
        } actions: {
            Button("Open Settings") {
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
                    Text("All Day")
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
                TextField("Title", text: $title)
                
                Toggle("All Day", isOn: $isAllDay)
                
                DatePicker("Start", selection: $startDate, displayedComponents: isAllDay ? .date : [.date, .hourAndMinute])
                
                DatePicker("End", selection: $endDate, displayedComponents: isAllDay ? .date : [.date, .hourAndMinute])
            }
            .navigationTitle("New Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
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

## Advanced Patterns

### 1. Reminders

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

### 2. Recurring Events

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

// Weekly on Monday
let weeklyRule = EKRecurrenceRule(
    recurrenceWith: .weekly,
    interval: 1,
    daysOfTheWeek: [EKRecurrenceDayOfWeek(.monday)],
    daysOfTheMonth: nil,
    monthsOfTheYear: nil,
    weeksOfTheYear: nil,
    daysOfTheYear: nil,
    setPositions: nil,
    end: nil  // Infinite recurrence
)

// Monthly on 15th, 10 occurrences
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

### 3. Using EventKitUI

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

## Important Notes

1. **iOS 17 Permission Changes**
   - `.fullAccess`: Full access
   - `.writeOnly`: Write only (cannot read)
   - Previous `.authorized` is deprecated

2. **Change Detection**
   ```swift
   NotificationCenter.default.addObserver(
       forName: .EKEventStoreChanged,
       object: eventStore,
       queue: .main
   ) { _ in
       // Refresh calendar data
   }
   ```

3. **Calendar Colors**
   ```swift
   let color = Color(cgColor: event.calendar.cgColor)
   ```

4. **Timezone Handling**
   - `EKEvent` includes timezone information
   - `startDate`, `endDate` are UTC based
