import CloudKit
import SwiftUI

@MainActor
final class CloudKitManager: ObservableObject {
    
    static let shared = CloudKitManager()
    
    private let container: CKContainer
    
    @Published var accountStatus: CKAccountStatus = .couldNotDetermine
    @Published var isSignedIn: Bool = false
    
    private init() {
        self.container = CKContainer.default()
    }
    
    /// iCloud 계정 상태 확인
    func checkAccountStatus() async throws -> CKAccountStatus {
        let status = try await container.accountStatus()
        
        await MainActor.run {
            self.accountStatus = status
            self.isSignedIn = (status == .available)
        }
        
        switch status {
        case .available:
            print("✅ iCloud 계정 사용 가능")
        case .noAccount:
            print("❌ iCloud 계정 없음 - 설정에서 로그인 필요")
        case .restricted:
            print("⚠️ iCloud 접근 제한됨 (자녀 보호 등)")
        case .couldNotDetermine:
            print("❓ 계정 상태 확인 불가")
        case .temporarilyUnavailable:
            print("⏳ 일시적으로 사용 불가")
        @unknown default:
            print("❓ 알 수 없는 상태")
        }
        
        return status
    }
}
