import Contacts

class ContactManager {
    static let shared = ContactManager()
    
    let store = CNContactStore()
    
    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contactStoreDidChange),
            name: .CNContactStoreDidChange,
            object: nil
        )
    }
    
    @objc private func contactStoreDidChange(_ notification: Notification) {
        // 연락처 데이터가 변경됨
        print("연락처가 변경되었습니다")
    }
}
