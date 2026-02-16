import ShazamKit

// SHError - ShazamKit 에러 타입
func describeSHError(_ error: Error) {
    guard let shError = error as? SHError else {
        print("알 수 없는 에러: \(error.localizedDescription)")
        return
    }
    
    switch shError.code {
    case .invalidAudioFormat:
        print("오디오 포맷이 올바르지 않습니다")
        
    case .audioDiscontinuity:
        print("오디오 스트림이 끊겼습니다")
        
    case .signatureInvalid:
        print("시그니처가 유효하지 않습니다")
        
    case .signatureDurationInvalid:
        print("시그니처 길이가 유효하지 않습니다")
        
    case .matchAttemptFailed:
        print("매칭 시도가 실패했습니다 (네트워크 문제?)")
        
    case .customCatalogInvalid:
        print("커스텀 카탈로그가 유효하지 않습니다")
        
    case .customCatalogInvalidURL:
        print("카탈로그 URL이 잘못되었습니다")
        
    case .mediaLibrarySyncFailed:
        print("미디어 라이브러리 동기화 실패")
        
    case .internalError:
        print("내부 오류가 발생했습니다")
        
    @unknown default:
        print("알 수 없는 ShazamKit 에러")
    }
}
