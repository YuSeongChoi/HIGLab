import Contacts

class ContactManager {
    let store = CNContactStore()
    
    func updateContact(_ contact: CNMutableContact) throws {
        let saveRequest = CNSaveRequest()
        
        // 수정할 연락처를 요청에 추가
        saveRequest.update(contact)
        
        // 저장 실행
        try store.execute(saveRequest)
        
        print("연락처가 수정되었습니다: \(contact.identifier)")
    }
}
