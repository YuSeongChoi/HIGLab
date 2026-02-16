import CloudKit
import SwiftUI

@MainActor
final class CloudKitManager: ObservableObject {
    
    static let shared = CloudKitManager()
    
    private let container: CKContainer
    
    // 세 가지 데이터베이스 참조
    var privateDatabase: CKDatabase {
        container.privateCloudDatabase
    }
    
    var publicDatabase: CKDatabase {
        container.publicCloudDatabase
    }
    
    var sharedDatabase: CKDatabase {
        container.sharedCloudDatabase
    }
    
    private init() {
        self.container = CKContainer.default()
    }
    
    // 데이터베이스 타입에 따라 반환
    func database(for scope: CKDatabase.Scope) -> CKDatabase {
        switch scope {
        case .private:
            return privateDatabase
        case .public:
            return publicDatabase
        case .shared:
            return sharedDatabase
        @unknown default:
            return privateDatabase
        }
    }
}
