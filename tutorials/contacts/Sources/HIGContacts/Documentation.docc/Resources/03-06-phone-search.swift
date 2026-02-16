import Contacts

class ContactManager {
    let store = CNContactStore()
    
    func searchContacts(phoneNumber: String) throws -> [CNContact] {
        let keysToFetch: [CNKeyDescriptor] = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey as CNKeyDescriptor
        ]
        
        // 전화번호로 검색하는 predicate
        let phoneValue = CNPhoneNumber(stringValue: phoneNumber)
        let predicate = CNContact.predicateForContacts(
            matching: phoneValue
        )
        
        return try store.unifiedContacts(
            matching: predicate,
            keysToFetch: keysToFetch
        )
    }
}
