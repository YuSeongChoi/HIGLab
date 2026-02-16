import Contacts

class SyncManager {
    let store = CNContactStore()
    
    var onContactDeleted: ((String) -> Void)?
    
    func handleDeletedContact(identifier: String) {
        print("연락처 삭제됨: \(identifier)")
        
        // 로컬 캐시에서 제거
        removeFromLocalCache(identifier: identifier)
        
        // 서버에 동기화
        syncDeleteToServer(identifier: identifier)
        
        // 콜백 호출
        onContactDeleted?(identifier)
    }
    
    private func removeFromLocalCache(identifier: String) {
        // identifier로 로컬 캐시에서 제거
    }
    
    private func syncDeleteToServer(identifier: String) {
        // 서버에 삭제 알림
    }
}
