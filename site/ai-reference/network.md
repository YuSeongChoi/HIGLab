# Network Framework AI Reference

> 저수준 네트워크 통신 가이드. 이 문서를 읽고 Network 프레임워크 코드를 생성할 수 있습니다.

## 개요

Network 프레임워크는 TCP, UDP, QUIC, TLS 등 저수준 네트워크 연결을 위한 현대적인 API입니다.
URLSession보다 세밀한 제어가 필요하거나, 커스텀 프로토콜, 실시간 통신이 필요할 때 사용합니다.

## 필수 Import

```swift
import Network
```

## 핵심 구성요소

### 1. NWConnection (연결)

```swift
// TCP 연결
let connection = NWConnection(
    host: "example.com",
    port: 8080,
    using: .tcp
)

// TLS 연결
let tlsParams = NWProtocolTLS.Options()
let tcpParams = NWProtocolTCP.Options()
let params = NWParameters(tls: tlsParams, tcp: tcpParams)
let secureConnection = NWConnection(host: "example.com", port: 443, using: params)

// UDP 연결
let udpConnection = NWConnection(
    host: "example.com",
    port: 9000,
    using: .udp
)
```

### 2. NWListener (서버)

```swift
// TCP 서버
let listener = try NWListener(using: .tcp, on: 8080)

listener.newConnectionHandler = { connection in
    // 새 연결 처리
}

listener.start(queue: .main)
```

### 3. NWPathMonitor (네트워크 상태)

```swift
let monitor = NWPathMonitor()

monitor.pathUpdateHandler = { path in
    if path.status == .satisfied {
        print("네트워크 연결됨")
    }
    
    if path.usesInterfaceType(.wifi) {
        print("Wi-Fi 사용 중")
    }
}

monitor.start(queue: .main)
```

## 전체 작동 예제

```swift
import SwiftUI
import Network

// MARK: - TCP Client Manager
@Observable
class TCPClientManager {
    var isConnected = false
    var receivedMessages: [String] = []
    var connectionStatus = "연결 안 됨"
    var errorMessage: String?
    
    private var connection: NWConnection?
    private let queue = DispatchQueue(label: "tcp.client")
    
    func connect(host: String, port: UInt16) {
        // 기존 연결 해제
        disconnect()
        
        connectionStatus = "연결 중..."
        
        // TCP 연결 생성
        let endpoint = NWEndpoint.hostPort(
            host: NWEndpoint.Host(host),
            port: NWEndpoint.Port(integerLiteral: port)
        )
        
        connection = NWConnection(to: endpoint, using: .tcp)
        
        // 상태 변경 핸들러
        connection?.stateUpdateHandler = { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                case .ready:
                    self?.isConnected = true
                    self?.connectionStatus = "연결됨"
                    self?.startReceiving()
                case .failed(let error):
                    self?.isConnected = false
                    self?.connectionStatus = "연결 실패"
                    self?.errorMessage = error.localizedDescription
                case .cancelled:
                    self?.isConnected = false
                    self?.connectionStatus = "연결 해제됨"
                case .waiting(let error):
                    self?.connectionStatus = "대기 중: \(error.localizedDescription)"
                default:
                    break
                }
            }
        }
        
        connection?.start(queue: queue)
    }
    
    func disconnect() {
        connection?.cancel()
        connection = nil
        isConnected = false
        connectionStatus = "연결 안 됨"
    }
    
    func send(_ message: String) {
        guard let data = (message + "\n").data(using: .utf8) else { return }
        
        connection?.send(content: data, completion: .contentProcessed { [weak self] error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = "전송 실패: \(error.localizedDescription)"
                }
            }
        })
    }
    
    private func startReceiving() {
        connection?.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] content, _, isComplete, error in
            if let data = content, let message = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self?.receivedMessages.append(message.trimmingCharacters(in: .whitespacesAndNewlines))
                }
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = "수신 오류: \(error.localizedDescription)"
                }
                return
            }
            
            if !isComplete {
                self?.startReceiving()
            }
        }
    }
}

// MARK: - Network Monitor
@Observable
class NetworkMonitor {
    var isConnected = false
    var connectionType: String = "알 수 없음"
    var isExpensive = false
    var isConstrained = false
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "network.monitor")
    
    init() {
        startMonitoring()
    }
    
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.isExpensive = path.isExpensive
                self?.isConstrained = path.isConstrained
                
                if path.usesInterfaceType(.wifi) {
                    self?.connectionType = "Wi-Fi"
                } else if path.usesInterfaceType(.cellular) {
                    self?.connectionType = "셀룰러"
                } else if path.usesInterfaceType(.wiredEthernet) {
                    self?.connectionType = "이더넷"
                } else {
                    self?.connectionType = "기타"
                }
            }
        }
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
}

// MARK: - Main View
struct NetworkView: View {
    @State private var client = TCPClientManager()
    @State private var networkMonitor = NetworkMonitor()
    @State private var host = "localhost"
    @State private var port = "8080"
    @State private var messageToSend = ""
    
    var body: some View {
        NavigationStack {
            List {
                // 네트워크 상태
                Section("네트워크 상태") {
                    LabeledContent("연결") {
                        HStack {
                            Circle()
                                .fill(networkMonitor.isConnected ? .green : .red)
                                .frame(width: 8, height: 8)
                            Text(networkMonitor.isConnected ? "연결됨" : "끊김")
                        }
                    }
                    LabeledContent("타입", value: networkMonitor.connectionType)
                    if networkMonitor.isExpensive {
                        Label("데이터 비용 발생", systemImage: "dollarsign.circle")
                            .foregroundStyle(.orange)
                    }
                }
                
                // TCP 연결
                Section("TCP 연결") {
                    TextField("호스트", text: $host)
                        .autocapitalization(.none)
                    TextField("포트", text: $port)
                        .keyboardType(.numberPad)
                    
                    HStack {
                        Text("상태: \(client.connectionStatus)")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Circle()
                            .fill(client.isConnected ? .green : .gray)
                            .frame(width: 10, height: 10)
                    }
                    
                    Button(client.isConnected ? "연결 해제" : "연결") {
                        if client.isConnected {
                            client.disconnect()
                        } else if let portNum = UInt16(port) {
                            client.connect(host: host, port: portNum)
                        }
                    }
                }
                
                // 메시지 전송
                if client.isConnected {
                    Section("메시지") {
                        HStack {
                            TextField("메시지", text: $messageToSend)
                            Button("전송") {
                                client.send(messageToSend)
                                messageToSend = ""
                            }
                            .disabled(messageToSend.isEmpty)
                        }
                    }
                }
                
                // 수신 메시지
                if !client.receivedMessages.isEmpty {
                    Section("수신 메시지") {
                        ForEach(client.receivedMessages.indices, id: \.self) { index in
                            Text(client.receivedMessages[index])
                                .font(.system(.body, design: .monospaced))
                        }
                    }
                }
                
                // 에러
                if let error = client.errorMessage {
                    Section {
                        Label(error, systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Network")
        }
    }
}

#Preview {
    NetworkView()
}
```

