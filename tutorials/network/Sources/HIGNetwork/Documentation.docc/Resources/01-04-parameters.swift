import Network

// TCP 기본 파라미터
let tcpParams = NWParameters.tcp

// UDP 기본 파라미터
let udpParams = NWParameters.udp

// TLS가 적용된 TCP
let tlsParams = NWParameters.tls

// 커스텀 파라미터 생성
let customParams = NWParameters(tls: nil, tcp: NWProtocolTCP.Options())
customParams.requiredInterfaceType = .wifi  // Wi-Fi만 사용
customParams.prohibitedInterfaceTypes = [.cellular]  // 셀룰러 제외
