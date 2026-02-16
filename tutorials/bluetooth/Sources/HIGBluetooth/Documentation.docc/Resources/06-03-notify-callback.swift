import CoreBluetooth

extension BluetoothManager {
    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateNotificationStateFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        if let error = error {
            print("❌ 알림 구독 실패: \(error.localizedDescription)")
            
            // 재시도
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                peripheral.setNotifyValue(true, for: characteristic)
            }
            return
        }
        
        if characteristic.isNotifying {
            print("✅ 알림 구독 성공: \(characteristic.uuid)")
        } else {
            print("🔕 알림 구독 해제됨: \(characteristic.uuid)")
        }
    }
}
