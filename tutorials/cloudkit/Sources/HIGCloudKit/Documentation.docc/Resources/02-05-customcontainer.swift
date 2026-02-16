import CloudKit
import SwiftUI

@MainActor
final class CloudKitManager: ObservableObject {
    
    static let shared = CloudKitManager()
    
    private let container: CKContainer
    
    // 컨테이너 ID 상수
    private static let containerIdentifier = "iCloud.com.example.SharedNotes"
    
    private init() {
        // 특정 컨테이너 ID로 접근
        // 여러 앱이 같은 컨테이너를 공유할 때 사용
        self.container = CKContainer(identifier: Self.containerIdentifier)
        
        print("Using container: \(Self.containerIdentifier)")
    }
}
