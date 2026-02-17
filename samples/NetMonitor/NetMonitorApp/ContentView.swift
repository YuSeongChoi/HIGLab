import SwiftUI

/// 메인 콘텐츠 뷰
/// 탭으로 구분된 네트워크 모니터링 기능 제공
struct ContentView: View {
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @EnvironmentObject var connectionManager: ConnectionManager
    @EnvironmentObject var echoServer: EchoServer
    
    /// 현재 선택된 탭
    @State private var selectedTab: Tab = .status
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 네트워크 상태 탭
            NetworkStatusView()
                .tabItem {
                    Label("상태", systemImage: "wifi")
                }
                .tag(Tab.status)
            
            // 인터페이스 목록 탭
            InterfaceListView()
                .tabItem {
                    Label("인터페이스", systemImage: "network")
                }
                .tag(Tab.interfaces)
            
            // 연결 테스트 탭
            ConnectionTestView()
                .tabItem {
                    Label("연결", systemImage: "link")
                }
                .tag(Tab.connection)
            
            // 에코 서버 탭
            EchoServerView()
                .tabItem {
                    Label("서버", systemImage: "server.rack")
                }
                .tag(Tab.server)
            
            // 통계 탭
            StatisticsView()
                .tabItem {
                    Label("통계", systemImage: "chart.bar")
                }
                .tag(Tab.statistics)
        }
        .onAppear {
            // 앱 시작 시 네트워크 모니터링 시작
            networkMonitor.startMonitoring()
        }
    }
    
    /// 탭 열거형
    enum Tab {
        case status
        case interfaces
        case connection
        case server
        case statistics
    }
}

