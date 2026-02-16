import ShazamKit

// SHManagedSession - iOS 17의 게임 체인저
@available(iOS 17.0, *)
struct ManagedSessionFeatures {
    // SHManagedSession이 자동으로 처리하는 것들
    // ✅ 마이크 오디오 입력
    // ✅ 시그니처 생성
    // ✅ 카탈로그 매칭
    // ✅ 세션 상태 관리
    
    // 개발자가 처리해야 하는 것
    // ⚠️ 마이크 권한 요청 UI
    // ⚠️ 매칭 결과 UI
    // ⚠️ 에러 처리 UI
    
    let session = SHManagedSession()
}
