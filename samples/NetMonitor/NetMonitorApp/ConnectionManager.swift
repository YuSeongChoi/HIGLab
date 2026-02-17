import Foundation
import Network
import Combine

/// TCP/UDP 연결을 관리하는 매니저
/// NWConnection을 사용하여 네트워크 연결 생성 및 데이터 송수신
class ConnectionManager: ObservableObject {
    
    // MARK: - Published 속성
    
    /// 현재 연결 상태
    @Published private(set) var connectionState: ConnectionState = .idle
    
    /// 현재 연결 정보
    @Published private(set) var currentConnectionInfo: ConnectionInfo?
    
    /// 에코 메시지 히스토리
    @Published private(set) var messages: [EchoMessage] = []
    
    /// 전송 통계
    @Published private(set) var statistics = TransferStatistics()
    
    /// 연결 히스토리
    @Published private(set) var connectionHistory: [ConnectionInfo] = []
    
    // MARK: - Private 속성
    
    /// 현재 NWConnection
    private var connection: NWConnection?
    
    /// 연결 큐
    private let connectionQueue = DispatchQueue(label: "com.netmonitor.connection", qos: .userInitiated)
    
    /// 수신 대기 중 여부
    private var isReceiving: Bool = false
    
    // MARK: - 연결 관리
    
    /// TCP 연결 생성
    /// - Parameters:
    ///   - host: 호스트 주소
    ///   - port: 포트 번호
    func connectTCP(host: String, port: UInt16) {
        connect(host: host, port: port, protocol: .tcp)
    }
    
    /// UDP 연결 생성
    /// - Parameters:
    ///   - host: 호스트 주소
    ///   - port: 포트 번호
    func connectUDP(host: String, port: UInt16) {
        connect(host: host, port: port, protocol: .udp)
    }
    
    /// 네트워크 연결 생성
    /// - Parameters:
    ///   - host: 호스트 주소
    ///   - port: 포트 번호
    ///   - protocol: 연결 프로토콜 (TCP/UDP)
    func connect(host: String, port: UInt16, protocol: ConnectionProtocol) {
        // 기존 연결 종료
        disconnect()
        
        // 연결 정보 생성
        let connectionInfo = ConnectionInfo(host: host, port: port, protocol: `protocol`)
        currentConnectionInfo = connectionInfo
        
        // NWEndpoint 생성
        let endpoint = NWEndpoint.hostPort(
            host: NWEndpoint.Host(host),
            port: NWEndpoint.Port(rawValue: port)!
        )
        
        // NWConnection 생성
        let parameters = `protocol`.nwParameters
        connection = NWConnection(to: endpoint, using: parameters)
        
        // 상태 핸들러 설정
        setupStateHandler()
        
        // 연결 시작
        connection?.start(queue: connectionQueue)
        
        DispatchQueue.main.async {
            self.connectionState = .preparing
        }
        
        print("🔌 연결 시작: \(host):\(port) (\(`protocol`.rawValue))")
    }
    
    /// 연결 상태 핸들러 설정
    private func setupStateHandler() {
        connection?.stateUpdateHandler = { [weak self] state in
            DispatchQueue.main.async {
                self?.handleStateUpdate(state)
            }
        }
    }
    
    /// 연결 상태 변경 처리
    private func handleStateUpdate(_ state: NWConnection.State) {
        connectionState = ConnectionState.from(state)
        
        switch state {
        case .ready:
            print("✅ 연결 성공")
            startReceiving()
            
        case .failed(let error):
            print("❌ 연결 실패: \(error.localizedDescription)")
            handleConnectionFailure()
            
        case .cancelled:
            print("⏹️ 연결 취소됨")
            
        case .waiting(let error):
            print("⏳ 연결 대기 중: \(error.localizedDescription)")
            
        default:
            break
        }
        
        // 연결 정보 상태 업데이트
        currentConnectionInfo?.state = connectionState
    }
    
    /// 연결 실패 처리
    private func handleConnectionFailure() {
        isReceiving = false
        
        // 히스토리에 추가
        if let info = currentConnectionInfo {
            connectionHistory.append(info)
        }
    }
    
