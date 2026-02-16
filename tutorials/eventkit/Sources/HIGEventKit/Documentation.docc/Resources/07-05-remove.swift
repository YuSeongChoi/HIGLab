import EventKit

extension CalendarManager {
    func removeAllAlarms(from event: EKEvent) {
        if let alarms = event.alarms {
            for alarm in alarms {
                event.removeAlarm(alarm)
            }
        }
    }
    
    func removeAlarm(_ alarm: EKAlarm, from event: EKEvent) {
        event.removeAlarm(alarm)
    }
}
