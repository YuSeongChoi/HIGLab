import Contacts

class GroupManager {
    let store = CNContactStore()
    
    func fetchGroups(inContainer container: CNContainer) throws -> [CNGroup] {
        // 특정 컨테이너의 그룹만 가져오기
        let predicate = CNGroup.predicateForGroups(
            inContainerWithIdentifier: container.identifier
        )
        
        return try store.groups(matching: predicate)
    }
    
    func fetchDefaultContainerGroups() throws -> [CNGroup] {
        let defaultContainerID = store.defaultContainerIdentifier()
        let predicate = CNGroup.predicateForGroups(
            inContainerWithIdentifier: defaultContainerID
        )
        
        return try store.groups(matching: predicate)
    }
}
