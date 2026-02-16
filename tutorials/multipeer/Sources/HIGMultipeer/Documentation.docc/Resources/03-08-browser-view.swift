import SwiftUI
import MultipeerConnectivity

struct BrowserView: View {
    @ObservedObject var browserManager: BrowserManager
    @ObservedObject var sessionManager: SessionManager
    
    var body: some View {
        NavigationStack {
            List {
                if browserManager.availablePeers.isEmpty {
                    ContentUnavailableView(
                        "주변 기기 없음",
                        systemImage: "antenna.radiowaves.left.and.right",
                        description: Text("같은 앱을 실행 중인 기기를 찾고 있습니다...")
                    )
                } else {
                    ForEach(browserManager.availablePeers, id: \.self) { peer in
                        PeerRow(
                            peer: peer,
                            onInvite: {
                                browserManager.invitePeer(peer, to: sessionManager.session)
                            }
                        )
                    }
                }
            }
            .navigationTitle("주변 기기")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        if browserManager.isBrowsing {
                            browserManager.stopBrowsing()
                        } else {
                            browserManager.startBrowsing()
                        }
                    } label: {
                        Image(systemName: browserManager.isBrowsing ? "stop.circle" : "arrow.clockwise")
                    }
                }
            }
        }
    }
}
