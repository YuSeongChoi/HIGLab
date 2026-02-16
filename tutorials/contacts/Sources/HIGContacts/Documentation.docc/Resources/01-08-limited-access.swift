import Contacts

class ContactManager {
    private let store = CNContactStore()
    
    var authorizationStatus: CNAuthorizationStatus {
        CNContactStore.authorizationStatus(for: .contacts)
    }
    
    var isLimitedAccess: Bool {
        if #available(iOS 18.0, *) {
            return authorizationStatus == .limited
        }
        return false
    }
    
    func checkAndRequestAccess() async -> Bool {
        switch authorizationStatus {
        case .notDetermined:
            return await requestAccess()
        case .authorized:
            return true
        case .denied, .restricted:
            return false
        case .limited:
            // iOS 18+: 사용자가 선택한 연락처만 접근 가능
            // 추가 연락처 선택을 요청할 수 있음
            return true
        @unknown default:
            return false
        }
    }
    
    private func requestAccess() async -> Bool {
        do {
            return try await store.requestAccess(for: .contacts)
        } catch {
            return false
        }
    }
}
