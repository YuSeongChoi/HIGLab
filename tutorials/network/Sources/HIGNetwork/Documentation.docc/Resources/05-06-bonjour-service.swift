import Network

// Bonjour 서비스 타입 정의
// 형식: _서비스이름._프로토콜

// TCP 기반 채팅 서비스
let chatServiceType = "_p2pchat._tcp"

// 다른 예시들:
// "_http._tcp"      - HTTP 서버
// "_ssh._tcp"       - SSH 서버
// "_ftp._tcp"       - FTP 서버
// "_ipp._tcp"       - 프린터
// "_airplay._tcp"   - AirPlay

// 서비스 이름 규칙:
// - 언더스코어(_)로 시작
// - 1-15자의 ASCII 문자
// - 프로토콜: _tcp 또는 _udp

// 도메인:
// - "local" - 로컬 네트워크 (기본값)
// - nil - 시스템 기본 도메인 사용
