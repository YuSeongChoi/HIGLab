import CoreBluetooth

// 관심있는 서비스 UUID 정의
enum BLEServiceUUID {
    static let heartRate = CBUUID(string: "180D")
    static let battery = CBUUID(string: "180F")
    static let deviceInfo = CBUUID(string: "180A")
    
    // 여러 서비스를 동시에 스캔
    static let all: [CBUUID] = [heartRate, battery]
}

extension BluetoothManager {
    func scanForHeartRateDevices() {
        guard centralManager.state == .poweredOn else { return }
        
        // 심박수 서비스를 가진 기기만 스캔
        centralManager.scanForPeripherals(
            withServices: [BLEServiceUUID.heartRate],
            options: nil
        )
        
        isScanning = true
        print("🔍 심박수 기기 스캔 중...")
    }
    
    func scanForMultipleServices() {
        centralManager.scanForPeripherals(
            withServices: BLEServiceUUID.all,
            options: nil
        )
    }
}
