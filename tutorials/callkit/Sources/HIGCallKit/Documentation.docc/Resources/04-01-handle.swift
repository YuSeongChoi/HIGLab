import CallKit

// 수신자 정보를 CXHandle로 생성
let phoneNumber = "+821098765432"

let handle = CXHandle(
    type: .phoneNumber,
    value: phoneNumber
)

// Handle 타입
// .phoneNumber: 전화번호
// .emailAddress: 이메일
// .generic: 사용자 ID 등
