import CallKit

let phoneNumber = "+821098765432"
let handle = CXHandle(type: .phoneNumber, value: phoneNumber)

// 새 통화를 위한 UUID 생성
let callUUID = UUID()

// CXStartCallAction 생성
let startCallAction = CXStartCallAction(
    call: callUUID,
    handle: handle
)