    /// 연결 종료
    func disconnect() {
        guard let conn = connection else { return }
        
        conn.cancel()
        connection = nil
        isReceiving = false
        
        DispatchQueue.main.async {
            self.connectionState = .cancelled
            
            // 히스토리에 추가
            if let info = self.currentConnectionInfo {
                self.connectionHistory.append(info)
            }
            self.currentConnectionInfo = nil
        }
        
        print("🔌 연결 종료됨")
    }
    
    // MARK: - 데이터 송수신
    
    /// 데이터 전송
    /// - Parameter data: 전송할 데이터
    func send(data: Data) {
        guard let connection = connection, connectionState == .ready else {
            print("⚠️ 연결되지 않은 상태에서 전송 시도")
            return
        }
        
        connection.send(content: data, completion: .contentProcessed { [weak self] error in
            if let error = error {
                print("❌ 전송 오류: \(error.localizedDescription)")
            } else {
                self?.statistics.recordSent(bytes: data.count)
                print("📤 \(data.count) 바이트 전송됨")
            }
        })
    }
    
    /// 문자열 전송
    /// - Parameter text: 전송할 문자열
    func send(text: String) {
        guard let data = text.data(using: .utf8) else { return }
        
        // 메시지 기록
        let message = EchoMessage(content: text, isOutgoing: true)
        DispatchQueue.main.async {
            self.messages.append(message)
        }
        
        send(data: data)
    }
    
    /// 데이터 수신 시작
    private func startReceiving() {
        guard !isReceiving else { return }
        isReceiving = true
        receiveNextMessage()
    }
    
    /// 다음 메시지 수신
    private func receiveNextMessage() {
        guard let connection = connection, isReceiving else { return }
        
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] content, _, isComplete, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ 수신 오류: \(error.localizedDescription)")
                return
            }
            
            if let data = content, !data.isEmpty {
                self.handleReceivedData(data)
            }
            
            if isComplete {
                print("📥 수신 완료")
                DispatchQueue.main.async {
                    self.isReceiving = false
                }
            } else if self.isReceiving {
                // 계속 수신
                self.receiveNextMessage()
            }
        }
    }
    
    /// 수신 데이터 처리
    private func handleReceivedData(_ data: Data) {
        statistics.recordReceived(bytes: data.count)
        
        if let text = String(data: data, encoding: .utf8) {
            let message = EchoMessage(content: text, isOutgoing: false)
            
            DispatchQueue.main.async {
                self.messages.append(message)
            }
            
            print("📥 수신: \(text)")
        } else {
            print("📥 \(data.count) 바이트 수신됨 (바이너리)")
        }
    }
    
    // MARK: - 편의 메서드
    
    /// 메시지 히스토리 초기화
    func clearMessages() {
        messages.removeAll()
    }
    
    /// 통계 초기화
    func resetStatistics() {
        statistics.reset()
    }
    
    /// 연결 히스토리 초기화
    func clearHistory() {
        connectionHistory.removeAll()
    }
    
    /// 연결 여부 확인
    var isConnected: Bool {
        connectionState == .ready
    }
}

// MARK: - 연결 테스트 유틸리티
extension ConnectionManager {
    
    /// 연결 테스트 (ping과 유사)
    /// - Parameters:
    ///   - host: 테스트할 호스트
    ///   - port: 포트 번호
    ///   - completion: 완료 핸들러 (성공 여부, 지연 시간)
    func testConnection(host: String, port: UInt16, completion: @escaping (Bool, TimeInterval?) -> Void) {
        let startTime = Date()
        
        let endpoint = NWEndpoint.hostPort(
            host: NWEndpoint.Host(host),
            port: NWEndpoint.Port(rawValue: port)!
        )
        
        let testConnection = NWConnection(to: endpoint, using: .tcp)
        
        testConnection.stateUpdateHandler = { state in
            switch state {
            case .ready:
                let latency = Date().timeIntervalSince(startTime)
                testConnection.cancel()
                DispatchQueue.main.async {
                    completion(true, latency)
                }
                
            case .failed, .cancelled:
                DispatchQueue.main.async {
                    completion(false, nil)
                }
                
            default:
                break
            }
        }
        
        testConnection.start(queue: connectionQueue)
        
        // 타임아웃 (5초)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if testConnection.state != .ready {
                testConnection.cancel()
                completion(false, nil)
            }
        }
    }
}
