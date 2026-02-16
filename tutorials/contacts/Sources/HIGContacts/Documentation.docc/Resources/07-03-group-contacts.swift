import Contacts

class GroupManager {
    let store = CNContactStore()
    
    func fetchContacts(inGroup group: CNGroup) throws -> [CNContact] {
        let keysToFetch: [CNKeyDescriptor] = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey as CNKeyDescriptor
        ]
        
        // 그룹에 속한 연락처 검색
        let predicate = CNContact.predicateForContactsInGroup(
            withIdentifier: group.identifier
        )
        
        return try store.unifiedContacts(
            matching: predicate,
            keysToFetch: keysToFetch
        )
    }
}
