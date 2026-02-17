import Foundation

// 사용자 친화적 에러 메시지 변환
struct UserFriendlyError {
    let title: String
    let message: String
    let suggestion: String?
    let icon: String
    
    init(from error: AccessorySetupError) {
        switch error {
        case .sessionNotActivated:
            title = "앱 초기화 필요"
            message = "액세서리 기능을 사용하려면 앱을 다시 시작해주세요."
            suggestion = nil
            icon = "arrow.clockwise"
            
        case .sessionActivationFailed:
            title = "시작할 수 없음"
            message = "액세서리 기능을 시작할 수 없습니다."
            suggestion = "앱을 종료 후 다시 실행해주세요."
            icon = "exclamationmark.circle"
            
        case .pickerCancelled:
            title = "취소됨"
            message = "기기 선택이 취소되었습니다."
            suggestion = nil
            icon = "xmark.circle"
            
        case .bluetoothUnavailable:
            title = "Bluetooth 꺼짐"
            message = "Bluetooth가 꺼져있어 기기를 찾을 수 없습니다."
            suggestion = "설정에서 Bluetooth를 켜주세요."
            icon = "bluetooth.slash"
            
        case .connectionLost:
            title = "연결 끊김"
            message = "기기와의 연결이 끊어졌습니다."
            suggestion = "기기가 가까이 있는지 확인하고 다시 연결해주세요."
            icon = "wifi.exclamationmark"
            
        case .pairingFailed(let reason):
            (title, message, suggestion) = Self.pairingFailureMessage(reason)
            icon = "xmark.circle"
            
        case .connectionFailed:
            title = "연결 실패"
            message = "기기에 연결할 수 없습니다."
            suggestion = "기기 전원을 확인하고 다시 시도해주세요."
            icon = "antenna.radiowaves.left.and.right.slash"
            
        case .alreadyPaired:
            title = "이미 연결됨"
            message = "이 기기는 이미 연결되어 있습니다."
            suggestion = nil
            icon = "checkmark.circle"
            
        default:
            title = "오류 발생"
            message = "문제가 발생했습니다."
            suggestion = "잠시 후 다시 시도해주세요."
            icon = "exclamationmark.triangle"
        }
    }
    
    private static func pairingFailureMessage(_ reason: PairingFailureReason) -> (String, String, String?) {
        switch reason {
        case .timeout:
            return ("시간 초과", "기기 검색에 시간이 너무 오래 걸렸습니다.", "기기가 페어링 모드인지 확인해주세요.")
        case .deviceNotFound:
            return ("기기 없음", "주변에서 기기를 찾을 수 없습니다.", "기기의 전원이 켜져 있는지 확인해주세요.")
        case .userDenied:
            return ("권한 필요", "기기 연결 권한이 거부되었습니다.", "설정에서 권한을 허용해주세요.")
        case .incompatible:
            return ("호환 불가", "이 기기는 지원되지 않습니다.", "지원되는 기기 목록을 확인해주세요.")
        }
    }
}
