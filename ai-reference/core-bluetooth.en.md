# Core Bluetooth AI Reference

> BLE device connection and communication guide. Read this document to implement Bluetooth LE functionality.

## Overview

Core Bluetooth is a framework for communicating with Bluetooth Low Energy (BLE) devices.
It supports both Central (scan/connect) and Peripheral (advertise/provide services) roles.

## Required Import

```swift
import CoreBluetooth
```

## Info.plist Setup

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Bluetooth permission is required to discover and connect to nearby BLE devices.</string>
```

## Core Components (Central Role)

### 1. CBCentralManager (Scan/Connection Management)

```swift
class BluetoothManager: NSObject, ObservableObject {
    private var centralManager: CBCentralManager!
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScanning() {
        // Filter by specific service UUID (nil for all devices)
        centralManager.scanForPeripherals(
            withServices: [CBUUID(string: "180D")],  // Heart Rate Service
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: false]
        )
    }
    
    func stopScanning() {
        centralManager.stopScan()
    }
    
    func connect(_ peripheral: CBPeripheral) {
        centralManager.connect(peripheral, options: nil)
    }
    
    func disconnect(_ peripheral: CBPeripheral) {
        centralManager.cancelPeripheralConnection(peripheral)
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Bluetooth is on")
            startScanning()
        case .poweredOff:
            print("Bluetooth is off")
        case .unauthorized:
            print("Unauthorized")
        default:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, 
                       didDiscover peripheral: CBPeripheral,
                       advertisementData: [String: Any],
                       rssi RSSI: NSNumber) {
        print("Discovered: \(peripheral.name ?? "Unknown") RSSI: \(RSSI)")
        // Add to device list
    }
    
    func centralManager(_ central: CBCentralManager, 
                       didConnect peripheral: CBPeripheral) {
        print("Connected: \(peripheral.name ?? "")")
        peripheral.delegate = self
        peripheral.discoverServices(nil)  // Discover all services
    }
    
    func centralManager(_ central: CBCentralManager,
                       didFailToConnect peripheral: CBPeripheral,
                       error: Error?) {
        print("Connection failed: \(error?.localizedDescription ?? "")")
    }
    
    func centralManager(_ central: CBCentralManager,
                       didDisconnectPeripheral peripheral: CBPeripheral,
                       error: Error?) {
        print("Disconnected: \(peripheral.name ?? "")")
    }
}
```

### 2. CBPeripheral (Device Communication)

```swift
extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, 
                   didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            print("Service: \(service.uuid)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                   didDiscoverCharacteristicsFor service: CBService,
                   error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for char in characteristics {
            print("Characteristic: \(char.uuid)")
            
            // Read
            if char.properties.contains(.read) {
                peripheral.readValue(for: char)
            }
            
            // Subscribe to notifications
            if char.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: char)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                   didUpdateValueFor characteristic: CBCharacteristic,
                   error: Error?) {
        guard let data = characteristic.value else { return }
        print("Value received: \(data)")
        // Parse data
    }
    
    // Write
    func writeValue(_ data: Data, to characteristic: CBCharacteristic, 
                   peripheral: CBPeripheral) {
        if characteristic.properties.contains(.writeWithoutResponse) {
            peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
        } else {
            peripheral.writeValue(data, for: characteristic, type: .withResponse)
        }
    }
}
```

## Complete Working Example: BLE Scanner

```swift
import SwiftUI
import CoreBluetooth

// MARK: - Discovered Device Model
struct DiscoveredDevice: Identifiable {
    let id: UUID
    let peripheral: CBPeripheral
    let name: String
    let rssi: Int
    var isConnected = false
}

// MARK: - Bluetooth Manager
@Observable
class BLEManager: NSObject {
    var devices: [DiscoveredDevice] = []
    var isScanning = false
    var isPoweredOn = false
    var connectedDevice: CBPeripheral?
    var receivedData: String = ""
    
    private var centralManager: CBCentralManager!
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScan() {
        guard isPoweredOn else { return }
        devices.removeAll()
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        isScanning = true
    }
    
    func stopScan() {
        centralManager.stopScan()
        isScanning = false
    }
    
    func connect(_ device: DiscoveredDevice) {
        stopScan()
        centralManager.connect(device.peripheral, options: nil)
    }
    
