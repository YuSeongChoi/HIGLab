import CallKit

let phoneNumber = "+821098765432"
let handle = CXHandle(type: .phoneNumber, value: phoneNumber)
let callUUID = UUID()

let startCallAction = CXStartCallAction(
    call: callUUID,
    handle: handle
)
startCallAction.isVideo = false

// CXTransaction으로 액션 래핑
let transaction = CXTransaction(action: startCallAction)
