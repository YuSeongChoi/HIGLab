import Contacts

class ContactManager {
    let store = CNContactStore()
    
    func fetchSortedContacts(order: CNContactSortOrder) throws -> [CNContact] {
        let keysToFetch: [CNKeyDescriptor] = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName)
        ]
        
        let request = CNContactFetchRequest(keysToFetch: keysToFetch)
        
        // 정렬 순서 옵션
        // .userDefault: 시스템 설정에 따름
        // .givenName: 이름 기준
        // .familyName: 성 기준
        request.sortOrder = order
        
        var contacts: [CNContact] = []
        try store.enumerateContacts(with: request) { contact, _ in
            contacts.append(contact)
        }
        
        return contacts
    }
}
