import CoreBluetooth

extension BluetoothManager {
    func connect(to peripheral: CBPeripheral) {
        // 중요: Peripheral 참조를 유지해야 함
        // 참조가 사라지면 연결이 자동 해제됨
        self.connectedPeripheral = peripheral
        
        // 스캔 중지 (배터리 절약)
        stopScanning()
        
        // 연결 시작
        centralManager.connect(peripheral, options: [
            // 연결 성공 시 시스템 알림 (백그라운드용)
            CBConnectPeripheralOptionNotifyOnConnectionKey: true,
            // 연결 해제 시 시스템 알림
            CBConnectPeripheralOptionNotifyOnDisconnectionKey: true
        ])
        
        print("🔗 연결 시도 중: \(peripheral.name ?? "Unknown")")
    }
    
    func disconnect() {
        guard let peripheral = connectedPeripheral else { return }
        centralManager.cancelPeripheralConnection(peripheral)
    }
}
