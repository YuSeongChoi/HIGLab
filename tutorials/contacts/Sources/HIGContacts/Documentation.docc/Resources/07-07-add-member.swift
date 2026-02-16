import Contacts

class GroupManager {
    let store = CNContactStore()
    
    func addContact(_ contact: CNContact, toGroup group: CNGroup) throws {
        let saveRequest = CNSaveRequest()
        
        // 연락처를 그룹에 추가
        saveRequest.addMember(contact, to: group)
        
        try store.execute(saveRequest)
        
        print("연락처가 그룹에 추가되었습니다")
    }
    
    func addContacts(_ contacts: [CNContact], toGroup group: CNGroup) throws {
        let saveRequest = CNSaveRequest()
        
        for contact in contacts {
            saveRequest.addMember(contact, to: group)
        }
        
        try store.execute(saveRequest)
    }
}
