import Contacts

class ContactManager {
    private let store = CNContactStore()
    
    var authorizationStatus: CNAuthorizationStatus {
        CNContactStore.authorizationStatus(for: .contacts)
    }
    
    func requestAccess() async -> Bool {
        do {
            return try await store.requestAccess(for: .contacts)
        } catch {
            print("권한 요청 실패: \(error)")
            return false
        }
    }
    
    func checkAndRequestAccess() async -> Bool {
        switch authorizationStatus {
        case .notDetermined:
            return await requestAccess()
        case .authorized:
            return true
        case .denied, .restricted:
            // 설정 앱으로 안내
            return false
        case .limited:
            // iOS 18+: 제한된 접근
            return true
        @unknown default:
            return false
        }
    }
}
