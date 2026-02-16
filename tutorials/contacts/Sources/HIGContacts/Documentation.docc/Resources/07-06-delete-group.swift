import Contacts

class GroupManager {
    let store = CNContactStore()
    
    func deleteGroup(_ group: CNMutableGroup) throws {
        let saveRequest = CNSaveRequest()
        
        // 그룹 삭제
        saveRequest.delete(group)
        
        try store.execute(saveRequest)
        
        print("그룹이 삭제되었습니다")
    }
    
    func deleteGroup(identifier: String) throws {
        // 삭제하려면 mutableCopy 필요
        let groups = try store.groups(matching: nil)
        guard let group = groups.first(where: { $0.identifier == identifier }),
              let mutableGroup = group.mutableCopy() as? CNMutableGroup else {
            throw ContactError.notFound
        }
        
        try deleteGroup(mutableGroup)
    }
}
