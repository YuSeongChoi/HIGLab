import Foundation

struct Call: Identifiable {
    let id: UUID
    let handle: String
    let isOutgoing: Bool
    let hasVideo: Bool
    
    var isConnected: Bool = false
    var isOnHold: Bool = false
    var isMuted: Bool = false
    
    var connectedAt: Date?
    
    init(
        uuid: UUID = UUID(),
        handle: String,
        isOutgoing: Bool,
        hasVideo: Bool = false
    ) {
        self.id = uuid
        self.handle = handle
        self.isOutgoing = isOutgoing
        self.hasVideo = hasVideo
    }
}
