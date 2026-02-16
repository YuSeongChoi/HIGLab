import Contacts

class ContactManager {
    let store = CNContactStore()
    
    func removePhoneNumber(
        from contact: CNMutableContact,
        at index: Int
    ) {
        guard index < contact.phoneNumbers.count else { return }
        
        var phones = contact.phoneNumbers
        phones.remove(at: index)
        contact.phoneNumbers = phones
    }
    
    // 특정 레이블의 전화번호 제거
    func removePhoneNumbers(
        from contact: CNMutableContact,
        withLabel label: String
    ) {
        contact.phoneNumbers = contact.phoneNumbers.filter { $0.label != label }
    }
}
