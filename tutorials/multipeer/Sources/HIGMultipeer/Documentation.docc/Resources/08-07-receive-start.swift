import MultipeerConnectivity

extension ResourceManager: MCSessionDelegate {
    
    func session(
        _ session: MCSession,
        didStartReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        with progress: Progress
    ) {
        print("수신 시작: '\(resourceName)' from \(peerID.displayName)")
        print("예상 크기: \(progress.totalUnitCount) bytes")
        
        // 수신 정보 저장
        let receiveInfo = ReceiveInfo(
            resourceName: resourceName,
            fromPeer: peerID,
            progress: progress
        )
        
        DispatchQueue.main.async {
            self.receivingResources.append(receiveInfo)
        }
        
        // Progress 관찰
        progress.observe(\.fractionCompleted) { [weak self] prog, _ in
            DispatchQueue.main.async {
                if let index = self?.receivingResources.firstIndex(where: { $0.resourceName == resourceName && $0.fromPeer == peerID }) {
                    self?.receivingResources[index].currentProgress = prog.fractionCompleted
                }
            }
        }
    }
    
    // 수신 정보 구조체
    struct ReceiveInfo: Identifiable {
        let id = UUID()
        let resourceName: String
        let fromPeer: MCPeerID
        let progress: Progress
        var currentProgress: Double = 0
    }
    
    @Published var receivingResources: [ReceiveInfo] = []
}
