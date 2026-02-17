import Foundation
import Network

/// 간단한 에코 서버 구현
/// 클라이언트가 보낸 데이터를 그대로 돌려보냄
class EchoServer: ObservableObject {
    
    // MARK: - Published 속성
    
    /// 서버 상태
    @Published private(set) var state: ServerState = .stopped
    
    /// 연결된 클라이언트 수
    @Published private(set) var connectedClients: Int = 0
    
    /// 서버 로그
    @Published private(set) var logs: [ServerLog] = []
    
    /// 전송 통계
    @Published private(set) var statistics = TransferStatistics()
    
    // MARK: - Private 속성
    
    /// TCP 리스너
    private var tcpListener: NWListener?
    
    /// UDP 리스너
    private var udpListener: NWListener?
    
    /// 활성 연결들
    private var activeConnections: [NWConnection] = []
    
    /// 리스너 큐
    private let listenerQueue = DispatchQueue(label: "com.netmonitor.echoserver", qos: .userInitiated)
    
    /// 현재 포트
    private var currentPort: UInt16 = 0
    
    // MARK: - 서버 제어
    
    /// TCP 서버 시작
    /// - Parameter port: 리스닝 포트 (0이면 자동 할당)
    func startTCP(port: UInt16 = 0) {
        start(protocol: .tcp, port: port)
    }
    
    /// UDP 서버 시작
    /// - Parameter port: 리스닝 포트 (0이면 자동 할당)
    func startUDP(port: UInt16 = 0) {
        start(protocol: .udp, port: port)
    }
    
    /// 서버 시작
    private func start(protocol: ConnectionProtocol, port: UInt16) {
        // 이미 실행 중이면 중지
        stop()
        
        DispatchQueue.main.async {
            self.state = .starting
        }
        
        do {
            let parameters = `protocol`.nwParameters
            
            // 포트 지정
            if port > 0 {
                parameters.requiredLocalEndpoint = NWEndpoint.hostPort(
                    host: .ipv4(.any),
                    port: NWEndpoint.Port(rawValue: port)!
                )
            }
            
            // 리스너 생성
            let listener = try NWListener(using: parameters)
            
            // 상태 핸들러
            listener.stateUpdateHandler = { [weak self] state in
                self?.handleListenerState(state, protocol: `protocol`)
            }
            
            // 새 연결 핸들러
            listener.newConnectionHandler = { [weak self] connection in
                self?.handleNewConnection(connection)
            }
            
            // 리스너 시작
            listener.start(queue: listenerQueue)
            
            if `protocol` == .tcp {
                tcpListener = listener
            } else {
                udpListener = listener
            }
            
            addLog("🚀 \(`protocol`.rawValue) 서버 시작 중...")
            
        } catch {
            DispatchQueue.main.async {
                self.state = .error(error.localizedDescription)
            }
            addLog("❌ 서버 시작 실패: \(error.localizedDescription)")
        }
    }
    
    /// 리스너 상태 처리
    private func handleListenerState(_ listenerState: NWListener.State, protocol: ConnectionProtocol) {
        switch listenerState {
        case .ready:
            // 실제 포트 가져오기
            if let port = tcpListener?.port ?? udpListener?.port {
                currentPort = port.rawValue
                DispatchQueue.main.async {
                    self.state = .running(port: self.currentPort)
                }
                addLog("✅ \(`protocol`.rawValue) 서버 실행 중 (포트: \(currentPort))")
            }
            
        case .failed(let error):
            DispatchQueue.main.async {
                self.state = .error(error.localizedDescription)
            }
            addLog("❌ 서버 오류: \(error.localizedDescription)")
            
        case .cancelled:
            DispatchQueue.main.async {
                self.state = .stopped
            }
            addLog("⏹️ 서버 중지됨")
            
        default:
            break
        }
    }
    
    /// 새 연결 처리
    private func handleNewConnection(_ connection: NWConnection) {
        addLog("📥 새 연결: \(connection.endpoint)")
        
        // 연결 상태 핸들러
        connection.stateUpdateHandler = { [weak self] state in
            self?.handleConnectionState(state, connection: connection)
        }
        
        // 연결 시작
        connection.start(queue: listenerQueue)
        
        // 활성 연결에 추가
        activeConnections.append(connection)
        
        DispatchQueue.main.async {
            self.connectedClients = self.activeConnections.count
        }
    }
    
