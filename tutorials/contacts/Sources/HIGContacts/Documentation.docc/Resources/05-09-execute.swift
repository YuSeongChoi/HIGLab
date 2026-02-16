import Contacts

class ContactManager {
    let store = CNContactStore()
    
    func createContact(_ contact: CNMutableContact) throws {
        let saveRequest = CNSaveRequest()
        saveRequest.add(contact, toContainerWithIdentifier: nil)
        
        // 저장 요청 실행
        try store.execute(saveRequest)
        
        print("연락처가 저장되었습니다: \(contact.identifier)")
    }
}
