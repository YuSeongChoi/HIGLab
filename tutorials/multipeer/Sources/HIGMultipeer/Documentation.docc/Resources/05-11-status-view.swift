import SwiftUI
import MultipeerConnectivity

struct ConnectionStatusView: View {
    @ObservedObject var sessionManager: SessionManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(statusColor)
                    .frame(width: 12, height: 12)
                
                Text(statusText)
                    .font(.headline)
            }
            
            if !sessionManager.connectedPeers.isEmpty {
                ForEach(sessionManager.connectedPeers, id: \.self) { peer in
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .foregroundStyle(.green)
                        Text(peer.displayName)
                    }
                    .font(.subheadline)
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var statusColor: Color {
        sessionManager.connectedPeers.isEmpty ? .orange : .green
    }
    
    private var statusText: String {
        let count = sessionManager.connectedPeers.count
        switch count {
        case 0: return "연결된 기기 없음"
        case 1: return "1개 기기 연결됨"
        default: return "\(count)개 기기 연결됨"
        }
    }
}
