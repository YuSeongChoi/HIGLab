import LocalAuthentication

// LAError를 사용자 친화적 메시지로 변환

extension LAError {
    var userFriendlyMessage: String {
        switch code {
        case .userCancel:
            return "인증이 취소되었습니다."
            
        case .userFallback:
            return "패스코드 인증으로 전환합니다."
            
        case .systemCancel:
            return "인증이 중단되었습니다. 다시 시도해주세요."
            
        case .biometryNotAvailable:
            return "이 기기에서는 생체 인증을 사용할 수 없습니다."
            
        case .biometryNotEnrolled:
            return "Face ID 또는 Touch ID가 설정되지 않았습니다.\n설정 앱에서 등록해주세요."
            
        case .biometryLockout:
            return "생체 인증이 잠겼습니다.\n기기 패스코드로 잠금을 해제하세요."
            
        case .passcodeNotSet:
            return "기기 패스코드를 먼저 설정해주세요."
            
        case .authenticationFailed:
            return "인증에 실패했습니다. 다시 시도해주세요."
            
        case .invalidContext:
            return "인증 세션이 만료되었습니다. 다시 시도해주세요."
            
        default:
            return "알 수 없는 오류가 발생했습니다.\n(\(code.rawValue))"
        }
    }
    
    var requiresUserAction: Bool {
        switch code {
        case .biometryNotEnrolled, .passcodeNotSet:
            return true // 설정 앱으로 안내 필요
        default:
            return false
        }
    }
}
