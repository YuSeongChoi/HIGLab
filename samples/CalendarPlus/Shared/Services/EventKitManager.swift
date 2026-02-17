import Foundation
import EventKit
import Combine

// MARK: - EventKit 관리 서비스
/// 캘린더와 리마인더 데이터를 관리하는 싱글톤 서비스
@MainActor
final class EventKitManager: ObservableObject {
    
    // MARK: - 싱글톤 인스턴스
    static let shared = EventKitManager()
    
    // MARK: - Published 프로퍼티
    @Published var calendarAuthorizationStatus: EKAuthorizationStatus = .notDetermined
    @Published var reminderAuthorizationStatus: EKAuthorizationStatus = .notDetermined
    @Published var calendars: [CalendarInfo] = []
    @Published var reminderLists: [ReminderList] = []
    @Published var events: [CalendarEvent] = []
    @Published var reminders: [ReminderItem] = []
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    // MARK: - Private 프로퍼티
    private let eventStore = EKEventStore()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 초기화
    private init() {
        // 현재 권한 상태 확인
        updateAuthorizationStatus()
        
        // EventKit 변경 알림 구독
        NotificationCenter.default.publisher(for: .EKEventStoreChanged)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task {
                    await self?.refreshAllData()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - 권한 상태 업데이트
    private func updateAuthorizationStatus() {
        calendarAuthorizationStatus = EKEventStore.authorizationStatus(for: .event)
        reminderAuthorizationStatus = EKEventStore.authorizationStatus(for: .reminder)
    }
    
    // MARK: - 캘린더 권한 요청
    /// 캘린더 접근 권한을 요청합니다
    func requestCalendarAccess() async -> Bool {
        do {
            // iOS 17+에서는 전체 접근 권한 요청
            if #available(iOS 17.0, macOS 14.0, *) {
                let granted = try await eventStore.requestFullAccessToEvents()
                updateAuthorizationStatus()
                if granted {
                    await loadCalendars()
                }
                return granted
            } else {
                // iOS 17 미만에서는 기존 방식
                let granted = try await eventStore.requestAccess(to: .event)
                updateAuthorizationStatus()
                if granted {
                    await loadCalendars()
                }
                return granted
            }
        } catch {
            errorMessage = "캘린더 권한 요청 실패: \(error.localizedDescription)"
            return false
        }
    }
    
    // MARK: - 리마인더 권한 요청
    /// 리마인더 접근 권한을 요청합니다
    func requestReminderAccess() async -> Bool {
        do {
            // iOS 17+에서는 전체 접근 권한 요청
            if #available(iOS 17.0, macOS 14.0, *) {
                let granted = try await eventStore.requestFullAccessToReminders()
                updateAuthorizationStatus()
                if granted {
                    await loadReminderLists()
                }
                return granted
            } else {
                let granted = try await eventStore.requestAccess(to: .reminder)
                updateAuthorizationStatus()
                if granted {
                    await loadReminderLists()
                }
                return granted
            }
        } catch {
            errorMessage = "리마인더 권한 요청 실패: \(error.localizedDescription)"
            return false
        }
    }
    
    // MARK: - 모든 데이터 새로고침
    func refreshAllData() async {
        updateAuthorizationStatus()
        
        if calendarAuthorizationStatus == .fullAccess || calendarAuthorizationStatus == .authorized {
            await loadCalendars()
        }
        
        if reminderAuthorizationStatus == .fullAccess || reminderAuthorizationStatus == .authorized {
            await loadReminderLists()
        }
    }
    
    // MARK: - 캘린더 목록 로드
    func loadCalendars() async {
        let ekCalendars = eventStore.calendars(for: .event)
        calendars = ekCalendars.map { CalendarInfo(from: $0) }
    }
    
    // MARK: - 리마인더 목록 로드
    func loadReminderLists() async {
        let ekCalendars = eventStore.calendars(for: .reminder)
        var lists: [ReminderList] = []
        
        for calendar in ekCalendars {
            // 각 목록의 미완료 항목 수 계산
            let predicate = eventStore.predicateForIncompleteReminders(
                withDueDateStarting: nil,
                ending: nil,
                calendars: [calendar]
            )
            
            let count = await withCheckedContinuation { continuation in
                eventStore.fetchReminders(matching: predicate) { reminders in
                    continuation.resume(returning: reminders?.count ?? 0)
                }
            }
            
            lists.append(ReminderList(from: calendar, incompleteCount: count))
        }
        
        reminderLists = lists
    }
    
