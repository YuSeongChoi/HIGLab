import Foundation

// 인증 상태를 명확하게 표현하는 열거형

enum AuthenticationState: Equatable {
    case locked                    // 잠금 상태
    case authenticating            // 인증 중
    case authenticated             // 인증 완료
    case failed(AuthError)         // 인증 실패
}

enum AuthError: Equatable {
    case cancelled                 // 사용자 취소
    case biometryLockout           // 시도 횟수 초과
    case biometryNotEnrolled       // 생체 인증 미등록
    case biometryNotAvailable      // 생체 인증 불가
    case passcodeNotSet            // 패스코드 미설정
    case unknown(String)           // 알 수 없는 에러
    
    var message: String {
        switch self {
        case .cancelled:
            return "인증이 취소되었습니다"
        case .biometryLockout:
            return "생체 인증이 잠겼습니다"
        case .biometryNotEnrolled:
            return "설정에서 Face ID/Touch ID를 등록하세요"
        case .biometryNotAvailable:
            return "생체 인증을 사용할 수 없습니다"
        case .passcodeNotSet:
            return "기기 패스코드를 먼저 설정하세요"
        case .unknown(let message):
            return message
        }
    }
}
