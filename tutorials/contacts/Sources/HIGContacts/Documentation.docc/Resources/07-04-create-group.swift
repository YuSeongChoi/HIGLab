import Contacts

class GroupManager {
    let store = CNContactStore()
    
    func createGroup(name: String) -> CNMutableGroup {
        let group = CNMutableGroup()
        group.name = name
        return group
    }
}
