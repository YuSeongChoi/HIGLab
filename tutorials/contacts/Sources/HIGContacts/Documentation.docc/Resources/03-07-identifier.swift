import Contacts

class ContactManager {
    let store = CNContactStore()
    
    func fetchContact(identifier: String) throws -> CNContact? {
        let keysToFetch: [CNKeyDescriptor] = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactEmailAddressesKey as CNKeyDescriptor,
            CNContactImageDataKey as CNKeyDescriptor
        ]
        
        // 식별자로 검색
        let predicate = CNContact.predicateForContacts(
            withIdentifiers: [identifier]
        )
        
        let contacts = try store.unifiedContacts(
            matching: predicate,
            keysToFetch: keysToFetch
        )
        
        return contacts.first
    }
}
