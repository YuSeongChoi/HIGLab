import MultipeerConnectivity

class ResourceManager: ObservableObject {
    
    let session: MCSession
    
    // 파일 전송
    func sendFile(at fileURL: URL, to peer: MCPeerID, completion: @escaping (Error?) -> Void) -> Progress? {
        // 파일 존재 확인
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            completion(ResourceError.fileNotFound)
            return nil
        }
        
        return session.sendResource(
            at: fileURL,
            withName: fileURL.lastPathComponent,
            toPeer: peer,
            withCompletionHandler: completion
        )
    }
    
    // 문서 디렉터리의 파일 전송
    func sendDocumentFile(named fileName: String, to peer: MCPeerID) -> Progress? {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let fileURL = documentsURL.appendingPathComponent(fileName)
        
        return sendFile(at: fileURL, to: peer) { error in
            if let error = error {
                print("전송 실패: \(error)")
            }
        }
    }
}

enum ResourceError: Error {
    case fileNotFound
    case saveFailed
}
