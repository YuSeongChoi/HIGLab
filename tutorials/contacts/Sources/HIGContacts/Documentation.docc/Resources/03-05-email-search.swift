import Contacts

class ContactManager {
    let store = CNContactStore()
    
    func searchContacts(email: String) throws -> [CNContact] {
        let keysToFetch: [CNKeyDescriptor] = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactEmailAddressesKey as CNKeyDescriptor
        ]
        
        // 이메일로 검색하는 predicate
        let predicate = CNContact.predicateForContacts(
            matchingEmailAddress: email
        )
        
        return try store.unifiedContacts(
            matching: predicate,
            keysToFetch: keysToFetch
        )
    }
}
