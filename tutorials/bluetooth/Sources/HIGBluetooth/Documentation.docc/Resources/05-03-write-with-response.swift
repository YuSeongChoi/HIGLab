import CoreBluetooth

extension BluetoothManager {
    func writeValue(
        _ data: Data,
        for characteristic: CBCharacteristic
    ) {
        guard let peripheral = connectedPeripheral else { return }
        
        // 쓰기 가능한지 확인
        guard characteristic.properties.contains(.write) else {
            print("⚠️ 이 Characteristic은 쓰기를 지원하지 않음")
            return
        }
        
        // 응답을 받는 쓰기
        peripheral.writeValue(
            data,
            for: characteristic,
            type: .withResponse
        )
        
        print("✍️ 값 쓰기 요청: \(data.hexString)")
    }
}

// 사용 예: LED 색상 변경
func setLEDColor(red: UInt8, green: UInt8, blue: UInt8) {
    let data = Data([red, green, blue])
    // writeValue(data, for: ledCharacteristic)
}
