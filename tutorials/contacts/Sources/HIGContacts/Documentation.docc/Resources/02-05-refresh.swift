import Contacts
import Combine

class ContactManager {
    static let shared = ContactManager()
    
    let store = CNContactStore()
    var contacts: [CNContact] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        NotificationCenter.default
            .publisher(for: .CNContactStoreDidChange)
            .sink { [weak self] _ in
                Task {
                    await self?.refreshContacts()
                }
            }
            .store(in: &cancellables)
    }
    
    func refreshContacts() async {
        // 연락처 목록 새로고침
        do {
            contacts = try await fetchAllContacts()
        } catch {
            print("새로고침 실패: \(error)")
        }
    }
    
    private func fetchAllContacts() async throws -> [CNContact] {
        // 구현은 다음 챕터에서
        return []
    }
}
