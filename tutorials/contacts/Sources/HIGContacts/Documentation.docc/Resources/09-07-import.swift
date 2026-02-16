import Contacts

class VCardManager {
    let store = CNContactStore()
    
    func importContacts(from vCardData: Data) throws -> Int {
        let contacts = try CNContactVCardSerialization.contacts(with: vCardData)
        
        let saveRequest = CNSaveRequest()
        
        for contact in contacts {
            // CNContact는 불변이므로 mutableCopy 필요
            if let mutableContact = contact.mutableCopy() as? CNMutableContact {
                saveRequest.add(mutableContact, toContainerWithIdentifier: nil)
            }
        }
        
        try store.execute(saveRequest)
        
        return contacts.count
    }
    
    func importContactsFromFile(at url: URL) throws -> Int {
        let contacts = try readVCardFile(at: url)
        
        let saveRequest = CNSaveRequest()
        
        for contact in contacts {
            if let mutableContact = contact.mutableCopy() as? CNMutableContact {
                saveRequest.add(mutableContact, toContainerWithIdentifier: nil)
            }
        }
        
        try store.execute(saveRequest)
        
        return contacts.count
    }
    
    private func readVCardFile(at url: URL) throws -> [CNContact] {
        let data = try Data(contentsOf: url)
        return try CNContactVCardSerialization.contacts(with: data)
    }
}