    func disconnect() {
        if let peripheral = connectedDevice {
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
}

extension BLEManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        isPoweredOn = central.state == .poweredOn
    }
    
    func centralManager(_ central: CBCentralManager,
                       didDiscover peripheral: CBPeripheral,
                       advertisementData: [String: Any],
                       rssi RSSI: NSNumber) {
        // Only add devices with names
        guard let name = peripheral.name, !name.isEmpty else { return }
        
        // Check for duplicates
        if !devices.contains(where: { $0.peripheral.identifier == peripheral.identifier }) {
            let device = DiscoveredDevice(
                id: peripheral.identifier,
                peripheral: peripheral,
                name: name,
                rssi: RSSI.intValue
            )
            devices.append(device)
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                       didConnect peripheral: CBPeripheral) {
        connectedDevice = peripheral
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        
        // Update connection status
        if let index = devices.firstIndex(where: { $0.id == peripheral.identifier }) {
            devices[index].isConnected = true
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                       didDisconnectPeripheral peripheral: CBPeripheral,
                       error: Error?) {
        connectedDevice = nil
        
        if let index = devices.firstIndex(where: { $0.id == peripheral.identifier }) {
            devices[index].isConnected = false
        }
    }
}

extension BLEManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral,
                   didDiscoverServices error: Error?) {
        peripheral.services?.forEach { service in
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                   didDiscoverCharacteristicsFor service: CBService,
                   error: Error?) {
        service.characteristics?.forEach { char in
            if char.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: char)
            }
            if char.properties.contains(.read) {
                peripheral.readValue(for: char)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                   didUpdateValueFor characteristic: CBCharacteristic,
                   error: Error?) {
        if let data = characteristic.value,
           let string = String(data: data, encoding: .utf8) {
            receivedData = string
        }
    }
}

// MARK: - View
struct BLEScannerView: View {
    @State private var bleManager = BLEManager()
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    if bleManager.isScanning {
                        HStack {
                            ProgressView()
                            Text("Scanning...")
                        }
                    }
                }
                
                Section("Discovered Devices (\(bleManager.devices.count))") {
                    ForEach(bleManager.devices) { device in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(device.name)
                                    .font(.headline)
                                Text("RSSI: \(device.rssi) dBm")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            if device.isConnected {
                                Text("Connected")
                                    .foregroundStyle(.green)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if device.isConnected {
                                bleManager.disconnect()
                            } else {
                                bleManager.connect(device)
                            }
                        }
                    }
                }
                
                if !bleManager.receivedData.isEmpty {
                    Section("Received Data") {
                        Text(bleManager.receivedData)
                            .font(.system(.body, design: .monospaced))
                    }
                }
            }
            .navigationTitle("BLE Scanner")
            .toolbar {
                Button(bleManager.isScanning ? "Stop" : "Scan") {
                    if bleManager.isScanning {
                        bleManager.stopScan()
                    } else {
                        bleManager.startScan()
                    }
                }
                .disabled(!bleManager.isPoweredOn)
            }
        }
    }
}

#Preview {
    BLEScannerView()
}
```

## Common BLE Service UUIDs

```swift
struct BLEServiceUUID {
    static let heartRate = CBUUID(string: "180D")
    static let battery = CBUUID(string: "180F")
    static let deviceInfo = CBUUID(string: "180A")
    static let bloodPressure = CBUUID(string: "1810")
    static let glucose = CBUUID(string: "1808")
    
    // Nordic UART Service
    static let nordicUART = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
}
```

## Background Support

```swift
// Info.plist
<key>UIBackgroundModes</key>
<array>
    <string>bluetooth-central</string>
</array>

// Create with restoration identifier
centralManager = CBCentralManager(
    delegate: self,
    queue: nil,
    options: [CBCentralManagerOptionRestoreIdentifierKey: "myBLEManager"]
)

// Restoration delegate
func centralManager(_ central: CBCentralManager,
                   willRestoreState dict: [String: Any]) {
    if let peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral] {
        // Handle restored connections
    }
}
```

## Important Notes

1. **Permissions**: iOS 13+ requires NSBluetoothAlwaysUsageDescription
2. **Main Thread**: UI updates must be on main thread
3. **Strong Reference**: Peripheral must be strongly referenced during connection
4. **UUID Format**: "180D" (16-bit) or full UUID (128-bit)
5. **Simulator**: Bluetooth testing not possible, real device required
