import CoreBluetooth

extension BluetoothManager {
    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Error?
    ) {
        if let error = error {
            print("❌ Characteristic 발견 실패: \(error.localizedDescription)")
            return
        }
        
        guard let characteristics = service.characteristics else { return }
        
        print("📋 서비스 \(service.uuid)의 Characteristics:")
        
        for characteristic in characteristics {
            print("  - \(characteristic.uuid)")
            print("    Properties: \(characteristic.properties)")
            
            // 속성에 따라 자동 동작
            if characteristic.properties.contains(.read) {
                peripheral.readValue(for: characteristic)
            }
            
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
}
