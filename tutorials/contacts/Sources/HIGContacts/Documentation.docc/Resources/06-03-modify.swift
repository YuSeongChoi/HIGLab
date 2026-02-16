import Contacts

class ContactManager {
    let store = CNContactStore()
    
    func updateContactName(
        identifier: String,
        givenName: String,
        familyName: String
    ) throws {
        let mutableContact = try fetchMutableContact(identifier: identifier)
        
        // 이름 수정
        mutableContact.givenName = givenName
        mutableContact.familyName = familyName
        
        // 저장 로직은 다음 단계에서
    }
    
    private func fetchMutableContact(identifier: String) throws -> CNMutableContact {
        // 이전 코드...
        fatalError("구현 필요")
    }
}
