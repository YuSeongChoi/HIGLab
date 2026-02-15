import CoreBluetooth

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate {
    @Published var isBluetoothOn = false
    @Published var discoveredDevices: [CBPeripheral] = []
    
    private var centralManager: CBCentralManager!
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        isBluetoothOn = (central.state == .poweredOn)
    }
}