## 고급 패턴

### 1. TCP 서버

```swift
@Observable
class TCPServer {
    var isRunning = false
    var connectedClients: [NWConnection] = []
    
    private var listener: NWListener?
    private let queue = DispatchQueue(label: "tcp.server")
    
    func start(port: UInt16) throws {
        let params = NWParameters.tcp
        params.allowLocalEndpointReuse = true
        
        listener = try NWListener(using: params, on: NWEndpoint.Port(integerLiteral: port))
        
        listener?.stateUpdateHandler = { [weak self] state in
            DispatchQueue.main.async {
                self?.isRunning = state == .ready
            }
        }
        
        listener?.newConnectionHandler = { [weak self] connection in
            self?.handleNewConnection(connection)
        }
        
        listener?.start(queue: queue)
    }
    
    func stop() {
        listener?.cancel()
        connectedClients.forEach { $0.cancel() }
        connectedClients.removeAll()
        isRunning = false
    }
    
    private func handleNewConnection(_ connection: NWConnection) {
        connection.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                DispatchQueue.main.async {
                    self?.connectedClients.append(connection)
                }
                self?.receive(on: connection)
            case .cancelled, .failed:
                DispatchQueue.main.async {
                    self?.connectedClients.removeAll { $0 === connection }
                }
            default:
                break
            }
        }
        
        connection.start(queue: queue)
    }
    
    private func receive(on connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] content, _, isComplete, _ in
            if let data = content {
                // 에코 서버 - 받은 메시지 되돌려 보내기
                connection.send(content: data, completion: .idempotent)
            }
            
            if !isComplete {
                self?.receive(on: connection)
            }
        }
    }
    
    func broadcast(_ message: String) {
        guard let data = message.data(using: .utf8) else { return }
        
        for client in connectedClients {
            client.send(content: data, completion: .idempotent)
        }
    }
}
```

### 2. UDP 통신

