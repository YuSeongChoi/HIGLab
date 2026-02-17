import Foundation

// MARK: - 보안 에러 정의
/// SecureVault 앱 전반에서 사용하는 통합 에러 타입
/// 각 서비스(키체인, 암호화, 생체인증, Apple 로그인)별 에러를 체계적으로 관리

/// 통합 보안 에러 열거형
/// - Note: 사용자에게 표시할 메시지와 개발자용 디버그 정보를 분리하여 관리
enum SecurityError: LocalizedError, Equatable {
    
    // MARK: - 키체인 에러
    
    /// 키체인 저장 실패
    case keychainSaveFailed(status: OSStatus)
    
    /// 키체인 로드 실패
    case keychainLoadFailed(status: OSStatus)
    
    /// 키체인 삭제 실패
    case keychainDeleteFailed(status: OSStatus)
    
    /// 키체인 업데이트 실패
    case keychainUpdateFailed(status: OSStatus)
    
    /// 키체인 항목을 찾을 수 없음
    case keychainItemNotFound
    
    /// 키체인 접근 제한됨 (기기 잠금 상태)
    case keychainAccessDenied
    
    /// 중복 키체인 항목
    case keychainDuplicateItem
    
    // MARK: - 데이터 에러
    
    /// 데이터 인코딩 실패
    case dataEncodingFailed(underlying: Error?)
    
    /// 데이터 디코딩 실패
    case dataDecodingFailed(underlying: Error?)
    
    /// 예상치 못한 데이터 형식
    case unexpectedDataFormat
    
    /// 데이터 손상됨
    case dataCorrupted(description: String)
    
    // MARK: - 생체인증 에러
    
    /// 생체 인증 실패 (잘못된 지문/얼굴)
    case biometricAuthenticationFailed
    
    /// 사용자가 인증 취소
    case biometricUserCancelled
    
    /// 생체 인증 사용 불가 (하드웨어 미지원)
    case biometricNotAvailable
    
    /// 생체 인증 미등록 (Face ID/Touch ID 설정 안 됨)
    case biometricNotEnrolled
    
    /// 생체 인증 잠김 (너무 많은 실패 시도)
    case biometricLockout
    
    /// 기기 암호 미설정
    case passcodeNotSet
    
    /// 인증 컨텍스트 무효화
    case authContextInvalidated
    
    /// 사용자가 폴백(암호 입력) 선택
    case userFallback
    
    /// 시스템에 의한 취소 (앱 전환 등)
    case systemCancelled
    
    // MARK: - 암호화 에러
    
    /// 키 생성 실패
    case keyGenerationFailed(reason: String)
    
    /// 암호화 실패
    case encryptionFailed(underlying: Error?)
    
    /// 복호화 실패
    case decryptionFailed(underlying: Error?)
    
    /// 서명 생성 실패
    case signatureCreationFailed
    
    /// 서명 검증 실패
    case signatureVerificationFailed
    
    /// Secure Enclave 사용 불가
    case secureEnclaveNotAvailable
    
    /// Secure Enclave 키 생성 실패
    case secureEnclaveKeyGenerationFailed
    
    /// 유효하지 않은 키
    case invalidKey
    
    /// 잘못된 nonce
    case invalidNonce
    
    /// 무결성 검증 실패 (인증 태그 불일치)
    case integrityCheckFailed
    
    // MARK: - Apple 로그인 에러
    
    /// Apple ID 자격 증명 취소됨
    case appleIDCredentialRevoked
    
    /// Apple ID를 찾을 수 없음
    case appleIDCredentialNotFound
    
    /// Apple 로그인 실패
    case appleSignInFailed(underlying: Error?)
    
    /// Apple 로그인 취소
    case appleSignInCancelled
    
    /// 유효하지 않은 응답
    case invalidAppleIDResponse
    
    /// 인증 세션 실패
    case authorizationSessionFailed
    
    // MARK: - 일반 에러
    
    /// 알 수 없는 에러
    case unknown(underlying: Error?)
    
    /// 작업 타임아웃
    case timeout
    
    /// 네트워크 연결 없음
    case noNetworkConnection
    
    /// 권한 없음
    case insufficientPermissions
    
    // MARK: - LocalizedError 구현
    
