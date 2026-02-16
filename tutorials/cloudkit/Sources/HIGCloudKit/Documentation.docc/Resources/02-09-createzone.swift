import CloudKit
import SwiftUI

@MainActor
final class CloudKitManager: ObservableObject {
    
    static let shared = CloudKitManager()
    
    private let container: CKContainer
    static let notesZoneName = "NotesZone"
    
    lazy var notesZone: CKRecordZone = {
        CKRecordZone(zoneName: Self.notesZoneName)
    }()
    
    private var privateDatabase: CKDatabase {
        container.privateCloudDatabase
    }
    
    private init() {
        self.container = CKContainer.default()
    }
    
    /// 커스텀 Zone 생성 (한 번만 실행)
    func createNotesZoneIfNeeded() async throws {
        // 기존 Zone 확인
        let zones = try await privateDatabase.allRecordZones()
        let zoneExists = zones.contains { $0.zoneID.zoneName == Self.notesZoneName }
        
        if zoneExists {
            print("✅ Zone already exists: \(Self.notesZoneName)")
            return
        }
        
        // Zone 생성
        let savedZone = try await privateDatabase.save(notesZone)
        print("✅ Zone created: \(savedZone.zoneID.zoneName)")
    }
}
