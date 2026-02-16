import CoreBluetooth
import Foundation

class BluetoothManager: NSObject {
    private var centralManager: CBCentralManager!
    
    override init() {
        super.init()
        
        // CBCentralManager 생성
        // - delegate: 상태 변화, 기기 발견 등 이벤트 수신
        // - queue: nil이면 메인 큐 사용
        centralManager = CBCentralManager(
            delegate: self,
            queue: nil
        )
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // Bluetooth 상태 변경 시 호출
        print("Bluetooth state: \(central.state)")
    }
}