    /// 사용자에게 표시할 에러 설명
    var errorDescription: String? {
        switch self {
        // 키체인 에러
        case .keychainSaveFailed:
            return "보안 저장소에 데이터를 저장하지 못했습니다"
        case .keychainLoadFailed:
            return "보안 저장소에서 데이터를 불러오지 못했습니다"
        case .keychainDeleteFailed:
            return "보안 저장소에서 데이터를 삭제하지 못했습니다"
        case .keychainUpdateFailed:
            return "보안 저장소의 데이터를 업데이트하지 못했습니다"
        case .keychainItemNotFound:
            return "요청한 항목을 찾을 수 없습니다"
        case .keychainAccessDenied:
            return "보안 저장소에 접근할 수 없습니다. 기기 잠금을 해제해주세요"
        case .keychainDuplicateItem:
            return "이미 존재하는 항목입니다"
            
        // 데이터 에러
        case .dataEncodingFailed:
            return "데이터 변환에 실패했습니다"
        case .dataDecodingFailed:
            return "데이터를 읽는 데 실패했습니다"
        case .unexpectedDataFormat:
            return "예상치 못한 데이터 형식입니다"
        case .dataCorrupted(let description):
            return "데이터가 손상되었습니다: \(description)"
            
        // 생체인증 에러
        case .biometricAuthenticationFailed:
            return "인증에 실패했습니다. 다시 시도해주세요"
        case .biometricUserCancelled:
            return "인증이 취소되었습니다"
        case .biometricNotAvailable:
            return "이 기기에서는 생체 인증을 사용할 수 없습니다"
        case .biometricNotEnrolled:
            return "생체 인증이 등록되어 있지 않습니다. 설정에서 등록해주세요"
        case .biometricLockout:
            return "너무 많은 시도로 생체 인증이 잠겼습니다. 기기 암호를 입력해주세요"
        case .passcodeNotSet:
            return "기기 암호가 설정되어 있지 않습니다"
        case .authContextInvalidated:
            return "인증 세션이 만료되었습니다. 다시 시도해주세요"
        case .userFallback:
            return "암호 입력으로 전환합니다"
        case .systemCancelled:
            return "시스템에 의해 인증이 중단되었습니다"
            
        // 암호화 에러
        case .keyGenerationFailed(let reason):
            return "암호화 키 생성에 실패했습니다: \(reason)"
        case .encryptionFailed:
            return "데이터 암호화에 실패했습니다"
        case .decryptionFailed:
            return "데이터 복호화에 실패했습니다"
        case .signatureCreationFailed:
            return "서명 생성에 실패했습니다"
        case .signatureVerificationFailed:
            return "서명 검증에 실패했습니다"
        case .secureEnclaveNotAvailable:
            return "Secure Enclave을 사용할 수 없는 기기입니다"
        case .secureEnclaveKeyGenerationFailed:
            return "보안 키 생성에 실패했습니다"
        case .invalidKey:
            return "유효하지 않은 암호화 키입니다"
        case .invalidNonce:
            return "유효하지 않은 암호화 매개변수입니다"
        case .integrityCheckFailed:
            return "데이터 무결성 검증에 실패했습니다. 데이터가 변조되었을 수 있습니다"
            
        // Apple 로그인 에러
        case .appleIDCredentialRevoked:
            return "Apple ID 연결이 해제되었습니다. 다시 로그인해주세요"
        case .appleIDCredentialNotFound:
            return "Apple ID 정보를 찾을 수 없습니다"
        case .appleSignInFailed:
            return "Apple 로그인에 실패했습니다"
        case .appleSignInCancelled:
            return "Apple 로그인이 취소되었습니다"
        case .invalidAppleIDResponse:
            return "Apple로부터 유효하지 않은 응답을 받았습니다"
        case .authorizationSessionFailed:
            return "인증 세션을 시작할 수 없습니다"
            
        // 일반 에러
        case .unknown:
            return "알 수 없는 오류가 발생했습니다"
        case .timeout:
            return "작업 시간이 초과되었습니다"
        case .noNetworkConnection:
            return "네트워크 연결을 확인해주세요"
        case .insufficientPermissions:
            return "권한이 부족합니다"
        }
    }
    
    /// 복구 방법 제안
    var recoverySuggestion: String? {
        switch self {
        case .biometricNotEnrolled:
            return "설정 앱 > Face ID 및 암호에서 생체 인증을 등록해주세요"
        case .biometricLockout:
            return "기기 암호로 잠금을 해제한 후 다시 시도해주세요"
        case .passcodeNotSet:
            return "설정 앱 > Face ID 및 암호에서 암호를 설정해주세요"
        case .keychainAccessDenied:
            return "기기 잠금을 해제한 후 다시 시도해주세요"
        case .appleIDCredentialRevoked:
            return "'Apple로 로그인' 버튼을 눌러 다시 연결해주세요"
        case .integrityCheckFailed:
            return "데이터가 손상되었을 수 있습니다. 백업에서 복원하거나 새로 생성해주세요"
        case .noNetworkConnection:
            return "Wi-Fi 또는 셀룰러 데이터 연결을 확인해주세요"
        default:
            return nil
        }
    }
    