    /// 연결 상태 처리
    private func handleConnectionState(_ state: NWConnection.State, connection: NWConnection) {
        switch state {
        case .ready:
            addLog("✅ 클라이언트 연결됨: \(connection.endpoint)")
            startReceiving(connection: connection)
            
        case .failed(let error):
            addLog("❌ 클라이언트 연결 실패: \(error.localizedDescription)")
            removeConnection(connection)
            
        case .cancelled:
            addLog("🔌 클라이언트 연결 해제: \(connection.endpoint)")
            removeConnection(connection)
            
        default:
            break
        }
    }
    
    /// 연결 제거
    private func removeConnection(_ connection: NWConnection) {
        activeConnections.removeAll { $0 === connection }
        
        DispatchQueue.main.async {
            self.connectedClients = self.activeConnections.count
        }
    }
    
    /// 데이터 수신 시작
    private func startReceiving(connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] content, _, isComplete, error in
            guard let self = self else { return }
            
            if let error = error {
                self.addLog("❌ 수신 오류: \(error.localizedDescription)")
                return
            }
            
            if let data = content, !data.isEmpty {
                self.handleReceivedData(data, from: connection)
            }
            
            if !isComplete && connection.state == .ready {
                // 계속 수신
                self.startReceiving(connection: connection)
            }
        }
    }
    
    /// 수신 데이터 처리 (에코)
    private func handleReceivedData(_ data: Data, from connection: NWConnection) {
        statistics.recordReceived(bytes: data.count)
        
        // 수신 데이터 로깅
        if let text = String(data: data, encoding: .utf8) {
            addLog("📨 수신 [\(connection.endpoint)]: \(text)")
        } else {
            addLog("📨 수신 [\(connection.endpoint)]: \(data.count) 바이트")
        }
        
        // 에코 (받은 데이터 그대로 전송)
        connection.send(content: data, completion: .contentProcessed { [weak self] error in
            if let error = error {
                self?.addLog("❌ 에코 전송 오류: \(error.localizedDescription)")
            } else {
                self?.statistics.recordSent(bytes: data.count)
                
                if let text = String(data: data, encoding: .utf8) {
                    self?.addLog("📤 에코 [\(connection.endpoint)]: \(text)")
                } else {
                    self?.addLog("📤 에코 [\(connection.endpoint)]: \(data.count) 바이트")
                }
            }
        })
    }
    
    /// 서버 중지
    func stop() {
        // 모든 연결 종료
        for connection in activeConnections {
            connection.cancel()
        }
        activeConnections.removeAll()
        
        // 리스너 중지
        tcpListener?.cancel()
        tcpListener = nil
        
        udpListener?.cancel()
        udpListener = nil
        
        currentPort = 0
        
        DispatchQueue.main.async {
            self.state = .stopped
            self.connectedClients = 0
        }
        
        addLog("⏹️ 서버 중지됨")
    }
    
    // MARK: - 로깅
    
    /// 로그 추가
    private func addLog(_ message: String) {
        let log = ServerLog(message: message)
        
        DispatchQueue.main.async {
            self.logs.append(log)
            
            // 최대 100개까지만 유지
            if self.logs.count > 100 {
                self.logs.removeFirst()
            }
        }
        
        #if DEBUG
        print("[EchoServer] \(message)")
        #endif
    }
    
    /// 로그 초기화
    func clearLogs() {
        logs.removeAll()
    }
    
    /// 통계 초기화
    func resetStatistics() {
        statistics.reset()
    }
    
    // MARK: - 브로드캐스트
    
    /// 모든 연결된 클라이언트에게 메시지 전송
    func broadcast(message: String) {
        guard let data = message.data(using: .utf8) else { return }
        
        for connection in activeConnections {
            connection.send(content: data, completion: .contentProcessed { [weak self] error in
                if let error = error {
                    self?.addLog("❌ 브로드캐스트 오류: \(error.localizedDescription)")
                } else {
                    self?.statistics.recordSent(bytes: data.count)
                }
            })
        }
        
        addLog("📢 브로드캐스트: \(message) (\(activeConnections.count)개 클라이언트)")
    }
}

// MARK: - 서버 로그
/// 서버 로그 항목
struct ServerLog: Identifiable {
    let id = UUID()
    let timestamp: Date
    let message: String
    
    init(message: String) {
        self.timestamp = Date()
        self.message = message
    }
    
    /// 포맷된 시간
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: timestamp)
    }
}
