import Contacts

class GroupManager {
    let store = CNContactStore()
    
    func saveGroup(_ group: CNMutableGroup, in containerID: String? = nil) throws {
        let saveRequest = CNSaveRequest()
        
        // 그룹 추가 (nil이면 기본 컨테이너)
        saveRequest.add(group, toContainerWithIdentifier: containerID)
        
        try store.execute(saveRequest)
        
        print("그룹이 생성되었습니다: \(group.name)")
    }
    
    func createAndSaveGroup(name: String) throws -> CNMutableGroup {
        let group = CNMutableGroup()
        group.name = name
        
        try saveGroup(group)
        
        return group
    }
}
