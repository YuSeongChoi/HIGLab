import CallKit

let phoneNumber = "+821098765432"
let handle = CXHandle(type: .phoneNumber, value: phoneNumber)
let callUUID = UUID()

let startCallAction = CXStartCallAction(
    call: callUUID,
    handle: handle
)

// 영상 통화 여부 설정
startCallAction.isVideo = false

// 발신자 이름 (상대방에게 표시될 이름)
startCallAction.contactIdentifier = "홍길동"
