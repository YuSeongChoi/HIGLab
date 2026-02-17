import AccessorySetupKit
import CoreBluetooth

extension PairingManager {
    func processNewAccessory(_ accessory: ASAccessory) {
        // 액세서리 식별자 저장
        let identifier = accessory.bluetoothIdentifier
        UserDefaults.standard.set(identifier?.uuidString, forKey: "pairedAccessoryID")
        
        // 액세서리 정보 로깅
        print("새 액세서리 페어링됨:")
        print("  - 표시 이름: \(accessory.displayName)")
        print("  - Bluetooth ID: \(identifier?.uuidString ?? "N/A")")
        
        // Bluetooth 연결 시작
        if let btIdentifier = identifier {
            connectToBluetooth(identifier: btIdentifier)
        }
        
        // 앱 상태 업데이트
        Task { @MainActor in
            self.pairedAccessory = accessory
            self.state = .paired
        }
    }
    
    private func connectToBluetooth(identifier: UUID) {
        // CBCentralManager를 사용하여 실제 BLE 연결
        // AccessorySetupKit은 페어링만 담당, 통신은 CoreBluetooth 사용
        let peripherals = centralManager.retrievePeripherals(withIdentifiers: [identifier])
        if let peripheral = peripherals.first {
            centralManager.connect(peripheral)
        }
    }
}
