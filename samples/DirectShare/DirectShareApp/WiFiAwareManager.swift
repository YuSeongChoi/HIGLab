// WiFiAwareManager.swift
// DirectShare - Wi-Fi Aware 직접 파일 공유
// Wi-Fi Aware 핵심 매니저: 피어 발견, 연결, 통신

import Foundation
import Network
import Observation

/// Wi-Fi Aware 네트워크 매니저
/// iOS 26의 NWBrowser/NWListener를 Wi-Fi Aware 모드로 사용
@Observable
final class WiFiAwareManager: @unchecked Sendable {
    
    // MARK: - 상태
    
    /// 발견된 피어 목록
    private(set) var discoveredPeers: [Peer] = []
    
    /// 현재 앱 연결 상태
    private(set) var connectionState: AppConnectionState = .idle
    
    /// Wi-Fi Aware 사용 가능 여부
    private(set) var isWiFiAwareAvailable = false
    
    /// 스캔 중인지 여부
    private(set) var isScanning = false
    
    /// 광고 중인지 여부
    private(set) var isAdvertising = false
    
    // MARK: - Network 객체
    
    /// 피어 검색용 브라우저
    private var browser: NWBrowser?
    
    /// 서비스 광고용 리스너
    private var listener: NWListener?
    
    /// 활성 연결들
    private var activeConnections: [UUID: NWConnection] = [:]
    
    /// 네트워크 큐
    private let networkQueue = DispatchQueue(label: "com.directshare.network", qos: .userInitiated)
    
    /// 연결 이벤트 콜백
    var onConnectionEvent: ((ConnectionEvent) -> Void)?
    
    /// 메시지 수신 콜백
    var onMessageReceived: ((Peer, PeerMessage) -> Void)?
    
    // MARK: - 초기화
    
    init() {
        checkWiFiAwareAvailability()
    }
    
    deinit {
        stopAll()
    }
    
    // MARK: - Wi-Fi Aware 가용성 확인
    
