import Contacts

class ContactManager {
    let store = CNContactStore()
    
    func updatePhoneNumber(
        in contact: CNMutableContact,
        at index: Int,
        newNumber: String
    ) {
        guard index < contact.phoneNumbers.count else { return }
        
        let existingLabeled = contact.phoneNumbers[index]
        
        // CNLabeledValue는 불변이므로 새로 생성
        let updatedPhone = CNLabeledValue(
            label: existingLabeled.label,
            value: CNPhoneNumber(stringValue: newNumber)
        )
        
        // 배열 교체
        var phones = contact.phoneNumbers
        phones[index] = updatedPhone
        contact.phoneNumbers = phones
    }
}
