// MultipeerService.swift
// PeerChat - MultipeerConnectivity 기반 P2P 채팅
// MultipeerConnectivity 핵심 서비스

import Foundation
import MultipeerConnectivity
import Combine
import os.log

/// MultipeerConnectivity 서비스 관리자
@MainActor
class MultipeerService: NSObject, ObservableObject {
    // MARK: - Published Properties
    
    /// 로컬 기기 표시 이름
    @Published var localDisplayName: String {
        didSet {
            UserDefaults.standard.set(localDisplayName, forKey: "userName")
            restartServices()
        }
    }
    
    /// 발견된 피어 목록
    @Published private(set) var discoveredPeers: [DiscoveredPeer] = []
    
    /// 연결된 피어 목록
    @Published private(set) var connectedPeers: [DiscoveredPeer] = []
    
    /// 대기 중인 초대 목록
    @Published private(set) var pendingInvitations: [PeerInvitation] = []
    
    /// 메시지 저장소 (피어 ID -> 메시지 배열)
    @Published private(set) var messages: [String: [ChatMessage]] = [:]
    
    /// 읽지 않은 메시지 수 (피어 ID -> 카운트)
    @Published private(set) var unreadCounts: [String: Int] = [:]
    
    /// 그룹 세션 목록
    @Published private(set) var groupSessions: [GroupSession] = []
    
    /// 광고 중 여부
    @Published private(set) var isAdvertising = false
    
    /// 탐색 중 여부
    @Published private(set) var isBrowsing = false
    
    // MARK: - Private Properties
    
    /// 로컬 피어 ID
    private var localPeerID: MCPeerID
    
    /// 세션 (피어 연결 관리)
    private var session: MCSession!
    
    /// 서비스 광고자 (다른 기기에 자신을 알림)
    private var advertiser: MCNearbyServiceAdvertiser?
    
    /// 서비스 탐색자 (주변 기기 탐색)
    private var browser: MCNearbyServiceBrowser?
    
    /// 세션 고유 ID
    private let sessionID = UUID().uuidString
    
    /// 로거
    private let logger = Logger(subsystem: "com.higlab.peerchat", category: "MultipeerService")
    
    // MARK: - Computed Properties
    
    /// 총 읽지 않은 메시지 수
    var totalUnreadCount: Int {
        unreadCounts.values.reduce(0, +)
    }
    
    // MARK: - Initialization
    
    override init() {
        // 저장된 이름 또는 기기 이름 사용
        let savedName = UserDefaults.standard.string(forKey: "userName")
            ?? ProcessInfo.processInfo.hostName
        self.localDisplayName = savedName
        self.localPeerID = MCPeerID(displayName: savedName)
        
        super.init()
        
        setupSession()
    }
    
    // MARK: - Session Setup
    
    /// 세션 초기화
    private func setupSession() {
        session = MCSession(
            peer: localPeerID,
            securityIdentity: nil,
            encryptionPreference: .required
        )
        session.delegate = self
    }
    
    // MARK: - Service Control
    
    /// 모든 서비스 시작
    func startServices() {
        startAdvertising()
        startBrowsing()
    }
    
    /// 모든 서비스 중지
    func stopServices() {
        stopAdvertising()
        stopBrowsing()
    }
    
    /// 서비스 재시작
    func restartServices() {
        stopServices()
        
        // 새 피어 ID로 세션 재생성
        localPeerID = MCPeerID(displayName: localDisplayName)
        setupSession()
        
        startServices()
    }
    
    /// 광고 시작
    func startAdvertising() {
        guard !isAdvertising else { return }
        
        let discoveryInfo = PeerChatService.makeDiscoveryInfo(
            displayName: localDisplayName,
            sessionID: sessionID
        )
        
        advertiser = MCNearbyServiceAdvertiser(
            peer: localPeerID,
            discoveryInfo: discoveryInfo,
            serviceType: PeerChatService.serviceType
        )
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
        
        isAdvertising = true
        logger.info("광고 시작: \(self.localDisplayName)")
    }
    
