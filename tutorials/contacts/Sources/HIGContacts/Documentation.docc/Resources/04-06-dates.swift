import Contacts

let contact: CNContact = // 가져온 연락처

// 생일 접근
if let birthday = contact.birthday {
    // DateComponents 타입
    let year = birthday.year   // 연도 (nil일 수 있음)
    let month = birthday.month // 월
    let day = birthday.day     // 일
    
    // Date로 변환
    if let date = Calendar.current.date(from: birthday) {
        print("생일: \(date)")
    }
}

// 기념일 등 날짜 목록
for labeledValue in contact.dates {
    let label = labeledValue.label ?? "기타"
    let localizedLabel = CNLabeledValue<NSString>.localizedString(forLabel: label)
    
    let dateComponents = labeledValue.value
    if let date = Calendar.current.date(from: dateComponents as DateComponents) {
        print("\(localizedLabel): \(date)")
    }
}
