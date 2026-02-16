import MultipeerConnectivity
import SwiftUI

class ChatManager: ObservableObject {
    
    @Published var messages: [ChatMessage] = []
    
    private let session: MCSession
    private let myPeerID: MCPeerID
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    init(session: MCSession, myPeerID: MCPeerID) {
        self.session = session
        self.myPeerID = myPeerID
    }
    
    // 텍스트 메시지 전송
    func sendText(_ text: String) {
        let message = ChatMessage(sender: myPeerID, type: .text, content: text)
        
        do {
            let data = try encoder.encode(message)
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            
            // 내 메시지 목록에 추가
            var myMessage = message
            myMessage.isFromMe = true
            DispatchQueue.main.async {
                self.messages.append(myMessage)
            }
        } catch {
            print("전송 실패: \(error)")
        }
    }
    
    // 메시지 수신 처리
    func handleReceivedData(_ data: Data, from peer: MCPeerID) {
        guard let message = try? decoder.decode(ChatMessage.self, from: data) else {
            return
        }
        
        DispatchQueue.main.async {
            self.messages.append(message)
        }
    }
}