    /// 광고 중지
    func stopAdvertising() {
        advertiser?.stopAdvertisingPeer()
        advertiser = nil
        isAdvertising = false
        logger.info("광고 중지")
    }
    
    /// 탐색 시작
    func startBrowsing() {
        guard !isBrowsing else { return }
        
        browser = MCNearbyServiceBrowser(
            peer: localPeerID,
            serviceType: PeerChatService.serviceType
        )
        browser?.delegate = self
        browser?.startBrowsingForPeers()
        
        isBrowsing = true
        logger.info("탐색 시작")
    }
    
    /// 탐색 중지
    func stopBrowsing() {
        browser?.stopBrowsingForPeers()
        browser = nil
        isBrowsing = false
        discoveredPeers.removeAll()
        logger.info("탐색 중지")
    }
    
    // MARK: - Peer Interaction
    
    /// 피어에게 연결 초대 보내기
    func invitePeer(_ peer: DiscoveredPeer) {
        guard let browser = browser else { return }
        
        // 초대 컨텍스트 데이터
        let context = try? JSONEncoder().encode([
            "displayName": localDisplayName,
            "sessionID": sessionID
        ])
        
        browser.invitePeer(
            peer.peerID,
            to: session,
            withContext: context,
            timeout: 30
        )
        
        // 상태 업데이트
        if let index = discoveredPeers.firstIndex(where: { $0.id == peer.id }) {
            discoveredPeers[index].state = .connecting
        }
        
        logger.info("초대 전송: \(peer.displayName)")
    }
    
    /// 초대 수락
    func acceptInvitation(_ invitation: PeerInvitation) {
        invitation.accept(session: session)
        pendingInvitations.removeAll { $0.id == invitation.id }
        logger.info("초대 수락: \(invitation.peerID.displayName)")
    }
    
    /// 초대 거절
    func declineInvitation(_ invitation: PeerInvitation) {
        invitation.decline()
        pendingInvitations.removeAll { $0.id == invitation.id }
        logger.info("초대 거절: \(invitation.peerID.displayName)")
    }
    
    /// 피어 연결 해제
    func disconnectPeer(_ peer: DiscoveredPeer) {
        // 세션에서는 개별 피어 연결 해제가 불가하므로
        // 연결된 피어 목록에서만 제거
        connectedPeers.removeAll { $0.id == peer.id }
        logger.info("피어 연결 해제: \(peer.displayName)")
    }
    
    // MARK: - Messaging
    
    /// 텍스트 메시지 전송
    func sendMessage(_ text: String, to peer: DiscoveredPeer) throws {
        let message = ChatMessage.text(
            senderID: localPeerID.displayName,
            senderName: localDisplayName,
            content: text
        )
        
        try sendChatMessage(message, to: [peer])
        
        // 로컬 메시지 저장
        appendMessage(message, for: peer.id)
    }
    
    /// 그룹에 텍스트 메시지 전송
    func sendMessage(_ text: String, toGroup groupID: UUID) throws {
        guard let group = groupSessions.first(where: { $0.id == groupID }) else {
            throw PeerChatError.sessionNotFound
        }
        
        let message = ChatMessage.text(
            senderID: localPeerID.displayName,
            senderName: localDisplayName,
            content: text
        )
        
        let targetPeers = connectedPeers.filter { group.memberIDs.contains($0.id) }
        try sendChatMessage(message, to: targetPeers)
        
        // 그룹 ID로 메시지 저장
        appendMessage(message, for: groupID.uuidString)
    }
    
    /// 파일 전송
    func sendFile(_ data: Data, fileName: String, mimeType: String, to peer: DiscoveredPeer) throws {
        // 파일 크기 제한 (10MB)
        let maxSize = 10 * 1024 * 1024
        guard data.count <= maxSize else {
            throw PeerChatError.fileTooLarge(maxSize: maxSize)
        }
        
        let message = ChatMessage.file(
            senderID: localPeerID.displayName,
            senderName: localDisplayName,
            fileName: fileName,
            fileData: data,
            mimeType: mimeType
        )
        
        try sendChatMessage(message, to: [peer])
        appendMessage(message, for: peer.id)
    }
    
