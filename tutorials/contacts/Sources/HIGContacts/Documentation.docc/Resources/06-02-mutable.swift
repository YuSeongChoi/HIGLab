import Contacts

class ContactManager {
    let store = CNContactStore()
    
    func fetchMutableContact(identifier: String) throws -> CNMutableContact {
        let contact = try fetchContact(identifier: identifier)
        
        // CNMutableContact로 변환
        guard let mutableContact = contact.mutableCopy() as? CNMutableContact else {
            throw ContactError.invalidData
        }
        
        return mutableContact
    }
    
    private func fetchContact(identifier: String) throws -> CNContact {
        let keysToFetch: [CNKeyDescriptor] = [
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor
        ]
        
        return try store.unifiedContact(
            withIdentifier: identifier,
            keysToFetch: keysToFetch
        )
    }
}
