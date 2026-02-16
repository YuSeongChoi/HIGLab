import CloudKit
import SwiftUI
import Foundation

/// CloudKit 작업을 관리하는 매니저
@MainActor
final class CloudKitManager: ObservableObject {
    
    // 싱글톤 인스턴스
    static let shared = CloudKitManager()
    
    // CloudKit 컨테이너
    private let container: CKContainer
    
    // 데이터베이스 참조
    private var privateDatabase: CKDatabase {
        container.privateCloudDatabase
    }
    
    private var publicDatabase: CKDatabase {
        container.publicCloudDatabase
    }
    
    private var sharedDatabase: CKDatabase {
        container.sharedCloudDatabase
    }
    
    // 초기화
    private init() {
        // 기본 컨테이너 사용
        self.container = CKContainer.default()
    }
}
