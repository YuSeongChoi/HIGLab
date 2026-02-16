import CoreBluetooth

extension BluetoothManager {
    // 연결 성공
    func centralManager(
        _ central: CBCentralManager,
        didConnect peripheral: CBPeripheral
    ) {
        print("✅ 연결됨: \(peripheral.name ?? "Unknown")")
        
        // Peripheral의 delegate 설정
        peripheral.delegate = self
        
        // 서비스 발견 시작
        peripheral.discoverServices(nil)  // nil: 모든 서비스
    }
    
    // 연결 실패
    func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
        error: Error?
    ) {
        print("❌ 연결 실패: \(error?.localizedDescription ?? "Unknown error")")
        connectedPeripheral = nil
    }
    
    // 연결 해제
    func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: Error?
    ) {
        if let error = error {
            print("⚠️ 예상치 못한 연결 해제: \(error.localizedDescription)")
            // 재연결 로직...
        } else {
            print("🔌 연결 해제됨")
        }
        connectedPeripheral = nil
    }
}
