import CoreBluetooth

extension BluetoothManager {
    func peripheral(
        _ peripheral: CBPeripheral,
        didWriteValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        if let error = error {
            print("❌ 쓰기 실패: \(error.localizedDescription)")
            
            // 에러 코드 확인
            if let bleError = error as? CBATTError {
                switch bleError.code {
                case .insufficientAuthentication:
                    print("인증 필요 - 기기 페어링 필요")
                case .insufficientEncryption:
                    print("암호화 필요")
                case .writeNotPermitted:
                    print("쓰기 권한 없음")
                default:
                    print("ATT 에러: \(bleError.code)")
                }
            }
            return
        }
        
        print("✅ 쓰기 성공: \(characteristic.uuid)")
    }
}
