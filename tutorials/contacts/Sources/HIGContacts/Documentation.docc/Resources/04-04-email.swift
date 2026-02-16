import Contacts

let contact: CNContact = // 가져온 연락처

// 이메일 목록 접근
for labeledValue in contact.emailAddresses {
    let label = labeledValue.label ?? "기타"
    let localizedLabel = CNLabeledValue<NSString>.localizedString(forLabel: label)
    
    // 이메일 값 (NSString 타입)
    let email = labeledValue.value as String
    
    print("\(localizedLabel): \(email)")
}

// 첫 번째 이메일만 가져오기
if let firstEmail = contact.emailAddresses.first {
    let email = firstEmail.value as String
}
