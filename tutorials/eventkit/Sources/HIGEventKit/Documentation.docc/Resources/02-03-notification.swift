import EventKit

class CalendarManager {
    static let shared = CalendarManager()
    
    let eventStore = EKEventStore()
    
    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(storeChanged),
            name: .EKEventStoreChanged,
            object: eventStore
        )
    }
    
    @objc private func storeChanged() {
        // 데이터 새로고침 처리
    }
}