    // MARK: - 이벤트 로드 (기간 지정)
    /// 지정된 기간의 이벤트를 로드합니다
    func loadEvents(from startDate: Date, to endDate: Date, calendars: [String]? = nil) async {
        isLoading = true
        defer { isLoading = false }
        
        var ekCalendars: [EKCalendar]?
        if let calendarIds = calendars {
            ekCalendars = calendarIds.compactMap { id in
                eventStore.calendar(withIdentifier: id)
            }
        }
        
        let predicate = eventStore.predicateForEvents(
            withStart: startDate,
            end: endDate,
            calendars: ekCalendars
        )
        
        let ekEvents = eventStore.events(matching: predicate)
        events = ekEvents.map { CalendarEvent(from: $0) }
            .sorted { $0.startDate < $1.startDate }
    }
    
    // MARK: - 이벤트 생성
    func createEvent(_ event: CalendarEvent) async throws {
        guard let calendar = eventStore.calendar(withIdentifier: event.calendarIdentifier) else {
            throw EventKitError.calendarNotFound
        }
        
        let ekEvent = EKEvent(eventStore: eventStore)
        ekEvent.title = event.title
        ekEvent.startDate = event.startDate
        ekEvent.endDate = event.endDate
        ekEvent.isAllDay = event.isAllDay
        ekEvent.location = event.location
        ekEvent.notes = event.notes
        ekEvent.calendar = calendar
        
        // 반복 규칙 설정
        if let rule = event.recurrenceRule {
            ekEvent.recurrenceRules = [rule.toEKRecurrenceRule()]
        }
        
        // 알림 설정
        ekEvent.alarms = event.alarms.map { $0.toEKAlarm() }
        
        try eventStore.save(ekEvent, span: .thisEvent)
    }
    
    // MARK: - 이벤트 수정
    func updateEvent(_ event: CalendarEvent, span: EKSpan = .thisEvent) async throws {
        guard let ekEvent = eventStore.event(withIdentifier: event.id) else {
            throw EventKitError.eventNotFound
        }
        
        ekEvent.title = event.title
        ekEvent.startDate = event.startDate
        ekEvent.endDate = event.endDate
        ekEvent.isAllDay = event.isAllDay
        ekEvent.location = event.location
        ekEvent.notes = event.notes
        
        // 캘린더 변경
        if let newCalendar = eventStore.calendar(withIdentifier: event.calendarIdentifier) {
            ekEvent.calendar = newCalendar
        }
        
        // 반복 규칙 업데이트
        ekEvent.recurrenceRules = nil
        if let rule = event.recurrenceRule {
            ekEvent.recurrenceRules = [rule.toEKRecurrenceRule()]
        }
        
        // 알림 업데이트
        ekEvent.alarms = event.alarms.map { $0.toEKAlarm() }
        
        try eventStore.save(ekEvent, span: span)
    }
    
    // MARK: - 이벤트 삭제
    func deleteEvent(_ event: CalendarEvent, span: EKSpan = .thisEvent) async throws {
        guard let ekEvent = eventStore.event(withIdentifier: event.id) else {
            throw EventKitError.eventNotFound
        }
        
        try eventStore.remove(ekEvent, span: span)
    }
    
    // MARK: - 리마인더 로드
    func loadReminders(for filter: ReminderFilter = .all, lists: [String]? = nil) async {
        isLoading = true
        defer { isLoading = false }
        
        var ekCalendars: [EKCalendar]?
        if let listIds = lists {
            ekCalendars = listIds.compactMap { id in
                eventStore.calendar(withIdentifier: id)
            }
        }
        
        let predicate: NSPredicate
        
        switch filter {
        case .all:
            predicate = eventStore.predicateForReminders(in: ekCalendars)
            
        case .today:
            let today = Calendar.current.startOfDay(for: Date())
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
            predicate = eventStore.predicateForIncompleteReminders(
                withDueDateStarting: today,
                ending: tomorrow,
                calendars: ekCalendars
            )
            
        case .scheduled:
            predicate = eventStore.predicateForIncompleteReminders(
                withDueDateStarting: Date(),
                ending: nil,
                calendars: ekCalendars
            )
            
        case .completed:
            predicate = eventStore.predicateForCompletedReminders(
                withCompletionDateStarting: nil,
                ending: nil,
                calendars: ekCalendars
            )
            
        case .flagged:
            // 중요 표시는 우선순위가 높음인 것들
            predicate = eventStore.predicateForReminders(in: ekCalendars)
        }
        
        let ekReminders = await withCheckedContinuation { continuation in
            eventStore.fetchReminders(matching: predicate) { reminders in
                continuation.resume(returning: reminders ?? [])
            }
        }
        
        var result = ekReminders.map { ReminderItem(from: $0) }
        
        // 중요 필터의 경우 추가 필터링
        if filter == .flagged {
            result = result.filter { $0.priority == .high }
        }
        
        // 정렬: 미완료 우선, 그 다음 기한 순
        reminders = result.sorted { r1, r2 in
            if r1.isCompleted != r2.isCompleted {
                return !r1.isCompleted
            }
            guard let d1 = r1.dueDate, let d2 = r2.dueDate else {
                return r1.dueDate != nil
            }
            return d1 < d2
        }
    }
    
