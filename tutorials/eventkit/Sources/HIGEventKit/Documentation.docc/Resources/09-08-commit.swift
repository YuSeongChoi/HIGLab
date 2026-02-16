import EventKit

extension CalendarManager {
    func createMultipleEvents(titles: [String], startDate: Date) throws {
        for (index, title) in titles.enumerated() {
            let event = EKEvent(eventStore: eventStore)
            event.title = title
            event.startDate = startDate.addingTimeInterval(Double(index) * 3600)
            event.endDate = event.startDate.addingTimeInterval(3600)
            event.calendar = eventStore.defaultCalendarForNewEvents
            
            try eventStore.save(event, span: .thisEvent, commit: false)
        }
        
        // 모든 변경사항을 한 번에 커밋
        try eventStore.commit()
    }
}
