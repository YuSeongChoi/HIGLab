import CoreBluetooth

extension BluetoothManager {
    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        if let error = error {
            print("❌ 값 읽기 실패: \(error.localizedDescription)")
            return
        }
        
        guard let data = characteristic.value else {
            print("값이 없음")
            return
        }
        
        print("📥 값 수신 [\(characteristic.uuid)]: \(data.hexString)")
        
        // UUID에 따라 다른 파싱
        switch characteristic.uuid {
        case CBUUID(string: "2A37"):  // 심박수
            handleHeartRateData(data)
        case CBUUID(string: "2A19"):  // 배터리
            handleBatteryLevel(data)
        default:
            print("Raw data: \(data)")
        }
    }
    
    private func handleHeartRateData(_ data: Data) {
        // 첫 바이트가 플래그, 두번째가 심박수
        if data.count >= 2 {
            let heartRate = data[1]
            print("💓 심박수: \(heartRate) BPM")
        }
    }
    
    private func handleBatteryLevel(_ data: Data) {
        if let level = data.first {
            print("🔋 배터리: \(level)%")
        }
    }
}