    /// ChatMessage 전송 (내부)
    private func sendChatMessage(_ message: ChatMessage, to peers: [DiscoveredPeer]) throws {
        let wrapper = MessageWrapper(message: message, sessionID: sessionID)
        
        guard let data = wrapper.encoded() else {
            throw PeerChatError.encodingFailed
        }
        
        let peerIDs = peers.map { $0.peerID }
        
        do {
            try session.send(data, toPeers: peerIDs, with: .reliable)
            logger.debug("메시지 전송 완료: \(message.type.rawValue)")
        } catch {
            logger.error("메시지 전송 실패: \(error.localizedDescription)")
            throw PeerChatError.sendFailed(underlying: error)
        }
    }
    
    /// 메시지 저장
    private func appendMessage(_ message: ChatMessage, for peerID: String) {
        if messages[peerID] == nil {
            messages[peerID] = []
        }
        messages[peerID]?.append(message)
    }
    
    // MARK: - Message Helpers
    
    /// 특정 피어의 마지막 메시지
    func lastMessage(for peerID: String) -> ChatMessage? {
        messages[peerID]?.last
    }
    
    /// 특정 피어의 읽지 않은 메시지 수
    func unreadCount(for peerID: String) -> Int? {
        unreadCounts[peerID]
    }
    
    /// 읽음 처리
    func markAsRead(for peerID: String) {
        unreadCounts[peerID] = 0
    }
    
    /// 특정 피어의 메시지 목록
    func getMessages(for peerID: String) -> [ChatMessage] {
        messages[peerID] ?? []
    }
    
    // MARK: - Group Session Management
    
    /// 그룹 세션 생성
    func createGroupSession(name: String, members: [DiscoveredPeer]) -> GroupSession {
        var group = GroupSession(name: name)
        for member in members {
            group.addMember(member.id)
        }
        groupSessions.append(group)
        logger.info("그룹 생성: \(name), 멤버 수: \(members.count)")
        return group
    }
    
    /// 그룹에 멤버 추가
    func addMemberToGroup(_ peer: DiscoveredPeer, groupID: UUID) {
        if let index = groupSessions.firstIndex(where: { $0.id == groupID }) {
            groupSessions[index].addMember(peer.id)
        }
    }
    
    /// 그룹에서 멤버 제거
    func removeMemberFromGroup(_ peerID: String, groupID: UUID) {
        if let index = groupSessions.firstIndex(where: { $0.id == groupID }) {
            groupSessions[index].removeMember(peerID)
        }
    }
    
    /// 그룹 삭제
    func deleteGroup(_ groupID: UUID) {
        groupSessions.removeAll { $0.id == groupID }
    }
}

// MARK: - MCSessionDelegate

extension MultipeerService: MCSessionDelegate {
    nonisolated func session(
        _ session: MCSession,
        peer peerID: MCPeerID,
        didChange state: MCSessionState
    ) {
        Task { @MainActor in
            logger.info("피어 상태 변경: \(peerID.displayName) -> \(state.rawValue)")
            
            let connectionState = PeerConnectionState(from: state)
            
            // 발견된 피어 상태 업데이트
            if let index = discoveredPeers.firstIndex(where: { $0.peerID == peerID }) {
                discoveredPeers[index].state = connectionState
            }
            
            // 연결된 피어 목록 업데이트
            switch state {
            case .connected:
                if !connectedPeers.contains(where: { $0.peerID == peerID }) {
                    let peer = DiscoveredPeer(peerID: peerID)
                    var connectedPeer = peer
                    connectedPeer.state = .connected
                    connectedPeers.append(connectedPeer)
                    
                    // 시스템 메시지 추가
                    let systemMsg = ChatMessage.system(content: "\(peerID.displayName)님이 연결되었습니다")
                    appendMessage(systemMsg, for: peerID.displayName)
                }
                
            case .notConnected:
                connectedPeers.removeAll { $0.peerID == peerID }
                
                // 시스템 메시지 추가
                let systemMsg = ChatMessage.system(content: "\(peerID.displayName)님의 연결이 끊어졌습니다")
                appendMessage(systemMsg, for: peerID.displayName)
                
            case .connecting:
                break
                
            @unknown default:
                break
            }
        }
    }
    
