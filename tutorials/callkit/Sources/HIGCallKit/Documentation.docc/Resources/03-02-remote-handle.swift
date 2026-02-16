import CallKit

let update = CXCallUpdate()

// 발신자 전화번호 설정
// CXHandle 타입: .phoneNumber, .emailAddress, .generic
update.remoteHandle = CXHandle(
    type: .phoneNumber,
    value: "+821012345678"
)
