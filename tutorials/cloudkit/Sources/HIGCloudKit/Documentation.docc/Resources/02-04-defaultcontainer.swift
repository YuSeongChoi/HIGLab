import CloudKit
import SwiftUI

@MainActor
final class CloudKitManager: ObservableObject {
    
    static let shared = CloudKitManager()
    
    // 기본 컨테이너 (앱의 bundle ID 기반)
    // Entitlements에 정의된 첫 번째 컨테이너를 사용
    private let container: CKContainer
    
    private init() {
        // CKContainer.default()는 앱의 기본 컨테이너 반환
        self.container = CKContainer.default()
        
        // 컨테이너 ID 확인
        print("Container ID: \(container.containerIdentifier ?? "unknown")")
    }
}
