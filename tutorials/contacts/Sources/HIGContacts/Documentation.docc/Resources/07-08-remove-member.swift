import Contacts

class GroupManager {
    let store = CNContactStore()
    
    func removeContact(_ contact: CNContact, fromGroup group: CNGroup) throws {
        let saveRequest = CNSaveRequest()
        
        // 연락처를 그룹에서 제거 (연락처 자체는 삭제되지 않음)
        saveRequest.removeMember(contact, from: group)
        
        try store.execute(saveRequest)
        
        print("연락처가 그룹에서 제거되었습니다")
    }
    
    func removeAllContacts(fromGroup group: CNGroup) throws {
        let contacts = try fetchContacts(inGroup: group)
        
        let saveRequest = CNSaveRequest()
        for contact in contacts {
            saveRequest.removeMember(contact, from: group)
        }
        
        try store.execute(saveRequest)
    }
    
    private func fetchContacts(inGroup group: CNGroup) throws -> [CNContact] {
        // 이전 코드...
        []
    }
}
