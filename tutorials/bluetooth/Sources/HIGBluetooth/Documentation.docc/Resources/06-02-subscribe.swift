import CoreBluetooth

extension BluetoothManager {
    func subscribe(to characteristic: CBCharacteristic) {
        guard let peripheral = connectedPeripheral else { return }
        
        guard characteristic.supportsAnyNotification else {
            print("⚠️ 알림 미지원")
            return
        }
        
        // 알림 구독 시작
        peripheral.setNotifyValue(true, for: characteristic)
        print("🔔 알림 구독 요청: \(characteristic.uuid)")
    }
    
    // 심박수 알림 구독
    func subscribeToHeartRate() {
        guard let peripheral = connectedPeripheral,
              let service = peripheral.services?.first(where: { 
                  $0.uuid == CBUUID(string: "180D") 
              }),
              let char = service.characteristics?.first(where: { 
                  $0.uuid == CBUUID(string: "2A37") 
              })
        else {
            print("심박수 Characteristic을 찾을 수 없음")
            return
        }
        
        subscribe(to: char)
    }
}
