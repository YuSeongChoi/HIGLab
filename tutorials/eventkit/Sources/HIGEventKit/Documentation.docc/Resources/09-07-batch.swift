import EventKit

extension CalendarManager {
    func createMultipleEvents(titles: [String], startDate: Date) throws {
        for (index, title) in titles.enumerated() {
            let event = EKEvent(eventStore: eventStore)
            event.title = title
            event.startDate = startDate.addingTimeInterval(Double(index) * 3600)
            event.endDate = event.startDate.addingTimeInterval(3600)
            event.calendar = eventStore.defaultCalendarForNewEvents
            
            // commit: false로 배치 처리
            try eventStore.save(event, span: .thisEvent, commit: false)
        }
    }
}
