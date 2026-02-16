import CoreBluetooth

extension BluetoothManager: CBPeripheralDelegate {
    // 연결 후 특정 서비스만 발견
    func discoverTargetServices() {
        guard let peripheral = connectedPeripheral else { return }
        
        // 관심있는 서비스만 발견 (효율적)
        let targetServices = [
            BLEServiceUUID.heartRate,
            BLEServiceUUID.battery
        ]
        
        peripheral.discoverServices(targetServices)
    }
    
    // 모든 서비스 발견 (디버깅용)
    func discoverAllServices() {
        guard let peripheral = connectedPeripheral else { return }
        peripheral.discoverServices(nil)
    }
}
