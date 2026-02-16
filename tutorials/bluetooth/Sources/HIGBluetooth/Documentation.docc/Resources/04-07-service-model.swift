import CoreBluetooth
import Foundation

// 발견된 서비스 구조체
struct DiscoveredService: Identifiable {
    let id = UUID()
    let service: CBService
    var characteristics: [DiscoveredCharacteristic] = []
    
    var name: String {
        // 표준 UUID면 이름 반환
        switch service.uuid.uuidString {
        case "180D": return "Heart Rate"
        case "180F": return "Battery"
        case "180A": return "Device Information"
        default: return service.uuid.uuidString
        }
    }
}

struct DiscoveredCharacteristic: Identifiable {
    let id = UUID()
    let characteristic: CBCharacteristic
    var value: Data?
    
    var canRead: Bool { characteristic.properties.contains(.read) }
    var canWrite: Bool { characteristic.properties.contains(.write) }
    var canNotify: Bool { characteristic.properties.contains(.notify) }
}

// Manager에서 저장
@Observable
class BluetoothManager {
    var discoveredServices: [DiscoveredService] = []
    // ...
}
