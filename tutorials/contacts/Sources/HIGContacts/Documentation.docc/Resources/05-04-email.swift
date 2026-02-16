import Contacts

let newContact = CNMutableContact()
newContact.givenName = "민수"
newContact.familyName = "김"

// 이메일 추가
let personalEmail = CNLabeledValue(
    label: CNLabelHome,
    value: "minsu@example.com" as NSString
)

let workEmail = CNLabeledValue(
    label: CNLabelWork,
    value: "minsu@company.com" as NSString
)

newContact.emailAddresses = [personalEmail, workEmail]
