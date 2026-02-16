import CoreBluetooth

extension BluetoothManager {
    func writeValueFast(
        _ data: Data,
        for characteristic: CBCharacteristic
    ) {
        guard let peripheral = connectedPeripheral else { return }
        
        // 응답 없는 쓰기를 지원하는지 확인
        guard characteristic.properties.contains(.writeWithoutResponse) else {
            print("⚠️ withoutResponse 미지원")
            return
        }
        
        // 빠른 쓰기 (응답 없음)
        peripheral.writeValue(
            data,
            for: characteristic,
            type: .withoutResponse
        )
    }
    
    // 연속 데이터 전송 (예: 조이스틱 제어)
    func sendControlData(_ x: Float, _ y: Float) {
        let xByte = UInt8(clamping: Int((x + 1) * 127.5))
        let yByte = UInt8(clamping: Int((y + 1) * 127.5))
        let data = Data([xByte, yByte])
        
        // writeValueFast(data, for: controlCharacteristic)
    }
}
