import Contacts

class ContactManager {
    let store = CNContactStore()
    
    func fetchContacts(inContainer container: CNContainer) throws -> [CNContact] {
        let keysToFetch: [CNKeyDescriptor] = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName)
        ]
        
        // 특정 컨테이너(iCloud, 로컬 등)의 연락처 검색
        let predicate = CNContact.predicateForContactsInContainer(
            withIdentifier: container.identifier
        )
        
        return try store.unifiedContacts(
            matching: predicate,
            keysToFetch: keysToFetch
        )
    }
    
    func fetchAllContainers() throws -> [CNContainer] {
        return try store.containers(matching: nil)
    }
}
