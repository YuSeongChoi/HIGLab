import Foundation
import MultipeerConnectivity

// 전송/수신 기록 관리
class TransferHistory: ObservableObject {
    
    @Published var records: [TransferRecord] = []
    
    struct TransferRecord: Identifiable, Codable {
        let id: UUID
        let fileName: String
        let peerName: String
        let direction: Direction
        let timestamp: Date
        let fileSize: Int64
        var status: Status
        
        enum Direction: String, Codable {
            case sent
            case received
        }
        
        enum Status: String, Codable {
            case inProgress
            case completed
            case failed
        }
    }
    
    func addSentRecord(fileName: String, to peer: MCPeerID, size: Int64) -> UUID {
        let record = TransferRecord(
            id: UUID(),
            fileName: fileName,
            peerName: peer.displayName,
            direction: .sent,
            timestamp: Date(),
            fileSize: size,
            status: .inProgress
        )
        records.insert(record, at: 0)
        return record.id
    }
    
    func addReceivedRecord(fileName: String, from peer: MCPeerID, size: Int64) -> UUID {
        let record = TransferRecord(
            id: UUID(),
            fileName: fileName,
            peerName: peer.displayName,
            direction: .received,
            timestamp: Date(),
            fileSize: size,
            status: .inProgress
        )
        records.insert(record, at: 0)
        return record.id
    }
    
    func updateStatus(_ id: UUID, status: TransferRecord.Status) {
        if let index = records.firstIndex(where: { $0.id == id }) {
            records[index].status = status
        }
    }
}
