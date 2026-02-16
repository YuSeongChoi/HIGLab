import CoreBluetooth

extension BluetoothManager {
    func startScanning() {
        // Bluetooth가 준비되었는지 확인
        guard centralManager.state == .poweredOn else {
            print("Bluetooth가 준비되지 않음: \(centralManager.state)")
            return
        }
        
        // 이미 스캔 중이면 리턴
        guard !isScanning else { return }
        
        // 스캔 시작 (모든 기기)
        centralManager.scanForPeripherals(
            withServices: nil,  // nil: 모든 기기 스캔
            options: [
                CBCentralManagerScanOptionAllowDuplicatesKey: false
            ]
        )
        
        isScanning = true
        print("🔍 스캔 시작")
    }
    
    func stopScanning() {
        centralManager.stopScan()
        isScanning = false
        print("⏹️ 스캔 중지")
    }
}
