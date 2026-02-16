import Contacts
import Foundation

class SyncManager {
    let store = CNContactStore()
    
    private let tokenKey = "ContactsHistoryToken"
    
    // History Token 저장
    func saveToken(_ token: Data) {
        UserDefaults.standard.set(token, forKey: tokenKey)
    }
    
    // History Token 로드
    func loadToken() -> Data? {
        UserDefaults.standard.data(forKey: tokenKey)
    }
    
    // 현재 토큰 가져오기 (iOS 18+)
    @available(iOS 18.0, *)
    func getCurrentToken() throws -> Data? {
        let request = CNChangeHistoryFetchRequest()
        let enumerator = try store.enumeratorForChangeHistory(matching: request)
        
        // 끝까지 진행하여 현재 토큰 획득
        while enumerator.nextObject() != nil {}
        
        return enumerator.currentHistoryToken
    }
}