// MARK: - 네트워크 상태 뷰
/// 현재 네트워크 연결 상태를 표시
struct NetworkStatusView: View {
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    var body: some View {
        NavigationStack {
            List {
                // 연결 상태 섹션
                Section {
                    HStack {
                        Image(systemName: networkMonitor.isConnected ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(networkMonitor.isConnected ? .green : .red)
                            .font(.title2)
                        
                        VStack(alignment: .leading) {
                            Text(networkMonitor.isConnected ? "연결됨" : "연결 안 됨")
                                .font(.headline)
                            Text(networkMonitor.connectionType.rawValue)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: networkMonitor.connectionType.iconName)
                            .font(.title)
                            .foregroundColor(.accentColor)
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("연결 상태")
                }
                
                // 연결 품질 섹션
                Section {
                    ConnectionQualityView(quality: networkMonitor.connectionQuality)
                } header: {
                    Text("연결 품질")
                }
                
                // 연결 상세 정보 섹션
                Section {
                    DetailRow(title: "비용 발생 연결", value: networkMonitor.isExpensive ? "예" : "아니오")
                    DetailRow(title: "저데이터 모드", value: networkMonitor.isConstrained ? "예" : "아니오")
                    DetailRow(title: "IPv4 지원", value: networkMonitor.pathState.supportsIPv4 ? "예" : "아니오")
                    DetailRow(title: "IPv6 지원", value: networkMonitor.pathState.supportsIPv6 ? "예" : "아니오")
                    DetailRow(title: "DNS 지원", value: networkMonitor.pathState.supportsDNS ? "예" : "아니오")
                } header: {
                    Text("상세 정보")
                }
                
                // 상태 변경 히스토리 섹션
                if !networkMonitor.stateHistory.isEmpty {
                    Section {
                        ForEach(networkMonitor.stateHistory.reversed()) { change in
                            HStack {
                                Text(change.formattedTime)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(width: 70, alignment: .leading)
                                
                                Text(change.description)
                                    .font(.subheadline)
                            }
                        }
                    } header: {
                        HStack {
                            Text("변경 히스토리")
                            Spacer()
                            Button("초기화") {
                                networkMonitor.clearHistory()
                            }
                            .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle("네트워크 상태")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
        }
    }
}

// MARK: - 연결 품질 뷰
/// 신호 강도 막대로 연결 품질 표시
struct ConnectionQualityView: View {
    let quality: ConnectionQuality
    
    var body: some View {
        HStack {
            Text("품질")
            
            Spacer()
            
            // 신호 강도 막대
            HStack(spacing: 3) {
                ForEach(0..<4) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(index < quality.signalBars ? barColor : Color.gray.opacity(0.3))
                        .frame(width: 8, height: CGFloat(8 + index * 4))
                }
            }
            
            Text(quality.rawValue)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .trailing)
        }
        .padding(.vertical, 4)
    }
    
    /// 막대 색상
    private var barColor: Color {
        switch quality {
        case .excellent: return .green
        case .good: return .blue
        case .fair: return .yellow
        case .poor: return .orange
        case .none: return .red
        }
    }
}

// MARK: - 연결 테스트 뷰
/// TCP/UDP 연결 테스트
struct ConnectionTestView: View {
    @EnvironmentObject var connectionManager: ConnectionManager
    
    @State private var host: String = "localhost"
    @State private var port: String = "8080"
    @State private var selectedProtocol: ConnectionProtocol = .tcp
    @State private var messageText: String = ""
    
    var body: some View {
        NavigationStack {
            List {
                // 연결 설정 섹션
                Section {
                    TextField("호스트", text: $host)
                        .textContentType(.URL)
                        #if os(iOS)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        #endif
                    
                    TextField("포트", text: $port)
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                    
                    Picker("프로토콜", selection: $selectedProtocol) {
                        ForEach(ConnectionProtocol.allCases) { proto in
                            Text(proto.rawValue).tag(proto)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    HStack {
                        Button(connectionManager.isConnected ? "연결 해제" : "연결") {
                            if connectionManager.isConnected {
                                connectionManager.disconnect()
                            } else {
                                guard let portNum = UInt16(port) else { return }
                                connectionManager.connect(host: host, port: portNum, protocol: selectedProtocol)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(connectionManager.isConnected ? .red : .blue)
                        
                        Spacer()
                        
                        // 연결 상태 표시
                        HStack {
                            Image(systemName: connectionManager.connectionState.iconName)
                                .foregroundColor(Color(connectionManager.connectionState.colorName))
                            Text(connectionManager.connectionState.displayText)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("연결 설정")
                }
                
                // 메시지 전송 섹션
                if connectionManager.isConnected {
                    Section {
                        HStack {
                            TextField("메시지 입력", text: $messageText)
                            
                            Button("전송") {
                                guard !messageText.isEmpty else { return }
                                connectionManager.send(text: messageText)
                                messageText = ""
                            }
                            .buttonStyle(.bordered)
                            .disabled(messageText.isEmpty)
                        }
                    } header: {
                        Text("메시지 전송")
                    }
                }
                
                // 메시지 히스토리 섹션
                if !connectionManager.messages.isEmpty {
                    Section {
                        ForEach(connectionManager.messages) { message in
                            HStack {
                                Image(systemName: message.isOutgoing ? "arrow.up.circle" : "arrow.down.circle")
                                    .foregroundColor(message.isOutgoing ? .blue : .green)
                                
                                VStack(alignment: .leading) {
                                    Text(message.content)
                                        .font(.body)
                                    Text(message.formattedTime)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    } header: {
                        HStack {
                            Text("메시지")
                            Spacer()
                            Button("초기화") {
                                connectionManager.clearMessages()
                            }
                            .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle("연결 테스트")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
        }
    }
}

// MARK: - 에코 서버 뷰
/// 에코 서버 제어 및 로그 표시
struct EchoServerView: View {
    @EnvironmentObject var echoServer: EchoServer
    
    @State private var port: String = "8080"
    @State private var selectedProtocol: ConnectionProtocol = .tcp
    @State private var broadcastMessage: String = ""
    
    var body: some View {
        NavigationStack {
            List {
                // 서버 제어 섹션
                Section {
                    HStack {
                        TextField("포트", text: $port)
                            #if os(iOS)
                            .keyboardType(.numberPad)
                            #endif
                            .frame(width: 100)
                        
                        Picker("프로토콜", selection: $selectedProtocol) {
                            ForEach(ConnectionProtocol.allCases) { proto in
                                Text(proto.rawValue).tag(proto)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 150)
                        
                        Spacer()
                        
                        Button(echoServer.state.isRunning ? "중지" : "시작") {
                            if echoServer.state.isRunning {
                                echoServer.stop()
                            } else {
                                let portNum = UInt16(port) ?? 0
                                if selectedProtocol == .tcp {
                                    echoServer.startTCP(port: portNum)
                                } else {
                                    echoServer.startUDP(port: portNum)
                                }
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(echoServer.state.isRunning ? .red : .green)
                    }
                    
                    // 서버 상태
                    HStack {
                        Image(systemName: echoServer.state.isRunning ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(echoServer.state.isRunning ? .green : .gray)
                        Text(echoServer.state.statusText)
                            .font(.subheadline)
                        Spacer()
                        Text("클라이언트: \(echoServer.connectedClients)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("서버 제어")
                }
                
                // 브로드캐스트 섹션
                if echoServer.state.isRunning && echoServer.connectedClients > 0 {
                    Section {
                        HStack {
                            TextField("브로드캐스트 메시지", text: $broadcastMessage)
                            
                            Button("전송") {
                                guard !broadcastMessage.isEmpty else { return }
                                echoServer.broadcast(message: broadcastMessage)
                                broadcastMessage = ""
                            }
                            .buttonStyle(.bordered)
                            .disabled(broadcastMessage.isEmpty)
                        }
                    } header: {
                        Text("브로드캐스트")
                    }
                }
                
                // 서버 로그 섹션
                Section {
                    if echoServer.logs.isEmpty {
                        Text("로그가 없습니다")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    } else {
                        ForEach(echoServer.logs.reversed()) { log in
                            HStack(alignment: .top) {
                                Text(log.formattedTime)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(width: 70, alignment: .leading)
                                
                                Text(log.message)
                                    .font(.subheadline)
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text("서버 로그")
                        Spacer()
                        Button("초기화") {
                            echoServer.clearLogs()
                        }
                        .font(.caption)
                    }
                }
            }
            .navigationTitle("에코 서버")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
        }
    }
}

// MARK: - 통계 뷰
/// 데이터 전송 통계 표시
struct StatisticsView: View {
    @EnvironmentObject var connectionManager: ConnectionManager
    @EnvironmentObject var echoServer: EchoServer
    
    var body: some View {
        NavigationStack {
            List {
                // 클라이언트 통계
                Section {
                    StatRow(title: "송신", value: connectionManager.statistics.formattedBytesSent)
                    StatRow(title: "수신", value: connectionManager.statistics.formattedBytesReceived)
                    StatRow(title: "총 전송량", value: connectionManager.statistics.formattedTotalBytes)
                    StatRow(title: "송신 패킷", value: "\(connectionManager.statistics.packetsSent)")
                    StatRow(title: "수신 패킷", value: "\(connectionManager.statistics.packetsReceived)")
                    StatRow(title: "송신 속도", value: connectionManager.statistics.formattedSendRate)
                    StatRow(title: "수신 속도", value: connectionManager.statistics.formattedReceiveRate)
                    StatRow(title: "경과 시간", value: connectionManager.statistics.formattedElapsedTime)
                } header: {
                    HStack {
                        Text("클라이언트 통계")
                        Spacer()
                        Button("초기화") {
                            connectionManager.resetStatistics()
                        }
                        .font(.caption)
                    }
                }
                
                // 서버 통계
                Section {
                    StatRow(title: "송신", value: echoServer.statistics.formattedBytesSent)
                    StatRow(title: "수신", value: echoServer.statistics.formattedBytesReceived)
                    StatRow(title: "총 전송량", value: echoServer.statistics.formattedTotalBytes)
                    StatRow(title: "송신 패킷", value: "\(echoServer.statistics.packetsSent)")
                    StatRow(title: "수신 패킷", value: "\(echoServer.statistics.packetsReceived)")
                    StatRow(title: "경과 시간", value: echoServer.statistics.formattedElapsedTime)
                } header: {
                    HStack {
                        Text("서버 통계")
                        Spacer()
                        Button("초기화") {
                            echoServer.resetStatistics()
                        }
                        .font(.caption)
                    }
                }
            }
            .navigationTitle("전송 통계")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
        }
    }
}

// MARK: - 헬퍼 뷰
/// 상세 정보 행
struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

/// 통계 행
struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(NetworkMonitor())
        .environmentObject(ConnectionManager())
        .environmentObject(EchoServer())
}
