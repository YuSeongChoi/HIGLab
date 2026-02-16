import CoreBluetooth
import Foundation

struct DiscoveredDevice: Identifiable, Equatable {
    let id: UUID  // peripheral.identifier
    let peripheral: CBPeripheral
    var name: String
    var rssi: Int
    var advertisementData: [String: Any]
    var lastSeen: Date
    
    static func == (lhs: DiscoveredDevice, rhs: DiscoveredDevice) -> Bool {
        lhs.id == rhs.id
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        let deviceName = peripheral.name 
            ?? advertisementData[CBAdvertisementDataLocalNameKey] as? String
            ?? "알 수 없는 기기"
        
        let device = DiscoveredDevice(
            id: peripheral.identifier,
            peripheral: peripheral,
            name: deviceName,
            rssi: RSSI.intValue,
            advertisementData: advertisementData,
            lastSeen: Date()
        )
        
        // 중복 제거 및 업데이트
        if let index = discoveredDevices.firstIndex(where: { $0.id == device.id }) {
            discoveredDevices[index] = device
        } else {
            discoveredDevices.append(device)
        }
    }
}
