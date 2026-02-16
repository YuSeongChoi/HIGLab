import Contacts
import Combine

class SyncManager {
    let store = CNContactStore()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // 연락처 변경 알림 구독
        NotificationCenter.default
            .publisher(for: .CNContactStoreDidChange)
            .sink { [weak self] notification in
                self?.handleContactsChanged(notification)
            }
            .store(in: &cancellables)
    }
    
    private func handleContactsChanged(_ notification: Notification) {
        print("연락처 데이터베이스가 변경되었습니다")
        
        // 변경사항 처리
        Task {
            await processChanges()
        }
    }
    
    private func processChanges() async {
        // 변경사항 처리 로직
    }
}
