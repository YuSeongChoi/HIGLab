import Contacts

class ContactManager {
    let store = CNContactStore()
    
    func createContact(_ contact: CNMutableContact) throws {
        // CNSaveRequest 생성
        let saveRequest = CNSaveRequest()
        
        // 추가할 연락처를 요청에 포함
        // nil은 기본 컨테이너에 저장
        saveRequest.add(contact, toContainerWithIdentifier: nil)
    }
}
