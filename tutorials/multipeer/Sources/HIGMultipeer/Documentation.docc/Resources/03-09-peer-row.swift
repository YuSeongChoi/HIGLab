import SwiftUI
import MultipeerConnectivity

struct PeerRow: View {
    let peer: MCPeerID
    let onInvite: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "iphone")
                .font(.title2)
                .foregroundStyle(.blue)
            
            VStack(alignment: .leading) {
                Text(peer.displayName)
                    .font(.headline)
                
                Text("연결 가능")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button("초대") {
                onInvite()
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
        }
        .padding(.vertical, 4)
    }
}
