import Contacts

let newContact = CNMutableContact()
newContact.givenName = "민수"
newContact.familyName = "김"

// 전화번호 추가
let mobilePhone = CNLabeledValue(
    label: CNLabelPhoneNumberMobile,
    value: CNPhoneNumber(stringValue: "010-1234-5678")
)

let workPhone = CNLabeledValue(
    label: CNLabelWork,
    value: CNPhoneNumber(stringValue: "02-123-4567")
)

newContact.phoneNumbers = [mobilePhone, workPhone]
