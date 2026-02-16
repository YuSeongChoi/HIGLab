import Contacts
import Combine
import Observation

@Observable
class SyncManager {
    let store = CNContactStore()
    
    var isSyncing = false
    var lastSyncDate: Date?
    var pendingChanges = 0
    
    private var cancellables = Set<AnyCancellable>()
    private let tokenKey = "ContactsHistoryToken"
    
    init() {
        setupNotifications()
    }
    
    private func setupNotifications() {
        NotificationCenter.default
            .publisher(for: .CNContactStoreDidChange)
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                Task { @MainActor in
                    await self?.sync()
                }
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    func sync() async {
        guard !isSyncing else { return }
        isSyncing = true
        defer { isSyncing = false }
        
        do {
            if #available(iOS 18.0, *) {
                try await syncWithHistory()
            } else {
                try await fullSync()
            }
            
            lastSyncDate = Date()
        } catch {
            print("동기화 실패: \(error)")
        }
    }
    
    @available(iOS 18.0, *)
    private func syncWithHistory() async throws {
        let token = UserDefaults.standard.data(forKey: tokenKey)
        
        let request = CNChangeHistoryFetchRequest()
        request.startingToken = token
        request.additionalContactKeyDescriptors = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey as CNKeyDescriptor
        ]
        
        let enumerator = try store.enumeratorForChangeHistory(matching: request)
        
        while let event = enumerator.nextObject() as? CNChangeHistoryEvent {
            await processEvent(event)
        }
        
        // 새 토큰 저장
        if let newToken = enumerator.currentHistoryToken {
            UserDefaults.standard.set(newToken, forKey: tokenKey)
        }
    }
    
    private func fullSync() async throws {
        // iOS 18 미만: 전체 동기화
    }
    
    @available(iOS 18.0, *)
    private func processEvent(_ event: CNChangeHistoryEvent) async {
        switch event {
        case let add as CNChangeHistoryAddContactEvent:
            pendingChanges += 1
            // 서버에 추가 동기화
            
        case let update as CNChangeHistoryUpdateContactEvent:
            pendingChanges += 1
            // 서버에 업데이트 동기화
            
        case let delete as CNChangeHistoryDeleteContactEvent:
            pendingChanges += 1
            // 서버에서 삭제
            
        default:
            break
        }
    }
}
