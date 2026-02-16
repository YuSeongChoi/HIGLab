import CoreBluetooth
import Foundation
import Observation

@Observable
class BluetoothManager: NSObject {
    private var centralManager: CBCentralManager!
    
    // @Observable이 자동으로 변경 추적
    var bluetoothState: CBManagerState = .unknown
    var isScanning = false
    var discoveredDevices: [DiscoveredDevice] = []
    var connectedPeripheral: CBPeripheral?
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    var isBluetoothReady: Bool {
        bluetoothState == .poweredOn
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        bluetoothState = central.state
    }
}

// SwiftUI에서 사용
// struct ContentView: View {
//     @State private var manager = BluetoothManager()
//     
//     var body: some View {
//         if manager.isBluetoothReady {
//             ScanView()
//         } else {
//             BluetoothStatusView()
//         }
//     }
// }
