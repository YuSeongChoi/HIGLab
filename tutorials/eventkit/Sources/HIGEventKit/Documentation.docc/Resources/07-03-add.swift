import EventKit

extension CalendarManager {
    func addAlarm(to event: EKEvent, minutesBefore: Int) {
        let alarm = EKAlarm(relativeOffset: TimeInterval(-minutesBefore * 60))
        event.addAlarm(alarm)
    }
}
