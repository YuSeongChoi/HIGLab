import AccessorySetupKit
import CoreBluetooth
import Combine

@Observable
class ConnectionMonitor {
    var connectionState: ConnectionState = .disconnected
    var signalStrength: Int? // RSSI
    
    private var centralManager: CBCentralManager!
    private var connectedPeripheral: CBPeripheral?
    private var rssiTimer: Timer?
    
    enum ConnectionState {
        case disconnected
        case connecting
        case connected
        case reconnecting
        
        var icon: String {
            switch self {
            case .disconnected: return "wifi.slash"
            case .connecting, .reconnecting: return "wifi.exclamationmark"
            case .connected: return "wifi"
            }
        }
    }
    
    func startMonitoring(for accessory: ASAccessory) {
        guard let identifier = accessory.bluetoothIdentifier else { return }
        
        // 연결 상태 모니터링
        let peripherals = centralManager.retrievePeripherals(withIdentifiers: [identifier])
        guard let peripheral = peripherals.first else { return }
        
        connectedPeripheral = peripheral
        centralManager.connect(peripheral, options: [
            CBConnectPeripheralOptionNotifyOnDisconnectionKey: true
        ])
        
        // RSSI 주기적 읽기
        startRSSIMonitoring()
    }
    
    private func startRSSIMonitoring() {
        rssiTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.connectedPeripheral?.readRSSI()
        }
    }
    
    func stopMonitoring() {
        rssiTimer?.invalidate()
        rssiTimer = nil
        if let peripheral = connectedPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
}
