import CloudKit

extension CloudKitManager {
    
    /// 메모 저장 (Private/Shared 자동 판단)
    func saveNote(_ note: Note, isShared: Bool, zoneID: CKRecordZone.ID? = nil) async throws -> Note {
        if isShared {
            guard let zoneID = zoneID else {
                throw CloudKitError.unknown(NSError(domain: "CloudKit", code: -1))
            }
            return try await updateSharedNote(note, in: zoneID)
        } else {
            return try await saveNote(note)
        }
    }
}
