import EventKit

extension CalendarManager {
    func addMultipleAlarms(to event: EKEvent) {
        // 1시간 전 알림
        let alarm1Hour = EKAlarm(relativeOffset: -60 * 60)
        event.addAlarm(alarm1Hour)
        
        // 15분 전 알림
        let alarm15Min = EKAlarm(relativeOffset: -15 * 60)
        event.addAlarm(alarm15Min)
    }
}
