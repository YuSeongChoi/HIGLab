import Contacts

class ContactManager {
    let store = CNContactStore()
    
    func addPhoneNumber(
        to contact: CNMutableContact,
        number: String,
        label: String = CNLabelPhoneNumberMobile
    ) {
        let newPhone = CNLabeledValue(
            label: label,
            value: CNPhoneNumber(stringValue: number)
        )
        
        // 기존 전화번호 배열에 추가
        var phones = contact.phoneNumbers
        phones.append(newPhone)
        contact.phoneNumbers = phones
    }
}