    /// Wi-Fi Aware 지원 확인
    private func checkWiFiAwareAvailability() {
        // iOS 26+에서 Wi-Fi Aware 파라미터 확인
        // 실제 기기에서만 정확한 가용성 판단 가능
        #if os(iOS)
        if #available(iOS 26, *) {
            isWiFiAwareAvailable = true
        } else {
            isWiFiAwareAvailable = false
        }
        #else
        isWiFiAwareAvailable = false
        #endif
    }
    
    // MARK: - 피어 검색 (NWBrowser)
    
    /// Wi-Fi Aware로 주변 피어 검색 시작
    func startScanning() {
        guard !isScanning else { return }
        
        // Wi-Fi Aware 브라우저 파라미터 구성
        // iOS 26의 새로운 includePeerToPeer 및 wifiAware 옵션 사용
        let parameters = NWParameters()
        parameters.includePeerToPeer = true
        
        // Wi-Fi Aware 전용 설정 (iOS 26+)
        if #available(iOS 26, *) {
            parameters.requiredInterface = .wifiAware
        }
        
        // 브라우저 생성 - Bonjour 서비스 탐색
        let descriptor = NWBrowser.Descriptor.bonjour(
            type: AppConstants.serviceType,
            domain: "local."
        )
        
        browser = NWBrowser(for: descriptor, using: parameters)
        
        // 브라우저 상태 핸들러
        browser?.stateUpdateHandler = { [weak self] state in
            self?.handleBrowserState(state)
        }
        
        // 브라우저 결과 핸들러 - 피어 발견/손실
        browser?.browseResultsChangedHandler = { [weak self] results, changes in
            self?.handleBrowseResults(results, changes: changes)
        }
        
        // 검색 시작
        browser?.start(queue: networkQueue)
        isScanning = true
        updateConnectionState()
        
        print("📡 Wi-Fi Aware 스캔 시작")
    }
    
    /// 피어 검색 중지
    func stopScanning() {
        browser?.cancel()
        browser = nil
        isScanning = false
        updateConnectionState()
        
        print("📡 Wi-Fi Aware 스캔 중지")
    }
    
    /// 브라우저 상태 처리
    private func handleBrowserState(_ state: NWBrowser.State) {
        switch state {
        case .ready:
            print("✅ 브라우저 준비됨")
        case .failed(let error):
            print("❌ 브라우저 오류: \(error)")
            connectionState = .error(.connectionFailed(error.localizedDescription))
        case .cancelled:
            print("⚪ 브라우저 취소됨")
        case .waiting(let error):
            print("⏳ 브라우저 대기 중: \(error)")
        default:
            break
        }
    }
    
    /// 브라우저 결과 처리 - 피어 발견/업데이트
    private func handleBrowseResults(_ results: Set<NWBrowser.Result>, changes: Set<NWBrowser.Result.Change>) {
        for change in changes {
            switch change {
            case .added(let result):
                handlePeerDiscovered(result)
            case .removed(let result):
                handlePeerLost(result)
            case .changed(old: _, new: let newResult, flags: _):
                handlePeerUpdated(newResult)
            case .identical:
                break
            @unknown default:
                break
            }
        }
    }
    
    /// 새 피어 발견 처리
    private func handlePeerDiscovered(_ result: NWBrowser.Result) {
        // TXT 레코드에서 메타데이터 추출
        var txtRecord: [String: String] = [:]
        if case .bonjour(let txt) = result.metadata {
            for key in txt.dictionary.keys {
                if let value = txt.dictionary[key] {
                    txtRecord[key] = value
                }
            }
        }
        
        let peer = Peer.from(endpoint: result.endpoint, txtRecord: txtRecord)
        
        DispatchQueue.main.async {
            // 중복 확인 후 추가
            if !self.discoveredPeers.contains(where: { $0.endpoint == peer.endpoint }) {
                self.discoveredPeers.append(peer)
                print("🔍 피어 발견: \(peer.deviceName)")
            }
        }
    }
    
    /// 피어 손실 처리
    private func handlePeerLost(_ result: NWBrowser.Result) {
        DispatchQueue.main.async {
            self.discoveredPeers.removeAll { $0.endpoint == result.endpoint }
            print("👋 피어 손실: \(result.endpoint)")
        }
    }
    
    /// 피어 업데이트 처리
    private func handlePeerUpdated(_ result: NWBrowser.Result) {
        DispatchQueue.main.async {
            if let index = self.discoveredPeers.firstIndex(where: { $0.endpoint == result.endpoint }) {
                self.discoveredPeers[index].update()
            }
        }
    }
    
    // MARK: - 서비스 광고 (NWListener)
    
    /// Wi-Fi Aware 서비스 광고 시작
    func startAdvertising() throws {
        guard !isAdvertising else { return }
        
        // Wi-Fi Aware 리스너 파라미터
        let parameters = NWParameters()
        parameters.includePeerToPeer = true
        
        // 보안 연결 설정
        if AppConstants.useSecureConnection {
            // TLS 보안 설정 (iOS 26 Wi-Fi Aware)
            let tlsOptions = NWProtocolTLS.Options()
            parameters.defaultProtocolStack.applicationProtocols.insert(tlsOptions, at: 0)
        }
        
        // Wi-Fi Aware 전용 설정 (iOS 26+)
        if #available(iOS 26, *) {
            parameters.requiredInterface = .wifiAware
        }
        
        // 리스너 생성
        listener = try NWListener(using: parameters)
        
        // Bonjour 서비스 광고 설정
        let txtRecord = NWTXTRecord(DeviceInfo.txtRecord)
        listener?.service = NWListener.Service(
            name: DeviceInfo.deviceName,
            type: AppConstants.serviceType,
            domain: "local.",
            txtRecord: txtRecord
        )
        
        // 리스너 상태 핸들러
        listener?.stateUpdateHandler = { [weak self] state in
            self?.handleListenerState(state)
        }
        
        // 새 연결 핸들러
        listener?.newConnectionHandler = { [weak self] connection in
            self?.handleIncomingConnection(connection)
        }
        
        // 광고 시작
        listener?.start(queue: networkQueue)
        isAdvertising = true
        updateConnectionState()
        
        print("📢 Wi-Fi Aware 광고 시작: \(DeviceInfo.deviceName)")
    }
    
    /// 서비스 광고 중지
    func stopAdvertising() {
        listener?.cancel()
        listener = nil
        isAdvertising = false
        updateConnectionState()
        
        print("📢 Wi-Fi Aware 광고 중지")
    }
    
    /// 리스너 상태 처리
    private func handleListenerState(_ state: NWListener.State) {
        switch state {
        case .ready:
            print("✅ 리스너 준비됨")
        case .failed(let error):
            print("❌ 리스너 오류: \(error)")
            connectionState = .error(.connectionFailed(error.localizedDescription))
        case .cancelled:
            print("⚪ 리스너 취소됨")
        case .waiting(let error):
            print("⏳ 리스너 대기 중: \(error)")
        default:
            break
        }
    }
    
    /// 수신 연결 처리
    private func handleIncomingConnection(_ connection: NWConnection) {
        print("📥 수신 연결: \(connection.endpoint)")
        
        // 연결 상태 핸들러 설정
        connection.stateUpdateHandler = { [weak self] state in
            self?.handleConnectionState(connection: connection, state: state)
        }
        
        // 연결 시작
        connection.start(queue: networkQueue)
    }
    
    // MARK: - 피어 연결
    
    /// 특정 피어에 연결
    func connect(to peer: Peer) {
        let oldState = peer.connectionState
        peer.connectionState = .connecting
        connectionState = .connecting(peer)
        
        // 연결 파라미터 구성
        let parameters = NWParameters()
        parameters.includePeerToPeer = true
        
        if #available(iOS 26, *) {
            parameters.requiredInterface = .wifiAware
        }
        
        // 연결 생성
        let connection = NWConnection(to: peer.endpoint, using: parameters)
        
        // 상태 핸들러
        connection.stateUpdateHandler = { [weak self] state in
            self?.handleConnectionState(connection: connection, state: state, peer: peer)
        }
        
        // 연결 저장 및 시작
        activeConnections[peer.id] = connection
        peer.activeConnection = connection
        connection.start(queue: networkQueue)
        
        // 이벤트 발송
        let event = ConnectionEvent(peer: peer, oldState: oldState, newState: .connecting)
        onConnectionEvent?(event)
        
        print("🔗 연결 시도: \(peer.deviceName)")
    }
    
    /// 피어와의 연결 해제
    func disconnect(from peer: Peer) {
        guard let connection = activeConnections[peer.id] else { return }
        
        let oldState = peer.connectionState
        connection.cancel()
        activeConnections.removeValue(forKey: peer.id)
        peer.activeConnection = nil
        peer.connectionState = .disconnected
        
        updateConnectionState()
        
        let event = ConnectionEvent(peer: peer, oldState: oldState, newState: .disconnected)
        onConnectionEvent?(event)
        
        print("🔌 연결 해제: \(peer.deviceName)")
    }
    
    /// 연결 상태 변경 처리
    private func handleConnectionState(connection: NWConnection, state: NWConnection.State, peer: Peer? = nil) {
        switch state {
        case .ready:
            print("✅ 연결됨: \(connection.endpoint)")
            if let peer = peer {
                let oldState = peer.connectionState
                peer.connectionState = .connected
                
                DispatchQueue.main.async {
                    self.connectionState = .connected(peer)
                }
                
                let event = ConnectionEvent(peer: peer, oldState: oldState, newState: .connected)
                onConnectionEvent?(event)
                
                // 메시지 수신 시작
                receiveMessage(on: connection, from: peer)
            }
            
        case .failed(let error):
            print("❌ 연결 실패: \(error)")
            if let peer = peer {
                let oldState = peer.connectionState
                peer.connectionState = .failed
                activeConnections.removeValue(forKey: peer.id)
                peer.activeConnection = nil
                
                let event = ConnectionEvent(
                    peer: peer,
                    oldState: oldState,
                    newState: .failed,
                    error: .connectionFailed(error.localizedDescription)
                )
                onConnectionEvent?(event)
            }
            updateConnectionState()
            
        case .cancelled:
            print("⚪ 연결 취소됨")
            if let peer = peer {
                peer.connectionState = .disconnected
                activeConnections.removeValue(forKey: peer.id)
                peer.activeConnection = nil
            }
            updateConnectionState()
            
        default:
            break
        }
    }
    
    // MARK: - 메시지 송수신
    
    /// 피어에게 메시지 전송
    func send(_ message: PeerMessage, to peer: Peer) async throws {
        guard let connection = peer.activeConnection else {
            throw ConnectionError.peerNotFound
        }
        
        let data = try message.serialize()
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            connection.send(content: data, completion: .contentProcessed { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            })
        }
    }
    
    /// 연결에서 메시지 수신 대기
    private func receiveMessage(on connection: NWConnection, from peer: Peer) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            if let error = error {
                print("❌ 수신 오류: \(error)")
                return
            }
            
            if let data = data, !data.isEmpty {
                do {
                    let message = try PeerMessage.deserialize(from: data)
                    self?.onMessageReceived?(peer, message)
                    print("📨 메시지 수신: \(message.type) from \(peer.deviceName)")
                } catch {
                    print("❌ 메시지 파싱 오류: \(error)")
                }
            }
            
            // 연결이 완료되지 않았으면 계속 수신
            if !isComplete {
                self?.receiveMessage(on: connection, from: peer)
            }
        }
    }
    
    // MARK: - 유틸리티
    
    /// 모든 네트워크 활동 중지
    func stopAll() {
        stopScanning()
        stopAdvertising()
        
        for (_, connection) in activeConnections {
            connection.cancel()
        }
        activeConnections.removeAll()
        discoveredPeers.removeAll()
        connectionState = .idle
    }
    
    /// 연결 상태 업데이트
    private func updateConnectionState() {
        DispatchQueue.main.async {
            if self.isScanning && self.isAdvertising {
                self.connectionState = .scanningAndAdvertising
            } else if self.isScanning {
                self.connectionState = .scanning
            } else if self.isAdvertising {
                self.connectionState = .advertising
            } else if case .connected = self.connectionState {
                // 유지
            } else {
                self.connectionState = .idle
            }
        }
    }
    
    /// 만료된 피어 정리
    func cleanupExpiredPeers() {
        let now = Date()
        let expiredPeers = discoveredPeers.filter {
            now.timeIntervalSince($0.lastSeen) > AppConstants.peerExpirationTime
        }
        
        for peer in expiredPeers {
            if let connection = activeConnections[peer.id] {
                connection.cancel()
                activeConnections.removeValue(forKey: peer.id)
            }
        }
        
        discoveredPeers.removeAll { peer in
            expiredPeers.contains { $0.id == peer.id }
        }
    }
}
