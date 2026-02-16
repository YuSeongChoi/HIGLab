// Private Email Relay 설정 가이드

/*
 Private Relay 이메일로 발송하려면 다음 설정이 필요합니다:
 
 1. Apple Developer 포털 접속
    https://developer.apple.com/account/resources/services/list
 
 2. Services > "Sign in with Apple for Email Communication" 클릭
 
 3. 발신 도메인 등록:
    - "+" 버튼 클릭
    - 도메인 입력 (예: mail.example.com)
    - DNS TXT 레코드로 소유권 확인
 
 4. 발신 이메일 주소 등록:
    - 도메인 선택 > "Register Email Sources"
    - 발신 주소 추가 (예: noreply@example.com)
 
 5. SPF 레코드 설정 (DNS):
    v=spf1 include:_spf.apple.com ~all
 
 설정 완료 후 @privaterelay.appleid.com 주소로
 이메일 발송이 가능합니다.
 */

struct PrivateRelayConfig {
    static let domain = "mail.example.com"
    static let senderEmail = "noreply@example.com"
    static let spfRecord = "v=spf1 include:_spf.apple.com ~all"
}
