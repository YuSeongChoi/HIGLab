import CoreBluetooth

extension BluetoothManager {
    func unsubscribe(from characteristic: CBCharacteristic) {
        guard let peripheral = connectedPeripheral else { return }
        
        peripheral.setNotifyValue(false, for: characteristic)
        print("🔕 알림 구독 해제 요청: \(characteristic.uuid)")
    }
    
    // 모든 알림 해제
    func unsubscribeAll() {
        guard let peripheral = connectedPeripheral,
              let services = peripheral.services else { return }
        
        for service in services {
            guard let characteristics = service.characteristics else { continue }
            for char in characteristics where char.isNotifying {
                peripheral.setNotifyValue(false, for: char)
            }
        }
    }
}

// SwiftUI에서
// .onDisappear {
//     manager.unsubscribeAll()
// }
