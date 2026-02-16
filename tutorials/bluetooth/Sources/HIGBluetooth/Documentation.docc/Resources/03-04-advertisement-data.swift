import CoreBluetooth

// Advertisement Data 파싱
extension DiscoveredDevice {
    // 광고 중인 서비스 UUID들
    var serviceUUIDs: [CBUUID] {
        advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] ?? []
    }
    
    // 제조사 데이터
    var manufacturerData: Data? {
        advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data
    }
    
    // 전송 파워 (거리 추정용)
    var txPowerLevel: Int? {
        advertisementData[CBAdvertisementDataTxPowerLevelKey] as? Int
    }
    
    // 연결 가능 여부
    var isConnectable: Bool {
        advertisementData[CBAdvertisementDataIsConnectable] as? Bool ?? true
    }
    
    // 추정 거리 (미터)
    var estimatedDistance: Double? {
        guard let txPower = txPowerLevel else { return nil }
        // 간단한 거리 추정 공식
        let ratio = Double(rssi) / Double(txPower)
        if ratio < 1.0 {
            return pow(ratio, 10)
        }
        return 0.89976 * pow(ratio, 7.7095) + 0.111
    }
}
