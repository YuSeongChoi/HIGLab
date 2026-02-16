import MultipeerConnectivity

class ResourceManager: ObservableObject {
    
    @Published var receivedFiles: [ReceivedFile] = []
    
    struct ReceivedFile: Identifiable {
        let id = UUID()
        let name: String
        let url: URL
        let receivedAt: Date
        let fromPeer: String
    }
    
    // 수신된 파일을 문서 디렉터리에 저장
    private func saveReceivedFile(from tempURL: URL, named name: String, from peer: MCPeerID) {
        guard let documentsURL = FileManager.default.urls(
            for: .documentDirectory, 
            in: .userDomainMask
        ).first else {
            return
        }
        
        // 파일 이름 중복 처리
        var destinationURL = documentsURL.appendingPathComponent(name)
        var counter = 1
        
        while FileManager.default.fileExists(atPath: destinationURL.path) {
            let nameWithoutExtension = (name as NSString).deletingPathExtension
            let ext = (name as NSString).pathExtension
            let newName = "\(nameWithoutExtension)_\(counter).\(ext)"
            destinationURL = documentsURL.appendingPathComponent(newName)
            counter += 1
        }
        
        do {
            // 임시 파일을 영구 위치로 이동
            try FileManager.default.moveItem(at: tempURL, to: destinationURL)
            
            let receivedFile = ReceivedFile(
                name: destinationURL.lastPathComponent,
                url: destinationURL,
                receivedAt: Date(),
                fromPeer: peer.displayName
            )
            
            DispatchQueue.main.async {
                self.receivedFiles.append(receivedFile)
            }
            
            print("파일 저장 완료: \(destinationURL)")
        } catch {
            print("파일 저장 실패: \(error)")
        }
    }
}
