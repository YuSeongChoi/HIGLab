import CloudKit

extension CloudKitManager {
    
    /// Shared Database 참조
    var sharedDatabase: CKDatabase {
        container.sharedCloudDatabase
    }
}
