import Contacts
import Combine

class ContactManager {
    static let shared = ContactManager()
    
    let store = CNContactStore()
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        NotificationCenter.default
            .publisher(for: .CNContactStoreDidChange)
            .sink { [weak self] _ in
                self?.handleContactsChanged()
            }
            .store(in: &cancellables)
    }
    
    private func handleContactsChanged() {
        print("연락처가 변경되었습니다")
    }
}
