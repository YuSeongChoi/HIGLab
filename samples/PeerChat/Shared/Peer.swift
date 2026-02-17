// Peer.swift
// PeerChat - MultipeerConnectivity 기반 P2P 채팅
// 피어 모델 정의

import Foundation
import MultipeerConnectivity

/// 피어 연결 상태
enum PeerConnectionState: String, Codable {
    case notConnected   // 연결 안 됨
    case connecting     // 연결 중
    case connected      // 연결됨
    
    /// MCSessionState에서 변환
    init(from sessionState: MCSessionState) {
        switch sessionState {
        case .notConnected:
            self = .notConnected
        case .connecting:
            self = .connecting
        case .connected:
            self = .connected
        @unknown default:
            self = .notConnected
        }
    }
    
    /// 표시 텍스트
    var displayText: String {
        switch self {
        case .notConnected:
            return "연결 안 됨"
        case .connecting:
            return "연결 중..."
        case .connected:
            return "연결됨"
        }
    }
    
    /// 상태 색상 이름
    var colorName: String {
        switch self {
        case .notConnected:
            return "gray"
        case .connecting:
            return "orange"
        case .connected:
            return "green"
        }
    }
}

/// 발견된 피어 정보
struct DiscoveredPeer: Identifiable, Equatable, Hashable {
    let id: String              // 피어 고유 ID
    let peerID: MCPeerID        // MultipeerConnectivity 피어 ID
    var displayName: String     // 표시 이름
    var state: PeerConnectionState  // 연결 상태
    var discoveryInfo: [String: String]?  // 발견 정보
    var lastSeen: Date          // 마지막으로 발견된 시간
    
    init(peerID: MCPeerID, discoveryInfo: [String: String]? = nil) {
        self.id = peerID.displayName
        self.peerID = peerID
        self.displayName = discoveryInfo?["displayName"] ?? peerID.displayName
        self.state = .notConnected
        self.discoveryInfo = discoveryInfo
        self.lastSeen = Date()
    }
    
    static func == (lhs: DiscoveredPeer, rhs: DiscoveredPeer) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    /// 기기 타입 아이콘
    var deviceIcon: String {
        guard let info = discoveryInfo,
              let deviceType = info["deviceType"] else {
            return "iphone"
        }
        
        switch deviceType {
        case "iPhone":
            return "iphone"
        case "iPad":
            return "ipad"
        case "Mac":
            return "laptopcomputer"
        default:
            return "desktopcomputer"
        }
    }
}

/// 연결된 피어 세션 정보
struct PeerSession: Identifiable {
    let id: String
    let peer: DiscoveredPeer
    var isTyping: Bool          // 타이핑 중 여부
    var unreadCount: Int        // 읽지 않은 메시지 수
    var lastMessage: ChatMessage?  // 마지막 메시지
    
    init(peer: DiscoveredPeer) {
        self.id = peer.id
        self.peer = peer
        self.isTyping = false
        self.unreadCount = 0
        self.lastMessage = nil
    }
}

/// 피어 초대 정보
struct PeerInvitation: Identifiable {
    let id: UUID
    let peerID: MCPeerID
    let invitationHandler: (Bool, MCSession?) -> Void
    let timestamp: Date
    
    init(
        peerID: MCPeerID,
        invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        self.id = UUID()
        self.peerID = peerID
        self.invitationHandler = invitationHandler
        self.timestamp = Date()
    }
    
    /// 초대 수락
    func accept(session: MCSession) {
        invitationHandler(true, session)
    }
    
    /// 초대 거절
    func decline() {
        invitationHandler(false, nil)
    }
}

/// 그룹 세션 정보
struct GroupSession: Identifiable, Codable {
    let id: UUID
    var name: String            // 그룹 이름
    var createdAt: Date         // 생성 시간
    var memberIDs: [String]     // 멤버 피어 ID 목록
    var isActive: Bool          // 활성 상태
    
    init(name: String, memberIDs: [String] = []) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
        self.memberIDs = memberIDs
        self.isActive = true
    }
    
    /// 멤버 수
    var memberCount: Int {
        memberIDs.count
    }
    
    /// 멤버 추가
    mutating func addMember(_ peerID: String) {
        if !memberIDs.contains(peerID) {
            memberIDs.append(peerID)
        }
    }
    
    /// 멤버 제거
    mutating func removeMember(_ peerID: String) {
        memberIDs.removeAll { $0 == peerID }
    }
}
