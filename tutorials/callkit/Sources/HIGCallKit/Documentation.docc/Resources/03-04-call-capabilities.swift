import CallKit

let update = CXCallUpdate()

update.remoteHandle = CXHandle(
    type: .phoneNumber,
    value: "+821012345678"
)
update.localizedCallerName = "홍길동"

// 통화 속성 설정
update.hasVideo = false           // 영상 통화 여부
update.supportsGrouping = false   // 컨퍼런스 콜 지원
update.supportsUngrouping = false // 컨퍼런스에서 분리 지원
update.supportsHolding = true     // 보류 지원
update.supportsDTMF = true        // DTMF 톤 지원
