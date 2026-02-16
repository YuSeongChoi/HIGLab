import Network

// IP 주소로 지정
let ipEndpoint = NWEndpoint.hostPort(
    host: NWEndpoint.Host("192.168.1.100"),
    port: NWEndpoint.Port(integerLiteral: 8080)
)

// 도메인 이름으로 지정
let domainEndpoint = NWEndpoint.hostPort(
    host: "chat.example.com",
    port: 443
)

// Bonjour 서비스로 지정
let serviceEndpoint = NWEndpoint.service(
    name: "Living Room Mac",
    type: "_mychat._tcp",
    domain: "local",
    interface: nil
)
