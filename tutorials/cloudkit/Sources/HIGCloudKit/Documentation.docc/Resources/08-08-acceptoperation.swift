import CloudKit

extension CloudKitManager {
    
    /// 공유 수락
    func acceptShare(metadata: CKShare.Metadata) async throws {
        let operation = CKAcceptSharesOperation(shareMetadatas: [metadata])
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            operation.perShareResultBlock = { metadata, result in
                switch result {
                case .success:
                    print("✅ Accepted share: \(metadata.share.recordID)")
                case .failure(let error):
                    print("❌ Failed to accept: \(error)")
                }
            }
            
            operation.acceptSharesResultBlock = { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            
            container.add(operation)
        }
    }
}
