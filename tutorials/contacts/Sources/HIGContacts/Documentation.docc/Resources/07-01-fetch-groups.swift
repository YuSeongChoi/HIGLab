import Contacts

class GroupManager {
    let store = CNContactStore()
    
    func fetchAllGroups() throws -> [CNGroup] {
        // 모든 그룹 가져오기
        return try store.groups(matching: nil)
    }
}
