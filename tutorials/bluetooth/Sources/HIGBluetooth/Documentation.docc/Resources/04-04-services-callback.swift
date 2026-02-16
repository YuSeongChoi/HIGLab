import CoreBluetooth

extension BluetoothManager {
    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverServices error: Error?
    ) {
        if let error = error {
            print("❌ 서비스 발견 실패: \(error.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services else {
            print("서비스가 없음")
            return
        }
        
        print("📦 발견된 서비스: \(services.count)개")
        
        for service in services {
            print("  - \(service.uuid)")
            
            // 각 서비스의 Characteristic 발견
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
}
