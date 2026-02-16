import Contacts

let newContact = CNMutableContact()
newContact.givenName = "민수"
newContact.familyName = "김"

// 주소 추가
let homeAddress = CNMutablePostalAddress()
homeAddress.street = "강남대로 123"
homeAddress.city = "서울"
homeAddress.state = "서울특별시"
homeAddress.postalCode = "06000"
homeAddress.country = "대한민국"

let labeledAddress = CNLabeledValue(
    label: CNLabelHome,
    value: homeAddress
)

newContact.postalAddresses = [labeledAddress]
