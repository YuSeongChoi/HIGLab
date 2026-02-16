import CoreBluetooth
import Foundation

class BluetoothManager: NSObject {
    private var centralManager: CBCentralManager!
    
    // 상태 퍼블리싱을 위한 프로퍼티
    var bluetoothState: CBManagerState = .unknown
    var isScanning = false
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        bluetoothState = central.state
        
        switch central.state {
        case .poweredOn:
            print("✅ Bluetooth 준비됨")
            // 이제 스캔/연결 가능
        case .poweredOff:
            print("❌ Bluetooth 꺼짐")
        case .unauthorized:
            print("⚠️ Bluetooth 권한 없음")
        case .unsupported:
            print("❌ BLE 미지원 기기")
        case .resetting:
            print("🔄 Bluetooth 재시작 중")
        case .unknown:
            print("❓ 상태 확인 중")
        @unknown default:
            print("새로운 상태")
        }
    }
}
