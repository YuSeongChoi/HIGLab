import EventKit

extension CalendarManager {
    func saveEvent(_ event: EKEvent) throws {
        do {
            try eventStore.save(event, span: .thisEvent, commit: true)
        } catch {
            print("이벤트 저장 실패: \(error.localizedDescription)")
            throw error
        }
    }
}
