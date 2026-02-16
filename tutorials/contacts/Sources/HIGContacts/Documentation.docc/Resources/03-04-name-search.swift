import Contacts

class ContactManager {
    let store = CNContactStore()
    
    func searchContacts(name: String) throws -> [CNContact] {
        let keysToFetch: [CNKeyDescriptor] = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey as CNKeyDescriptor
        ]
        
        // 이름으로 검색하는 predicate
        let predicate = CNContact.predicateForContacts(matchingName: name)
        
        return try store.unifiedContacts(
            matching: predicate,
            keysToFetch: keysToFetch
        )
    }
}
