import Network

// UDP 기본 파라미터
let udpParams = NWParameters.udp

// UDP 옵션 커스터마이징
let udpOptions = NWProtocolUDP.Options()
// UDP는 TCP보다 옵션이 적음

let customParams = NWParameters(dtls: nil, udp: udpOptions)

// 특정 인터페이스만 사용
customParams.requiredInterfaceType = .wifi

// 멀티캐스트/브로드캐스트 허용
customParams.allowLocalEndpointReuse = true
