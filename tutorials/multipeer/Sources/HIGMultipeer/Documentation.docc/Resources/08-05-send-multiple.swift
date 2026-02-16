import MultipeerConnectivity

class ResourceManager: ObservableObject {
    
    let session: MCSession
    
    @Published var transfers: [TransferInfo] = []
    
    struct TransferInfo: Identifiable {
        let id = UUID()
        let fileName: String
        let peer: MCPeerID
        var progress: Double = 0
        var isCompleted = false
        var error: Error?
    }
    
    // 여러 피어에게 파일 전송
    func sendFileToAll(at url: URL) {
        for peer in session.connectedPeers {
            sendFile(at: url, to: peer)
        }
    }
    
    // 여러 파일 전송
    func sendFiles(at urls: [URL], to peer: MCPeerID) {
        for url in urls {
            sendFile(at: url, to: peer)
        }
    }
    
    private func sendFile(at url: URL, to peer: MCPeerID) {
        var info = TransferInfo(fileName: url.lastPathComponent, peer: peer)
        
        let progress = session.sendResource(
            at: url,
            withName: url.lastPathComponent,
            toPeer: peer
        ) { [weak self] error in
            DispatchQueue.main.async {
                if let index = self?.transfers.firstIndex(where: { $0.id == info.id }) {
                    self?.transfers[index].isCompleted = true
                    self?.transfers[index].error = error
                }
            }
        }
        
        // Progress 관찰
        progress?.observe(\.fractionCompleted) { [weak self] prog, _ in
            DispatchQueue.main.async {
                if let index = self?.transfers.firstIndex(where: { $0.id == info.id }) {
                    self?.transfers[index].progress = prog.fractionCompleted
                }
            }
        }
        
        transfers.append(info)
    }
}