    /// 디버그용 상세 정보
    var debugDescription: String {
        switch self {
        case .keychainSaveFailed(let status):
            return "Keychain save failed with OSStatus: \(status)"
        case .keychainLoadFailed(let status):
            return "Keychain load failed with OSStatus: \(status)"
        case .keychainDeleteFailed(let status):
            return "Keychain delete failed with OSStatus: \(status)"
        case .keychainUpdateFailed(let status):
            return "Keychain update failed with OSStatus: \(status)"
        case .dataEncodingFailed(let error):
            return "Data encoding failed: \(error?.localizedDescription ?? "unknown")"
        case .dataDecodingFailed(let error):
            return "Data decoding failed: \(error?.localizedDescription ?? "unknown")"
        case .encryptionFailed(let error):
            return "Encryption failed: \(error?.localizedDescription ?? "unknown")"
        case .decryptionFailed(let error):
            return "Decryption failed: \(error?.localizedDescription ?? "unknown")"
        case .appleSignInFailed(let error):
            return "Apple Sign In failed: \(error?.localizedDescription ?? "unknown")"
        case .unknown(let error):
            return "Unknown error: \(error?.localizedDescription ?? "no details")"
        default:
            return String(describing: self)
        }
    }
    
    // MARK: - 편의 프로퍼티
    
    /// 사용자 조작으로 복구 가능한 에러인지 여부
    var isRecoverable: Bool {
        switch self {
        case .biometricUserCancelled, .biometricLockout, .userFallback,
             .systemCancelled, .appleSignInCancelled, .noNetworkConnection:
            return true
        default:
            return recoverySuggestion != nil
        }
    }
    
    /// 재시도 가능한 에러인지 여부
    var isRetryable: Bool {
        switch self {
        case .biometricAuthenticationFailed, .biometricUserCancelled,
             .systemCancelled, .timeout, .noNetworkConnection:
            return true
        default:
            return false
        }
    }
    
    /// 생체 인증 관련 에러인지 여부
    var isBiometricError: Bool {
        switch self {
        case .biometricAuthenticationFailed, .biometricUserCancelled,
             .biometricNotAvailable, .biometricNotEnrolled, .biometricLockout,
             .passcodeNotSet, .authContextInvalidated, .userFallback, .systemCancelled:
            return true
        default:
            return false
        }
    }
    
    /// 암호화 관련 에러인지 여부
    var isCryptoError: Bool {
        switch self {
        case .keyGenerationFailed, .encryptionFailed, .decryptionFailed,
             .signatureCreationFailed, .signatureVerificationFailed,
             .secureEnclaveNotAvailable, .secureEnclaveKeyGenerationFailed,
             .invalidKey, .invalidNonce, .integrityCheckFailed:
            return true
        default:
            return false
        }
    }
    
    // MARK: - Equatable
    
    static func == (lhs: SecurityError, rhs: SecurityError) -> Bool {
        // 간단한 비교를 위해 errorDescription 사용
        lhs.errorDescription == rhs.errorDescription
    }
}

// MARK: - OSStatus 확장
extension OSStatus {
    /// OSStatus 코드를 SecurityError로 변환
    /// - Parameter operation: 수행 중이던 작업 유형
    func toSecurityError(for operation: KeychainOperation) -> SecurityError {
        switch (self, operation) {
        case (errSecSuccess, _):
            fatalError("Success status should not be converted to error")
        case (errSecItemNotFound, _):
            return .keychainItemNotFound
        case (errSecDuplicateItem, _):
            return .keychainDuplicateItem
        case (errSecAuthFailed, _), (errSecInteractionNotAllowed, _):
            return .keychainAccessDenied
        case (_, .save):
            return .keychainSaveFailed(status: self)
        case (_, .load):
            return .keychainLoadFailed(status: self)
        case (_, .delete):
            return .keychainDeleteFailed(status: self)
        case (_, .update):
            return .keychainUpdateFailed(status: self)
        }
    }
}

/// 키체인 작업 유형
enum KeychainOperation {
    case save
    case load
    case delete
    case update
}

// MARK: - 에러 로깅 유틸리티
extension SecurityError {
    /// 에러를 콘솔에 로깅 (디버그 빌드에서만)
    func log(file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        print("⚠️ SecurityError at \(fileName):\(line) in \(function)")
        print("   Description: \(errorDescription ?? "none")")
        print("   Debug: \(debugDescription)")
        if let recovery = recoverySuggestion {
            print("   Recovery: \(recovery)")
        }
        #endif
    }
}
