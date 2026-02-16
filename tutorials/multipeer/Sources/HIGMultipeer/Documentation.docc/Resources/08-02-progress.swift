import MultipeerConnectivity
import Combine

class ResourceManager: ObservableObject {
    
    let session: MCSession
    
    @Published var transferProgress: Double = 0
    @Published var isTransferring = false
    
    private var progressObservation: NSKeyValueObservation?
    
    init(session: MCSession) {
        self.session = session
    }
    
    func sendFile(at url: URL, to peer: MCPeerID) {
        isTransferring = true
        
        let progress = session.sendResource(
            at: url,
            withName: url.lastPathComponent,
            toPeer: peer
        ) { [weak self] error in
            DispatchQueue.main.async {
                self?.isTransferring = false
                self?.progressObservation = nil
                
                if let error = error {
                    print("전송 실패: \(error)")
                }
            }
        }
        
        // Progress 관찰
        progressObservation = progress?.observe(\.fractionCompleted) { [weak self] progress, _ in
            DispatchQueue.main.async {
                self?.transferProgress = progress.fractionCompleted
            }
        }
    }
}
