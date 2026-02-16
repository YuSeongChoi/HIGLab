import MultipeerConnectivity

class DataManager: NSObject {
    
    let session: MCSession
    private let decoder = JSONDecoder()
    
    var onMessageReceived: ((Message, MCPeerID) -> Void)?
    
    init(session: MCSession) {
        self.session = session
        super.init()
    }
    
    // 수신된 데이터 처리
    func handleReceivedData(_ data: Data, from peer: MCPeerID) {
        do {
            let message = try decoder.decode(Message.self, from: data)
            
            DispatchQueue.main.async {
                self.onMessageReceived?(message, peer)
            }
        } catch {
            print("메시지 디코딩 실패: \(error)")
            
            // 문자열로 시도
            if let text = String(data: data, encoding: .utf8) {
                let fallbackMessage = Message(type: .text, content: text)
                DispatchQueue.main.async {
                    self.onMessageReceived?(fallbackMessage, peer)
                }
            }
        }
    }
}
