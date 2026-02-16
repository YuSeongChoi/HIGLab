import Contacts

class ContactManager {
    let store = CNContactStore()
    
    func fetchContact(identifier: String) throws -> CNContact {
        let keysToFetch: [CNKeyDescriptor] = [
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactEmailAddressesKey as CNKeyDescriptor
        ]
        
        return try store.unifiedContact(
            withIdentifier: identifier,
            keysToFetch: keysToFetch
        )
    }
}
