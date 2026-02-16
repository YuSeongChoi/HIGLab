import SwiftUI
import MultipeerConnectivity

struct FileShareView: View {
    @ObservedObject var resourceManager: ResourceManager
    @ObservedObject var sessionManager: SessionManager
    @ObservedObject var transferHistory: TransferHistory
    
    @State private var selectedPeer: MCPeerID?
    
    var body: some View {
        NavigationStack {
            List {
                // 연결된 피어 섹션
                Section("연결된 기기") {
                    ForEach(sessionManager.connectedPeers, id: \.self) { peer in
                        HStack {
                            Image(systemName: "iphone")
                            Text(peer.displayName)
                            Spacer()
                            Button("전송") {
                                selectedPeer = peer
                            }
                            .buttonStyle(.borderedProminent)
                            .buttonBorderShape(.capsule)
                        }
                    }
                }
                
                // 수신된 파일 섹션
                Section("받은 파일") {
                    ForEach(resourceManager.receivedFiles) { file in
                        HStack {
                            Image(systemName: "doc.fill")
                                .foregroundStyle(.blue)
                            VStack(alignment: .leading) {
                                Text(file.name)
                                    .font(.headline)
                                Text("\(file.fromPeer)님으로부터")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                
                // 전송 기록 섹션
                Section("전송 기록") {
                    ForEach(transferHistory.records) { record in
                        HStack {
                            Image(systemName: record.direction == .sent ? "arrow.up" : "arrow.down")
                                .foregroundStyle(record.direction == .sent ? .blue : .green)
                            
                            VStack(alignment: .leading) {
                                Text(record.fileName)
                                Text(record.peerName)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            statusIcon(for: record.status)
                        }
                    }
                }
            }
            .navigationTitle("파일 공유")
            .sheet(item: $selectedPeer) { peer in
                FilePickerView(resourceManager: resourceManager, targetPeer: peer)
            }
        }
    }
    
    private func statusIcon(for status: TransferHistory.TransferRecord.Status) -> some View {
        switch status {
        case .inProgress:
            return Image(systemName: "arrow.triangle.2.circlepath").foregroundStyle(.orange)
        case .completed:
            return Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
        case .failed:
            return Image(systemName: "xmark.circle.fill").foregroundStyle(.red)
        }
    }
}

extension MCPeerID: @retroactive Identifiable {
    public var id: String { displayName }
}
