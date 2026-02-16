import Contacts

class VCardManager {
    func exportToVCard(contacts: [CNContact]) throws -> Data {
        // 여러 연락처를 하나의 vCard 파일로
        let vCardData = try CNContactVCardSerialization.data(with: contacts)
        return vCardData
    }
    
    func exportAllContacts(store: CNContactStore) throws -> Data {
        let keysToFetch: [CNKeyDescriptor] = [
            CNContactVCardSerialization.descriptorForRequiredKeys()
        ]
        
        let request = CNContactFetchRequest(keysToFetch: keysToFetch)
        var contacts: [CNContact] = []
        
        try store.enumerateContacts(with: request) { contact, _ in
            contacts.append(contact)
        }
        
        return try exportToVCard(contacts: contacts)
    }
}
