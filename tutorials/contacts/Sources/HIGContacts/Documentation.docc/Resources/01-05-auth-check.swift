import Contacts

class ContactManager {
    private let store = CNContactStore()
    
    var authorizationStatus: CNAuthorizationStatus {
        CNContactStore.authorizationStatus(for: .contacts)
    }
    
    var isAuthorized: Bool {
        authorizationStatus == .authorized
    }
}
