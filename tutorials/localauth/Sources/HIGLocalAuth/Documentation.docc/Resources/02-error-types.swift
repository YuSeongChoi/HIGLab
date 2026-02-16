import LocalAuthentication

// LAError 주요 케이스 정리

func handleAuthError(_ error: LAError) {
    switch error.code {
    // 사용자 액션
    case .userCancel:
        // 사용자가 취소 버튼 탭
        print("사용자 취소")
        
    case .userFallback:
        // 사용자가 폴백 버튼("비밀번호 입력") 탭
        print("폴백 요청")
        
    case .systemCancel:
        // 시스템이 인증 취소 (다른 앱 전환 등)
        print("시스템 취소")
        
    // 생체 인증 관련
    case .biometryNotAvailable:
        // 기기가 생체 인증을 지원하지 않음
        print("생체 인증 미지원")
        
    case .biometryNotEnrolled:
        // 생체 데이터가 등록되지 않음
        print("생체 데이터 미등록")
        
    case .biometryLockout:
        // 시도 횟수 초과로 잠금
        print("생체 인증 잠금됨")
        
    // 패스코드 관련
    case .passcodeNotSet:
        // 기기 패스코드가 설정되지 않음
        print("패스코드 미설정")
        
    // 기타
    case .authenticationFailed:
        // 인증 실패 (생체 인식 불일치)
        print("인증 실패")
        
    case .invalidContext:
        // LAContext가 무효화됨
        print("무효한 컨텍스트")
        
    default:
        print("기타 에러: \(error.localizedDescription)")
    }
}
