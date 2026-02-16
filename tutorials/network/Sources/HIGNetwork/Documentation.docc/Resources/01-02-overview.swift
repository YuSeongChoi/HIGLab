import Network

// NWConnection: TCP/UDP 연결을 나타냄
let connection = NWConnection(
    host: "example.com",
    port: 8080,
    using: .tcp
)

// NWListener: 서버로 동작하며 연결 수신
let listener = try? NWListener(using: .tcp)

// NWBrowser: Bonjour 서비스 탐색
let browser = NWBrowser(
    for: .bonjour(type: "_mychat._tcp", domain: nil),
    using: .tcp
)

// NWPathMonitor: 네트워크 상태 감시
let monitor = NWPathMonitor()