    nonisolated func session(
        _ session: MCSession,
        didReceive data: Data,
        fromPeer peerID: MCPeerID
    ) {
        Task { @MainActor in
            guard let wrapper = MessageWrapper.decoded(from: data) else {
                logger.error("메시지 디코딩 실패")
                return
            }
            
            let message = wrapper.message
            logger.debug("메시지 수신: \(message.type.rawValue) from \(peerID.displayName)")
            
            // 메시지 저장
            appendMessage(message, for: peerID.displayName)
            
            // 읽지 않은 메시지 카운트 증가
            unreadCounts[peerID.displayName, default: 0] += 1
        }
    }
    
    nonisolated func session(
        _ session: MCSession,
        didReceive stream: InputStream,
        withName streamName: String,
        fromPeer peerID: MCPeerID
    ) {
        // 스트림 수신 (현재 미사용)
        Task { @MainActor in
            logger.debug("스트림 수신: \(streamName) from \(peerID.displayName)")
        }
    }
    
    nonisolated func session(
        _ session: MCSession,
        didStartReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        with progress: Progress
    ) {
        Task { @MainActor in
            logger.info("리소스 수신 시작: \(resourceName)")
        }
    }
    
    nonisolated func session(
        _ session: MCSession,
        didFinishReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        at localURL: URL?,
        withError error: Error?
    ) {
        Task { @MainActor in
            if let error = error {
                logger.error("리소스 수신 실패: \(error.localizedDescription)")
            } else {
                logger.info("리소스 수신 완료: \(resourceName)")
            }
        }
    }
}

// MARK: - MCNearbyServiceAdvertiserDelegate

extension MultipeerService: MCNearbyServiceAdvertiserDelegate {
    nonisolated func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?,
        invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        Task { @MainActor in
            logger.info("초대 수신: \(peerID.displayName)")
            
            let invitation = PeerInvitation(
                peerID: peerID,
                invitationHandler: invitationHandler
            )
            pendingInvitations.append(invitation)
        }
    }
    
    nonisolated func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didNotStartAdvertisingPeer error: Error
    ) {
        Task { @MainActor in
            logger.error("광고 시작 실패: \(error.localizedDescription)")
            isAdvertising = false
        }
    }
}

// MARK: - MCNearbyServiceBrowserDelegate

extension MultipeerService: MCNearbyServiceBrowserDelegate {
    nonisolated func browser(
        _ browser: MCNearbyServiceBrowser,
        foundPeer peerID: MCPeerID,
        withDiscoveryInfo info: [String: String]?
    ) {
        Task { @MainActor in
            logger.info("피어 발견: \(peerID.displayName)")
            
            // 자기 자신은 제외
            guard peerID != localPeerID else { return }
            
            // 이미 발견된 피어인지 확인
            if let index = discoveredPeers.firstIndex(where: { $0.peerID == peerID }) {
                discoveredPeers[index].lastSeen = Date()
                discoveredPeers[index].discoveryInfo = info
            } else {
                let peer = DiscoveredPeer(peerID: peerID, discoveryInfo: info)
                discoveredPeers.append(peer)
            }
        }
    }
    
    nonisolated func browser(
        _ browser: MCNearbyServiceBrowser,
        lostPeer peerID: MCPeerID
    ) {
        Task { @MainActor in
            logger.info("피어 손실: \(peerID.displayName)")
            
            // 연결되지 않은 피어만 제거
            discoveredPeers.removeAll {
                $0.peerID == peerID && $0.state == .notConnected
            }
        }
    }
    
    nonisolated func browser(
        _ browser: MCNearbyServiceBrowser,
        didNotStartBrowsingForPeers error: Error
    ) {
        Task { @MainActor in
            logger.error("탐색 시작 실패: \(error.localizedDescription)")
            isBrowsing = false
        }
    }
}
