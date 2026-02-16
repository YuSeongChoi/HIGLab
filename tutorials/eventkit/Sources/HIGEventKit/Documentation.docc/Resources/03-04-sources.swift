import EventKit

extension CalendarManager {
    func sourceTypeName(_ type: EKSourceType) -> String {
        switch type {
        case .local:
            return "로컬"
        case .exchange:
            return "Exchange"
        case .calDAV:
            return "CalDAV"
        case .birthdays:
            return "생일"
        case .subscribed:
            return "구독"
        @unknown default:
            return "기타"
        }
    }
}
