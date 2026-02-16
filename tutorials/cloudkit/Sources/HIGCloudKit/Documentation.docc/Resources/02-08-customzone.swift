import CloudKit
import SwiftUI

@MainActor
final class CloudKitManager: ObservableObject {
    
    static let shared = CloudKitManager()
    
    private let container: CKContainer
    
    // 커스텀 Zone 정의
    // Private Database에서만 커스텀 Zone 사용 가능
    static let notesZoneName = "NotesZone"
    
    lazy var notesZone: CKRecordZone = {
        CKRecordZone(zoneName: Self.notesZoneName)
    }()
    
    lazy var notesZoneID: CKRecordZone.ID = {
        CKRecordZone.ID(zoneName: Self.notesZoneName)
    }()
    
    private init() {
        self.container = CKContainer.default()
    }
}
