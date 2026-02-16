import EventKit

extension CalendarManager {
    // span 옵션:
    // .thisEvent - 현재 이벤트만 영향
    // .futureEvents - 현재 + 미래 이벤트 모두 영향
    
    func saveEvent(_ event: EKEvent, span: EKSpan = .thisEvent) throws {
        try eventStore.save(event, span: span, commit: true)
    }
}
