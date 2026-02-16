import Contacts

let contact: CNContact = // 가져온 연락처

// 주소 목록 접근
for labeledValue in contact.postalAddresses {
    let label = labeledValue.label ?? "기타"
    let localizedLabel = CNLabeledValue<NSString>.localizedString(forLabel: label)
    
    // 주소 값
    let address = labeledValue.value
    print("\(localizedLabel):")
    print("  거리: \(address.street)")
    print("  도시: \(address.city)")
    print("  지역: \(address.state)")
    print("  우편번호: \(address.postalCode)")
    print("  국가: \(address.country)")
    
    // 포맷된 주소 문자열
    let formatter = CNPostalAddressFormatter()
    let formattedAddress = formatter.string(from: address)
    print("포맷된 주소:\n\(formattedAddress)")
}
