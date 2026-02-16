import Network

// TCP 기본 파라미터
let parameters = NWParameters.tcp

// TCP 옵션 커스터마이징
let tcpOptions = NWProtocolTCP.Options()
tcpOptions.noDelay = true  // Nagle 알고리즘 비활성화 (지연 감소)
tcpOptions.connectionTimeout = 10  // 연결 타임아웃 10초
tcpOptions.enableKeepalive = true  // Keep-alive 활성화
tcpOptions.keepaliveInterval = 30  // 30초마다 keep-alive

let customParams = NWParameters(tls: nil, tcp: tcpOptions)
