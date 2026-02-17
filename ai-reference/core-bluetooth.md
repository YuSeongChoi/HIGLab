# Core Bluetooth AI Reference

> BLE 기기 연결 및 통신 가이드. 이 문서를 읽고 Bluetooth LE 기능을 구현할 수 있습니다.

## 개요

Core Bluetooth는 Bluetooth Low Energy(BLE) 기기와 통신하는 프레임워크입니다.
Central(스캔/연결)과 Peripheral(광고/서비스 제공) 역할을 지원합니다.

## 필수 Import

```swift
import CoreBluetooth
```

## Info.plist 설정

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>주변 BLE 기기를 검색하고 연결하기 위해 블루투스 권한이 필요합니다.</string>
```

## 핵심 구성요소 (Central 역할)

### 1. CBCentralManager (스캔/연결 관리)

```swift
class BluetoothManager: NSObject, ObservableObject {
    private var centralManager: CBCentralManager!
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScanning() {
        // 특정 서비스 UUID로 필터링 (nil이면 모든 기기)
        centralManager.scanForPeripherals(
            withServices: [CBUUID(string: "180D")],  // 심박 서비스
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
            print("블루투스 켜짐")
            startScanning()
        case .poweredOff:
            print("블루투스 꺼짐")
        case .unauthorized:
            print("권한 없음")
        default:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, 
                       didDiscover peripheral: CBPeripheral,
                       advertisementData: [String: Any],
                       rssi RSSI: NSNumber) {
        print("발견: \(peripheral.name ?? "Unknown") RSSI: \(RSSI)")
        // 기기 목록에 추가
    }
    
    func centralManager(_ central: CBCentralManager, 
                       didConnect peripheral: CBPeripheral) {
        print("연결됨: \(peripheral.name ?? "")")
        peripheral.delegate = self
        peripheral.discoverServices(nil)  // 모든 서비스 검색
    }
    
    func centralManager(_ central: CBCentralManager,
                       didFailToConnect peripheral: CBPeripheral,
                       error: Error?) {
        print("연결 실패: \(error?.localizedDescription ?? "")")
    }
    
    func centralManager(_ central: CBCentralManager,
                       didDisconnectPeripheral peripheral: CBPeripheral,
                       error: Error?) {
        print("연결 해제: \(peripheral.name ?? "")")
    }
}
```

### 2. CBPeripheral (기기 통신)

```swift
extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, 
                   didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            print("서비스: \(service.uuid)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                   didDiscoverCharacteristicsFor service: CBService,
                   error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for char in characteristics {
            print("특성: \(char.uuid)")
            
            // 읽기
            if char.properties.contains(.read) {
                peripheral.readValue(for: char)
            }
            
            // 알림 구독
            if char.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: char)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                   didUpdateValueFor characteristic: CBCharacteristic,
                   error: Error?) {
        guard let data = characteristic.value else { return }
        print("값 수신: \(data)")
        // 데이터 파싱
    }
    
    // 쓰기
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

## 전체 작동 예제: BLE 스캐너

```swift
import SwiftUI
import CoreBluetooth

// MARK: - 발견된 기기 모델
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
        // 이름 있는 기기만 추가
        guard let name = peripheral.name, !name.isEmpty else { return }
        
        // 중복 체크
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
        
        // 연결 상태 업데이트
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
                            Text("스캔 중...")
                        }
                    }
                }
                
                Section("발견된 기기 (\(bleManager.devices.count))") {
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
                                Text("연결됨")
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
                    Section("수신 데이터") {
                        Text(bleManager.receivedData)
                            .font(.system(.body, design: .monospaced))
                    }
                }
            }
            .navigationTitle("BLE 스캐너")
            .toolbar {
                Button(bleManager.isScanning ? "중지" : "스캔") {
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

## 일반적인 BLE 서비스 UUID

```swift
struct BLEServiceUUID {
    static let heartRate = CBUUID(string: "180D")
    static let battery = CBUUID(string: "180F")
    static let deviceInfo = CBUUID(string: "180A")
    static let bloodPressure = CBUUID(string: "1810")
    static let glucose = CBUUID(string: "1808")
    
    // Nordic UART 서비스
    static let nordicUART = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
}
```

## 백그라운드 지원

```swift
// Info.plist
<key>UIBackgroundModes</key>
<array>
    <string>bluetooth-central</string>
</array>

// 복원 식별자와 함께 생성
centralManager = CBCentralManager(
    delegate: self,
    queue: nil,
    options: [CBCentralManagerOptionRestoreIdentifierKey: "myBLEManager"]
)

// 복원 델리게이트
func centralManager(_ central: CBCentralManager,
                   willRestoreState dict: [String: Any]) {
    if let peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral] {
        // 복원된 연결 처리
    }
}
```

## 주의사항

1. **권한**: iOS 13+ NSBluetoothAlwaysUsageDescription 필수
2. **메인 스레드**: UI 업데이트는 메인 스레드에서
3. **강한 참조**: Peripheral은 연결 중 강하게 참조해야 함
4. **UUID 형식**: "180D" (16비트) 또는 전체 UUID (128비트)
5. **시뮬레이터**: 블루투스 테스트 불가, 실기기 필요