```swift
class UDPManager {
    private var connection: NWConnection?
    private let queue = DispatchQueue(label: "udp")
    
    func sendUDP(message: String, to host: String, port: UInt16) {
        let endpoint = NWEndpoint.hostPort(
            host: NWEndpoint.Host(host),
            port: NWEndpoint.Port(integerLiteral: port)
        )
        
        connection = NWConnection(to: endpoint, using: .udp)
        
        connection?.stateUpdateHandler = { state in
            if state == .ready {
                self.send(message)
            }
        }
        
        connection?.start(queue: queue)
    }
    
    private func send(_ message: String) {
        guard let data = message.data(using: .utf8) else { return }
        
        connection?.send(content: data, completion: .contentProcessed { error in
            if let error = error {
                print("UDP 전송 실패: \(error)")
            }
        })
    }
}
```

### 3. WebSocket

```swift
class WebSocketManager {
    private var connection: NWConnection?
    private let queue = DispatchQueue(label: "websocket")
    
    func connect(to url: URL) {
        let host = url.host ?? "localhost"
        let port = UInt16(url.port ?? 443)
        
        // WebSocket 파라미터
        let wsOptions = NWProtocolWebSocket.Options()
        wsOptions.autoReplyPing = true
        
        let tlsOptions = NWProtocolTLS.Options()
        let tcpOptions = NWProtocolTCP.Options()
        
        let params = NWParameters(tls: tlsOptions, tcp: tcpOptions)
        params.defaultProtocolStack.applicationProtocols.insert(wsOptions, at: 0)
        
        connection = NWConnection(
            host: NWEndpoint.Host(host),
            port: NWEndpoint.Port(integerLiteral: port),
            using: params
        )
        
        connection?.stateUpdateHandler = { state in
            switch state {
            case .ready:
                print("WebSocket 연결됨")
                self.receiveMessage()
            case .failed(let error):
                print("연결 실패: \(error)")
            default:
                break
            }
        }
        
        connection?.start(queue: queue)
    }
    
    func sendText(_ text: String) {
        let metadata = NWProtocolWebSocket.Metadata(opcode: .text)
        let context = NWConnection.ContentContext(
            identifier: "text",
            metadata: [metadata]
        )
        
        connection?.send(
            content: text.data(using: .utf8),
            contentContext: context,
            isComplete: true,
            completion: .idempotent
        )
    }
    
    private func receiveMessage() {
        connection?.receiveMessage { content, context, _, error in
            if let data = content,
               let metadata = context?.protocolMetadata(definition: NWProtocolWebSocket.definition) as? NWProtocolWebSocket.Metadata {
                switch metadata.opcode {
                case .text:
                    if let text = String(data: data, encoding: .utf8) {
                        print("수신: \(text)")
                    }
                case .binary:
                    print("바이너리 수신: \(data.count) bytes")
                default:
                    break
                }
            }
            
            if error == nil {
                self.receiveMessage()
            }
        }
    }
}
```

### 4. 특정 인터페이스로 연결

```swift
func connectViaWiFi(host: String, port: UInt16) {
    let params = NWParameters.tcp
    params.requiredInterfaceType = .wifi  // Wi-Fi만 사용
    
    let connection = NWConnection(
        host: NWEndpoint.Host(host),
        port: NWEndpoint.Port(integerLiteral: port),
        using: params
    )
    
    connection.start(queue: .main)
}

func connectViaCellular(host: String, port: UInt16) {
    let params = NWParameters.tcp
    params.requiredInterfaceType = .cellular  // 셀룰러만 사용
    
    let connection = NWConnection(
        host: NWEndpoint.Host(host),
        port: NWEndpoint.Port(integerLiteral: port),
        using: params
    )
    
    connection.start(queue: .main)
}
```

## 주의사항

1. **앱 전송 보안 (ATS)**
   ```xml
   <!-- 비암호화 연결 허용 (개발용) -->
   <key>NSAppTransportSecurity</key>
   <dict>
       <key>NSAllowsArbitraryLoads</key>
       <true/>
   </dict>
   ```

2. **연결 생명주기**
   ```swift
   // 반드시 cancel() 호출
   deinit {
       connection?.cancel()
   }
   ```

3. **스레드 안전**
   - 콜백은 지정한 큐에서 호출됨
   - UI 업데이트는 `DispatchQueue.main.async`

4. **재연결 로직**
   - 자동 재연결 없음
   - 직접 구현 필요

5. **로컬 네트워크 권한**
   - iOS 14+에서 로컬 네트워크 접근 시 권한 필요
   - Info.plist에 NSLocalNetworkUsageDescription 추가
