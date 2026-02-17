import AccessorySetupKit
import Foundation

// AccessorySetupKit 에러 분류
enum AccessorySetupError: LocalizedError {
    // 세션 관련
    case sessionNotActivated
    case sessionActivationFailed(underlying: Error)
    
    // 피커 관련
    case pickerCancelled
    case pickerFailed(underlying: Error)
    
    // 페어링 관련
    case pairingFailed(reason: PairingFailureReason)
    case alreadyPaired
    
    // 연결 관련
    case connectionFailed
    case connectionLost
    case bluetoothUnavailable
    
    // 일반
    case unknown(underlying: Error)
    
    var errorDescription: String? {
        switch self {
        case .sessionNotActivated:
            return "세션이 활성화되지 않았습니다"
        case .sessionActivationFailed:
            return "세션 활성화에 실패했습니다"
        case .pickerCancelled:
            return "기기 선택이 취소되었습니다"
        case .pickerFailed:
            return "기기 선택 화면을 표시할 수 없습니다"
        case .pairingFailed(let reason):
            return "페어링 실패: \(reason.description)"
        case .alreadyPaired:
            return "이미 페어링된 기기입니다"
        case .connectionFailed:
            return "연결에 실패했습니다"
        case .connectionLost:
            return "연결이 끊어졌습니다"
        case .bluetoothUnavailable:
            return "Bluetooth를 사용할 수 없습니다"
        case .unknown:
            return "알 수 없는 오류가 발생했습니다"
        }
    }
}

enum PairingFailureReason {
    case timeout
    case userDenied
    case deviceNotFound
    case incompatible
    
    var description: String {
        switch self {
        case .timeout: return "시간 초과"
        case .userDenied: return "사용자 거부"
        case .deviceNotFound: return "기기를 찾을 수 없음"
        case .incompatible: return "호환되지 않는 기기"
        }
    }
}

// ASError 변환
extension AccessorySetupError {
    static func from(_ error: Error) -> AccessorySetupError {
        if let asError = error as? ASError {
            switch asError.code {
            case .activationFailed:
                return .sessionActivationFailed(underlying: asError)
            case .pickerAlreadyActive, .userCancelled:
                return .pickerCancelled
            default:
                return .unknown(underlying: asError)
            }
        }
        return .unknown(underlying: error)
    }
}
