import Network

// 경고: 암호화 없는 평문 통신의 위험성

// 평문 TCP 연결
let insecureConnection = NWConnection(
    host: "example.com",
    port: 8080,
    using: .tcp  // TLS 없음!
)

// 문제점:
// 1. 도청 (Eavesdropping)
//    - 같은 네트워크의 누구나 데이터를 볼 수 있음
//    - 비밀번호, 개인정보 노출

// 2. 중간자 공격 (Man-in-the-Middle)
//    - 공격자가 데이터를 가로채고 수정 가능
//    - 가짜 서버로 유도 가능

// 3. 데이터 변조
//    - 전송 중 데이터 수정 감지 불가

// 해결책: TLS 사용
let secureConnection = NWConnection(
    host: "example.com",
    port: 443,
    using: .tls  // TLS 암호화!
)
