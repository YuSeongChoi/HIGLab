import EventKit

extension CalendarManager {
    func fetchCalendars() -> [EKCalendar] {
        eventStore.calendars(for: .event)
    }
    
    func printCalendarInfo(_ calendar: EKCalendar) {
        print("제목: \(calendar.title)")
        print("색상: \(calendar.cgColor)")
        print("소스: \(calendar.source.title)")
        print("수정 가능: \(calendar.allowsContentModifications)")
        print("식별자: \(calendar.calendarIdentifier)")
    }
}
