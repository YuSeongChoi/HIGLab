import CallKit

let update = CXCallUpdate()

update.remoteHandle = CXHandle(
    type: .phoneNumber,
    value: "+821012345678"
)

// 발신자 이름 (연락처에 없는 경우 표시)
update.localizedCallerName = "홍길동"
