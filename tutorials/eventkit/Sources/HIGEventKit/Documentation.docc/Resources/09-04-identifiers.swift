import EventKit

// eventIdentifier vs calendarItemIdentifier

// eventIdentifier:
// - 반복 이벤트의 각 occurrence를 고유하게 식별
// - 날짜 정보가 포함됨
// - event(withIdentifier:)로 조회

// calendarItemIdentifier:
// - 반복 이벤트 전체를 하나로 식별
// - 모든 occurrence가 동일한 값 공유
// - calendarItem(withIdentifier:)로 조회

func compareIdentifiers(event: EKEvent) {
    print("eventIdentifier: \(event.eventIdentifier)")
    print("calendarItemIdentifier: \(event.calendarItemIdentifier)")
}
