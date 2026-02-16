import Contacts

let keysToFetch: [CNKeyDescriptor] = [
    CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
    CNContactPhoneNumbersKey as CNKeyDescriptor,
    CNContactEmailAddressesKey as CNKeyDescriptor
]

// CNContactFetchRequest 생성
let request = CNContactFetchRequest(keysToFetch: keysToFetch)

// 정렬 순서 설정 (선택사항)
request.sortOrder = .userDefault
