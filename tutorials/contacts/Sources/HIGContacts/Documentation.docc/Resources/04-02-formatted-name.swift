import Contacts

let contact: CNContact = // 가져온 연락처

// CNContactFormatter로 지역화된 이름 포맷팅
let fullName = CNContactFormatter.string(
    from: contact,
    style: .fullName
)
// 한국어: "김민수"
// 영어: "Minsu Kim"

// 발음 이름 (일본어 등에서 사용)
let phoneticName = CNContactFormatter.string(
    from: contact,
    style: .phoneticFullName
)

// Formatter 인스턴스 사용
let formatter = CNContactFormatter()
formatter.style = .fullName
let name = formatter.string(from: contact)