    // MARK: - 리마인더 생성
    func createReminder(_ reminder: ReminderItem) async throws {
        guard let calendar = eventStore.calendar(withIdentifier: reminder.listIdentifier) else {
            throw EventKitError.calendarNotFound
        }
        
        let ekReminder = EKReminder(eventStore: eventStore)
        ekReminder.title = reminder.title
        ekReminder.notes = reminder.notes
        ekReminder.isCompleted = reminder.isCompleted
        ekReminder.priority = reminder.priority.rawValue
        ekReminder.calendar = calendar
        
        // 기한 설정
        if let dueDate = reminder.dueDate {
            ekReminder.dueDateComponents = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: dueDate
            )
        }
        
        // 알림 설정
        ekReminder.alarms = reminder.alarms.map { $0.toEKAlarm() }
        
        // 반복 규칙 설정
        if let rule = reminder.recurrenceRule {
            ekReminder.recurrenceRules = [rule.toEKRecurrenceRule()]
        }
        
        try eventStore.save(ekReminder, commit: true)
    }
    
    // MARK: - 리마인더 수정
    func updateReminder(_ reminder: ReminderItem) async throws {
        // 기존 리마인더 검색
        let predicate = eventStore.predicateForReminders(in: nil)
        
        let ekReminder = await withCheckedContinuation { continuation in
            eventStore.fetchReminders(matching: predicate) { reminders in
                let found = reminders?.first { $0.calendarItemIdentifier == reminder.id }
                continuation.resume(returning: found)
            }
        }
        
        guard let existingReminder = ekReminder else {
            throw EventKitError.reminderNotFound
        }
        
        existingReminder.title = reminder.title
        existingReminder.notes = reminder.notes
        existingReminder.isCompleted = reminder.isCompleted
        existingReminder.priority = reminder.priority.rawValue
        
        if reminder.isCompleted && existingReminder.completionDate == nil {
            existingReminder.completionDate = Date()
        } else if !reminder.isCompleted {
            existingReminder.completionDate = nil
        }
        
        // 캘린더 변경
        if let newCalendar = eventStore.calendar(withIdentifier: reminder.listIdentifier) {
            existingReminder.calendar = newCalendar
        }
        
        // 기한 업데이트
        if let dueDate = reminder.dueDate {
            existingReminder.dueDateComponents = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: dueDate
            )
        } else {
            existingReminder.dueDateComponents = nil
        }
        
        // 알림 업데이트
        existingReminder.alarms = reminder.alarms.map { $0.toEKAlarm() }
        
        // 반복 규칙 업데이트
        existingReminder.recurrenceRules = nil
        if let rule = reminder.recurrenceRule {
            existingReminder.recurrenceRules = [rule.toEKRecurrenceRule()]
        }
        
        try eventStore.save(existingReminder, commit: true)
    }
    
    // MARK: - 리마인더 완료 토글
    func toggleReminderCompletion(_ reminder: ReminderItem) async throws {
        var updatedReminder = reminder
        updatedReminder.isCompleted.toggle()
        try await updateReminder(updatedReminder)
    }
    
    // MARK: - 리마인더 삭제
    func deleteReminder(_ reminder: ReminderItem) async throws {
        let predicate = eventStore.predicateForReminders(in: nil)
        
        let ekReminder = await withCheckedContinuation { continuation in
            eventStore.fetchReminders(matching: predicate) { reminders in
                let found = reminders?.first { $0.calendarItemIdentifier == reminder.id }
                continuation.resume(returning: found)
            }
        }
        
        guard let existingReminder = ekReminder else {
            throw EventKitError.reminderNotFound
        }
        
        try eventStore.remove(existingReminder, commit: true)
    }
    
    // MARK: - 기본 캘린더 가져오기
    func defaultCalendar() -> CalendarInfo? {
        guard let ekCalendar = eventStore.defaultCalendarForNewEvents else {
            return nil
        }
        return CalendarInfo(from: ekCalendar)
    }
    
    // MARK: - 기본 리마인더 목록 가져오기
    func defaultReminderList() -> ReminderList? {
        guard let ekCalendar = eventStore.defaultCalendarForNewReminders else {
            return nil
        }
        return ReminderList(from: ekCalendar)
    }
}

// MARK: - EventKit 에러
enum EventKitError: LocalizedError {
    case calendarNotFound
    case eventNotFound
    case reminderNotFound
    case accessDenied
    case saveFailed
    
    var errorDescription: String? {
        switch self {
        case .calendarNotFound:
            return "캘린더를 찾을 수 없습니다"
        case .eventNotFound:
            return "이벤트를 찾을 수 없습니다"
        case .reminderNotFound:
            return "리마인더를 찾을 수 없습니다"
        case .accessDenied:
            return "접근 권한이 없습니다"
        case .saveFailed:
            return "저장에 실패했습니다"
        }
    }
}
