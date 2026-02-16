import CoreBluetooth

extension BluetoothManager {
    func readValue(for characteristic: CBCharacteristic) {
        guard let peripheral = connectedPeripheral else { return }
        
        // 읽기 가능한지 확인
        guard characteristic.properties.contains(.read) else {
            print("⚠️ 이 Characteristic은 읽기를 지원하지 않음")
            return
        }
        
        peripheral.readValue(for: characteristic)
        print("📖 값 읽기 요청: \(characteristic.uuid)")
    }
    
    // 특정 UUID로 Characteristic 찾아서 읽기
    func readCharacteristic(uuid: CBUUID, in serviceUUID: CBUUID) {
        guard let peripheral = connectedPeripheral,
              let service = peripheral.services?.first(where: { $0.uuid == serviceUUID }),
              let char = service.characteristics?.first(where: { $0.uuid == uuid })
        else {
            print("Characteristic을 찾을 수 없음")
            return
        }
        
        peripheral.readValue(for: char)
    }
}
