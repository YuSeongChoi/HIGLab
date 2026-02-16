import Contacts
import Observation

@Observable
class ContactManager {
    static let shared = ContactManager()
    
    let store = CNContactStore()
    var contacts: [CNContact] = []
    var isLoading = false
    var errorMessage: String?
    
    private init() {
        NotificationCenter.default.addObserver(
            forName: .CNContactStoreDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                await self?.refreshContacts()
            }
        }
    }
    
    @MainActor
    func refreshContacts() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            contacts = try await fetchAllContacts()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func fetchAllContacts() async throws -> [CNContact] {
        return []
    }
}
