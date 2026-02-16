import Contacts

class SyncManager {
    let store = CNContactStore()
    
    // iOS 18+에서 사용 가능한 Change History API
    @available(iOS 18.0, *)
    func fetchChangeHistory(since token: Data?) async throws -> [CNChangeHistoryEvent] {
        let request = CNChangeHistoryFetchRequest()
        
        // 이전 토큰이 있으면 해당 시점 이후 변경사항만
        if let token = token {
            request.startingToken = token
        }
        
        // 필요한 키 지정
        request.additionalContactKeyDescriptors = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName)
        ]
        
        var events: [CNChangeHistoryEvent] = []
        
        let enumerator = try store.enumeratorForChangeHistory(matching: request)
        
        while let result = enumerator.nextObject() as? CNChangeHistoryEvent {
            events.append(result)
        }
        
        // 현재 토큰 저장
        // enumerator.currentHistoryToken
        
        return events
    }
}
