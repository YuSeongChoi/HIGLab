import Contacts

class ContactManager {
    let store = CNContactStore()
    
    func deleteContact(_ contact: CNMutableContact) throws {
        let saveRequest = CNSaveRequest()
        
        // 삭제할 연락처를 요청에 추가
        saveRequest.delete(contact)
        
        // 삭제 실행
        try store.execute(saveRequest)
        
        print("연락처가 삭제되었습니다")
    }
    
    func deleteContact(identifier: String) throws {
        let mutableContact = try fetchMutableContact(identifier: identifier)
        try deleteContact(mutableContact)
    }
    
    private func fetchMutableContact(identifier: String) throws -> CNMutableContact {
        // 이전 코드...
        fatalError("구현 필요")
    }
}
