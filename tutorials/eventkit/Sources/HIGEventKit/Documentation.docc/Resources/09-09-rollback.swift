import EventKit

extension CalendarManager {
    func createMultipleEventsSafely(titles: [String], startDate: Date) throws {
        do {
            for (index, title) in titles.enumerated() {
                let event = EKEvent(eventStore: eventStore)
                event.title = title
                event.startDate = startDate.addingTimeInterval(Double(index) * 3600)
                event.endDate = event.startDate.addingTimeInterval(3600)
                event.calendar = eventStore.defaultCalendarForNewEvents
                
                try eventStore.save(event, span: .thisEvent, commit: false)
            }
            
            try eventStore.commit()
        } catch {
            // 에러 시 변경사항 되돌리기
            eventStore.reset()
            throw error
        }
    }
}
