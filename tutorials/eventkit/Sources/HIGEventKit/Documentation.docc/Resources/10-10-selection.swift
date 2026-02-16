import EventKit
import EventKitUI

// 선택 스타일
// .single - 하나만 선택
// .multiple - 여러 개 선택

let singleChooser = EKCalendarChooser(
    selectionStyle: .single,
    displayStyle: .writableCalendarsOnly,
    entityType: .event,
    eventStore: eventStore
)

let multipleChooser = EKCalendarChooser(
    selectionStyle: .multiple,
    displayStyle: .allCalendars,
    entityType: .event,
    eventStore: eventStore
)
