import CoreBluetooth

extension CBManagerState {
    var description: String {
        switch self {
        case .poweredOn:
            return "Bluetooth가 켜져 있습니다"
        case .poweredOff:
            return "Bluetooth가 꺼져 있습니다. 설정에서 켜주세요."
        case .unauthorized:
            return "앱에 Bluetooth 권한이 없습니다. 설정에서 허용해주세요."
        case .unsupported:
            return "이 기기는 BLE를 지원하지 않습니다."
        case .resetting:
            return "Bluetooth가 재시작 중입니다..."
        case .unknown:
            return "Bluetooth 상태 확인 중..."
        @unknown default:
            return "알 수 없는 상태"
        }
    }
    
    var systemImageName: String {
        switch self {
        case .poweredOn: return "antenna.radiowaves.left.and.right"
        case .poweredOff: return "antenna.radiowaves.left.and.right.slash"
        case .unauthorized: return "lock.shield"
        case .unsupported: return "xmark.circle"
        default: return "questionmark.circle"
        }
    }
}
