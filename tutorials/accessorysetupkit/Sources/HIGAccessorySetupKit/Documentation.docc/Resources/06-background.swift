import CoreBluetooth
import UIKit

// Info.plist에 필요한 설정:
// UIBackgroundModes: bluetooth-central
// NSBluetoothAlwaysUsageDescription: "액세서리와 통신하기 위해 Bluetooth가 필요합니다."

class BackgroundConnectionManager: NSObject, CBCentralManagerDelegate {
    private var centralManager: CBCentralManager!
    private var connectedPeripherals: [CBPeripheral] = []
    
    override init() {
        super.init()
        
        // 백그라운드 복원 지원 설정
        centralManager = CBCentralManager(
            delegate: self,
            queue: nil,
            options: [
                CBCentralManagerOptionRestoreIdentifierKey: "com.app.accessory.central"
            ]
        )
    }
    
    // MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            // 이전에 연결된 기기 복원
            restorePreviousConnections()
        }
    }
    
    // 앱 재시작 시 백그라운드 연결 복원
    func centralManager(_ central: CBCentralManager,
                        willRestoreState dict: [String: Any]) {
        if let peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral] {
            connectedPeripherals = peripherals
            for peripheral in peripherals {
                peripheral.delegate = self
            }
        }
    }
    
    private func restorePreviousConnections() {
        guard let savedID = UserDefaults.standard.string(forKey: "pairedAccessoryID"),
              let uuid = UUID(uuidString: savedID) else { return }
        
        let peripherals = centralManager.retrievePeripherals(withIdentifiers: [uuid])
        for peripheral in peripherals {
            centralManager.connect(peripheral)
        }
    }
}

extension BackgroundConnectionManager: CBPeripheralDelegate {
    // 페리퍼럴 이벤트 처리
}
