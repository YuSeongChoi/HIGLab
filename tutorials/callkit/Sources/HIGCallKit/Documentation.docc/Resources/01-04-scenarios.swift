import CallKit
import AVFoundation

// CallKit이 처리하는 시나리오:
//
// 1. 수신 전화
//    - 잠금화면/앱 내 전화 UI 표시
//    - 연락처 연동으로 발신자 정보 표시
//    - 응답/거절 처리
//
// 2. 발신 전화
//    - 시스템 통화 기록에 추가
//    - 다른 앱 오디오 중단 관리
//
// 3. 통화 중 액션
//    - 음소거, 보류, 스피커 전환
//    - DTMF 톤 전송
//    - 통화 병합 (컨퍼런스)
//
// 4. Call Directory
//    - 스팸 전화 차단
//    - 발신자 식별

class CallManager {
    private var provider: CXProvider?
    private let callController = CXCallController()
}
