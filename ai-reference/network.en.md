# Network Framework AI Reference

> Low-level network communication guide. Read this document to generate Network framework code.

## Overview

The Network framework provides modern APIs for low-level network connections including TCP, UDP, QUIC, and TLS.
Use it when you need finer control than URLSession, custom protocols, or real-time communication.

## Required Import

```swift
import Network
```

## Core Components

### 1. NWConnection (Connection)

```swift
// TCP connection
let connection = NWConnection(
    host: "example.com",
    port: 8080,
    using: .tcp
)

// TLS connection
let tlsParams = NWProtocolTLS.Options()
let tcpParams = NWProtocolTCP.Options()
let params = NWParameters(tls: tlsParams, tcp: tcpParams)
let secureConnection = NWConnection(host: "example.com", port: 443, using: params)

// UDP connection
let udpConnection = NWConnection(
    host: "example.com",
    port: 9000,
    using: .udp
)
```

### 2. NWListener (Server)

```swift
// TCP server
let listener = try NWListener(using: .tcp, on: 8080)

listener.newConnectionHandler = { connection in
    // Handle new connection
}

listener.start(queue: .main)
```

### 3. NWPathMonitor (Network Status)

```swift
let monitor = NWPathMonitor()

monitor.pathUpdateHandler = { path in
    if path.status == .satisfied {
        print("Network connected")
    }
    
    if path.usesInterfaceType(.wifi) {
        print("Using Wi-Fi")
    }
}

monitor.start(queue: .main)
```

## Complete Working Example

```swift
import SwiftUI
import Network

// MARK: - TCP Client Manager
@Observable
class TCPClientManager {
    var isConnected = false
    var receivedMessages: [String] = []
    var connectionStatus = "Disconnected"
    var errorMessage: String?
    
    private var connection: NWConnection?
    private let queue = DispatchQueue(label: "tcp.client")
    
    func connect(host: String, port: UInt16) {
        // Disconnect existing connection
        disconnect()
        
        connectionStatus = "Connecting..."
        
        // Create TCP connection
        let endpoint = NWEndpoint.hostPort(
            host: NWEndpoint.Host(host),
            port: NWEndpoint.Port(integerLiteral: port)
        )
        
        connection = NWConnection(to: endpoint, using: .tcp)
        
        // State change handler
        connection?.stateUpdateHandler = { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                case .ready:
                    self?.isConnected = true
                    self?.connectionStatus = "Connected"
                    self?.startReceiving()
                case .failed(let error):
                    self?.isConnected = false
                    self?.connectionStatus = "Connection Failed"
                    self?.errorMessage = error.localizedDescription
                case .cancelled:
                    self?.isConnected = false
                    self?.connectionStatus = "Disconnected"
                case .waiting(let error):
                    self?.connectionStatus = "Waiting: \(error.localizedDescription)"
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
        connectionStatus = "Disconnected"
    }
    
    func send(_ message: String) {
        guard let data = (message + "\n").data(using: .utf8) else { return }
        
        connection?.send(content: data, completion: .contentProcessed { [weak self] error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = "Send failed: \(error.localizedDescription)"
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
                    self?.errorMessage = "Receive error: \(error.localizedDescription)"
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
    var connectionType: String = "Unknown"
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
                    self?.connectionType = "Cellular"
                } else if path.usesInterfaceType(.wiredEthernet) {
                    self?.connectionType = "Ethernet"
                } else {
                    self?.connectionType = "Other"
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
                // Network status
                Section("Network Status") {
                    LabeledContent("Connection") {
                        HStack {
                            Circle()
                                .fill(networkMonitor.isConnected ? .green : .red)
                                .frame(width: 8, height: 8)
                            Text(networkMonitor.isConnected ? "Connected" : "Disconnected")
                        }
                    }
                    LabeledContent("Type", value: networkMonitor.connectionType)
                    if networkMonitor.isExpensive {
                        Label("Data costs may apply", systemImage: "dollarsign.circle")
                            .foregroundStyle(.orange)
                    }
                }
                
                // TCP connection
                Section("TCP Connection") {
                    TextField("Host", text: $host)
                        .autocapitalization(.none)
                    TextField("Port", text: $port)
                        .keyboardType(.numberPad)
                    
                    HStack {
                        Text("Status: \(client.connectionStatus)")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Circle()
                            .fill(client.isConnected ? .green : .gray)
                            .frame(width: 10, height: 10)
                    }
                    
                    Button(client.isConnected ? "Disconnect" : "Connect") {
                        if client.isConnected {
                            client.disconnect()
                        } else if let portNum = UInt16(port) {
                            client.connect(host: host, port: portNum)
                        }
                    }
                }
                
                // Send message
                if client.isConnected {
                    Section("Message") {
                        HStack {
                            TextField("Message", text: $messageToSend)
                            Button("Send") {
                                client.send(messageToSend)
                                messageToSend = ""
                            }
                            .disabled(messageToSend.isEmpty)
                        }
                    }
                }
                
                // Received messages
                if !client.receivedMessages.isEmpty {
                    Section("Received Messages") {
                        ForEach(client.receivedMessages.indices, id: \.self) { index in
                            Text(client.receivedMessages[index])
                                .font(.system(.body, design: .monospaced))
                        }
                    }
                }
                
                // Error
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

## Advanced Patterns

### 1. TCP Server

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
                // Echo server - send received message back
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

### 2. UDP Communication

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
                print("UDP send failed: \(error)")
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
        
        // WebSocket parameters
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
                print("WebSocket connected")
                self.receiveMessage()
            case .failed(let error):
                print("Connection failed: \(error)")
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
                        print("Received: \(text)")
                    }
                case .binary:
                    print("Binary received: \(data.count) bytes")
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

### 4. Connect via Specific Interface

```swift
func connectViaWiFi(host: String, port: UInt16) {
    let params = NWParameters.tcp
    params.requiredInterfaceType = .wifi  // Use Wi-Fi only
    
    let connection = NWConnection(
        host: NWEndpoint.Host(host),
        port: NWEndpoint.Port(integerLiteral: port),
        using: params
    )
    
    connection.start(queue: .main)
}

func connectViaCellular(host: String, port: UInt16) {
    let params = NWParameters.tcp
    params.requiredInterfaceType = .cellular  // Use cellular only
    
    let connection = NWConnection(
        host: NWEndpoint.Host(host),
        port: NWEndpoint.Port(integerLiteral: port),
        using: params
    )
    
    connection.start(queue: .main)
}
```

## Important Notes

1. **App Transport Security (ATS)**
   ```xml
   <!-- Allow non-encrypted connections (development only) -->
   <key>NSAppTransportSecurity</key>
   <dict>
       <key>NSAllowsArbitraryLoads</key>
       <true/>
   </dict>
   ```

2. **Connection Lifecycle**
   ```swift
   // Always call cancel()
   deinit {
       connection?.cancel()
   }
   ```

3. **Thread Safety**
   - Callbacks are called on the specified queue
   - Use `DispatchQueue.main.async` for UI updates

4. **Reconnection Logic**
   - No automatic reconnection
   - Must implement manually

5. **Local Network Permission**
   - Permission required for local network access in iOS 14+
   - Add NSLocalNetworkUsageDescription to Info.plist
