import Contacts

let contact: CNContact = // 가져온 연락처

// 전화번호 목록 접근
for labeledValue in contact.phoneNumbers {
    // 레이블 (휴대전화, 집, 회사 등)
    let label = labeledValue.label ?? "기타"
    let localizedLabel = CNLabeledValue<NSString>.localizedString(forLabel: label)
    
    // 전화번호 값
    let phoneNumber = labeledValue.value
    let stringValue = phoneNumber.stringValue
    
    print("\(localizedLabel): \(stringValue)")
}

// 첫 번째 전화번호만 가져오기
if let firstPhone = contact.phoneNumbers.first {
    let number = firstPhone.value.stringValue
}
