import ShazamKit

/// 사용자 친화적인 에러 메시지로 변환
func userFriendlyMessage(for error: Error) -> String {
    if let shError = error as? SHError {
        switch shError.code {
        case .matchAttemptFailed:
            return "인터넷 연결을 확인해주세요"
            
        case .invalidAudioFormat, .audioDiscontinuity:
            return "오디오 입력에 문제가 있습니다. 다시 시도해주세요"
            
        case .signatureInvalid, .signatureDurationInvalid:
            return "인식하기 어렵습니다. 음악에 더 가까이 가주세요"
            
        case .customCatalogInvalid, .customCatalogInvalidURL:
            return "카탈로그 파일에 문제가 있습니다"
            
        case .internalError:
            return "일시적인 문제가 발생했습니다. 잠시 후 다시 시도해주세요"
            
        default:
            return "알 수 없는 오류가 발생했습니다"
        }
    }
    
    // 네트워크 에러 체크
    if (error as NSError).domain == NSURLErrorDomain {
        return "인터넷 연결을 확인해주세요"
    }
    
    return error.localizedDescription
}
