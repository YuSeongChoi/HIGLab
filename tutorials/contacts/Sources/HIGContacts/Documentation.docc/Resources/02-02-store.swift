import Contacts

class ContactManager {
    static let shared = ContactManager()
    
    let store = CNContactStore()
    
    private init() {}
}
