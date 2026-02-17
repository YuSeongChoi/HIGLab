# Wi-Fi Aware AI Reference

> Wi-Fi Aware 기반 기기 발견 가이드. 이 문서를 읽고 Wi-Fi Aware 코드를 생성할 수 있습니다.

## 개요

Wi-Fi Aware(NAN - Neighbor Awareness Networking)는 iOS 18+에서 지원하는 근거리 기기 발견 기술입니다.
인터넷이나 액세스 포인트 없이 Wi-Fi를 통해 주변 기기를 발견하고 직접 연결할 수 있습니다.

## 필수 Import

```swift
import DeviceDiscoveryUI
import Network
```

## 프로젝트 설정

```xml
<!-- Info.plist -->
<key>NSLocalNetworkUsageDescription</key>
<string>주변 기기를 찾기 위해 로컬 네트워크 접근이 필요합니다.</string>

<key>NSBonjourServices</key>
<array>
    <string>_myapp._tcp</string>
    <string>_myapp._udp</string>
</array>
```

### Capability 추가
- Wireless Accessory Configuration (필요 시)

## 핵심 구성요소

### 1. DeviceDiscoveryUI (SwiftUI)

```swift
import SwiftUI
import DeviceDiscoveryUI

struct DevicePickerView: View {
    @State private var selectedEndpoint: NWEndpoint?
    
    var body: some View {
        DevicePicker(
            browseDescriptor: .applicationService(name: "MyApp"),
            parameters: .applicationService
        ) { endpoint in
            // 기기 선택됨
            selectedEndpoint = endpoint
            connectToDevice(endpoint)
        } label: {
            Label("기기 찾기", systemImage: "antenna.radiowaves.left.and.right")
        } fallback: {
            // Wi-Fi Aware 미지원 시 대체 UI
            Text("이 기기에서는 Wi-Fi Aware를 사용할 수 없습니다")
        } parameters: {
            // 브라우즈 파라미터 커스터마이징
            $0.includePeerToPeer = true
        }
    }
    
    func connectToDevice(_ endpoint: NWEndpoint) {
        let connection = NWConnection(to: endpoint, using: .applicationService)
        connection.start(queue: .main)
    }
}
```

### 2. NWBrowser (기기 탐색)

```swift
import Network

class WiFiAwareManager {
    private var browser: NWBrowser?
    private var listener: NWListener?
    
    func startBrowsing() {
        let descriptor = NWBrowser.Descriptor.applicationService(name: "MyApp")
        let params = NWParameters.applicationService
        
        browser = NWBrowser(for: descriptor, using: params)
        
        browser?.browseResultsChangedHandler = { results, changes in
            for result in results {
                switch result.endpoint {
                case .service(let name, let type, let domain, _):
                    print("발견: \(name).\(type).\(domain)")
                default:
                    break
                }
            }
        }
        
        browser?.stateUpdateHandler = { state in
            print("브라우저 상태: \(state)")
        }
        
        browser?.start(queue: .main)
    }
}
```

### 3. NWListener (서비스 광고)

```swift
func startAdvertising() throws {
    let params = NWParameters.applicationService
    
    listener = try NWListener(using: params)
    listener?.service = NWListener.Service(
        name: "MyDevice",
        type: "_myapp._tcp"
    )
    
    listener?.newConnectionHandler = { connection in
        self.handleConnection(connection)
    }
    
    listener?.stateUpdateHandler = { state in
        print("리스너 상태: \(state)")
    }
    
    listener?.start(queue: .main)
}
```

## 전체 작동 예제

```swift
import SwiftUI
import DeviceDiscoveryUI
import Network

// MARK: - Wi-Fi Aware Manager
@Observable
class WiFiAwareManager {
    var discoveredDevices: [DiscoveredDevice] = []
    var isAdvertising = false
    var isBrowsing = false
    var connectedDevice: DiscoveredDevice?
    var receivedMessages: [String] = []
    
    private var browser: NWBrowser?
    private var listener: NWListener?
    private var connection: NWConnection?
    private let serviceName = "WiFiAwareDemo"
    private let queue = DispatchQueue(label: "wifi.aware")
    
    // MARK: - 광고 시작
    func startAdvertising() {
        do {
            let params = NWParameters.applicationService
            
            listener = try NWListener(using: params)
            listener?.service = NWListener.Service(
                name: UIDevice.current.name,
                type: "_\(serviceName)._tcp"
            )
            
            listener?.stateUpdateHandler = { [weak self] state in
                DispatchQueue.main.async {
                    self?.isAdvertising = state == .ready
                }
            }
            
            listener?.newConnectionHandler = { [weak self] connection in
                self?.handleIncomingConnection(connection)
            }
            
            listener?.start(queue: queue)
        } catch {
            print("광고 시작 실패: \(error)")
        }
    }
    
    func stopAdvertising() {
        listener?.cancel()
        listener = nil
        isAdvertising = false
    }
    
    // MARK: - 탐색 시작
    func startBrowsing() {
        let descriptor = NWBrowser.Descriptor.applicationService(name: serviceName)
        let params = NWParameters.applicationService
        
        browser = NWBrowser(for: descriptor, using: params)
        
        browser?.stateUpdateHandler = { [weak self] state in
            DispatchQueue.main.async {
                self?.isBrowsing = state == .ready
            }
        }
        
        browser?.browseResultsChangedHandler = { [weak self] results, changes in
            DispatchQueue.main.async {
                self?.discoveredDevices = results.compactMap { result in
                    if case .service(let name, _, _, _) = result.endpoint {
                        return DiscoveredDevice(name: name, endpoint: result.endpoint)
                    }
                    return nil
                }
            }
        }
        
        browser?.start(queue: queue)
    }
    
    func stopBrowsing() {
        browser?.cancel()
        browser = nil
        isBrowsing = false
        discoveredDevices.removeAll()
    }
    
    // MARK: - 연결
    func connect(to device: DiscoveredDevice) {
        let params = NWParameters.applicationService
        connection = NWConnection(to: device.endpoint, using: params)
        
        connection?.stateUpdateHandler = { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                case .ready:
                    self?.connectedDevice = device
                    self?.startReceiving()
                case .failed, .cancelled:
                    self?.connectedDevice = nil
                default:
                    break
                }
            }
        }
        
        connection?.start(queue: queue)
    }
    
    func disconnect() {
        connection?.cancel()
        connection = nil
        connectedDevice = nil
    }
    
    // MARK: - 메시지 송수신
    func send(_ message: String) {
        guard let data = message.data(using: .utf8) else { return }
        
        connection?.send(content: data, completion: .contentProcessed { error in
            if let error = error {
                print("전송 실패: \(error)")
            }
        })
    }
    
    private func startReceiving() {
        connection?.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] content, _, isComplete, error in
            if let data = content, let message = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self?.receivedMessages.append(message)
                }
            }
            
            if !isComplete && error == nil {
                self?.startReceiving()
            }
        }
    }
    
    private func handleIncomingConnection(_ newConnection: NWConnection) {
        // 기존 연결이 있으면 새 연결 거부
        if connection != nil {
            newConnection.cancel()
            return
        }
        
        connection = newConnection
        
        connection?.stateUpdateHandler = { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                case .ready:
                    self?.connectedDevice = DiscoveredDevice(name: "수신 연결", endpoint: newConnection.endpoint!)
                    self?.startReceiving()
                case .failed, .cancelled:
                    self?.connectedDevice = nil
                default:
                    break
                }
            }
        }
        
        connection?.start(queue: queue)
    }
}

// MARK: - Discovered Device
struct DiscoveredDevice: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let endpoint: NWEndpoint
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: DiscoveredDevice, rhs: DiscoveredDevice) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Main View
struct WiFiAwareView: View {
    @State private var manager = WiFiAwareManager()
    @State private var messageToSend = ""
    
    var body: some View {
        NavigationStack {
            List {
                // 상태 섹션
                Section("상태") {
                    Toggle("광고", isOn: Binding(
                        get: { manager.isAdvertising },
                        set: { $0 ? manager.startAdvertising() : manager.stopAdvertising() }
                    ))
                    
                    Toggle("탐색", isOn: Binding(
                        get: { manager.isBrowsing },
                        set: { $0 ? manager.startBrowsing() : manager.stopBrowsing() }
                    ))
                }
                
                // 발견된 기기
                if manager.isBrowsing {
                    Section("발견된 기기") {
                        if manager.discoveredDevices.isEmpty {
                            Text("검색 중...")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(manager.discoveredDevices) { device in
                                Button {
                                    manager.connect(to: device)
                                } label: {
                                    HStack {
                                        Image(systemName: "iphone")
                                        Text(device.name)
                                        Spacer()
                                        if manager.connectedDevice == device {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(.green)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // DevicePicker UI
                Section("시스템 UI") {
                    DevicePicker(
                        browseDescriptor: .applicationService(name: "WiFiAwareDemo"),
                        parameters: .applicationService
                    ) { endpoint in
                        print("선택됨: \(endpoint)")
                    } label: {
                        Label("기기 선택", systemImage: "antenna.radiowaves.left.and.right")
                    } fallback: {
                        Text("Wi-Fi Aware 미지원")
                            .foregroundStyle(.secondary)
                    }
                }
                
                // 연결된 기기와 메시징
                if let device = manager.connectedDevice {
                    Section("연결됨: \(device.name)") {
                        HStack {
                            TextField("메시지", text: $messageToSend)
                            Button("전송") {
                                manager.send(messageToSend)
                                messageToSend = ""
                            }
                            .disabled(messageToSend.isEmpty)
                        }
                        
                        Button("연결 해제", role: .destructive) {
                            manager.disconnect()
                        }
                    }
                }
                
                // 수신 메시지
                if !manager.receivedMessages.isEmpty {
                    Section("수신 메시지") {
                        ForEach(manager.receivedMessages.indices, id: \.self) { index in
                            Text(manager.receivedMessages[index])
                                .font(.system(.body, design: .monospaced))
                        }
                    }
                }
            }
            .navigationTitle("Wi-Fi Aware")
        }
    }
}

#Preview {
    WiFiAwareView()
}
```

## 고급 패턴

### 1. 커스텀 DevicePicker 스타일

```swift
DevicePicker(
    browseDescriptor: .applicationService(name: "MyApp"),
    parameters: .applicationService
) { endpoint in
    handleSelection(endpoint)
} label: {
    // 커스텀 레이블
    HStack {
        Image(systemName: "wifi")
        Text("주변 기기 연결")
    }
    .padding()
    .background(.blue)
    .foregroundStyle(.white)
    .clipShape(RoundedRectangle(cornerRadius: 12))
} fallback: {
    // 대체 UI
    Button("Bluetooth로 연결") {
        // MultipeerConnectivity 또는 CoreBluetooth 사용
    }
} parameters: { params in
    // 파라미터 커스터마이징
    params.includePeerToPeer = true
    params.requiredInterfaceType = .wifi
}
```

### 2. TXT 레코드로 추가 정보 전달

```swift
// 서비스 광고 시 메타데이터 추가
func advertiseWithMetadata() throws {
    let params = NWParameters.applicationService
    
    listener = try NWListener(using: params)
    
    // TXT 레코드 설정
    let txtRecord = NWTXTRecord()
    txtRecord["version"] = "1.0"
    txtRecord["capabilities"] = "video,audio"
    
    listener?.service = NWListener.Service(
        name: "MyDevice",
        type: "_myapp._tcp",
        txtRecord: txtRecord
    )
    
    listener?.start(queue: .main)
}

// 브라우징 시 메타데이터 읽기
browser?.browseResultsChangedHandler = { results, _ in
    for result in results {
        if case .service(_, _, _, let interface) = result.endpoint {
            // TXT 레코드 접근은 연결 후 가능
        }
    }
}
```

### 3. 파일 전송

```swift
func sendFile(url: URL, over connection: NWConnection) {
    guard let data = try? Data(contentsOf: url) else { return }
    
    // 파일 크기 먼저 전송
    var size = UInt64(data.count)
    let sizeData = Data(bytes: &size, count: 8)
    
    connection.send(content: sizeData, completion: .contentProcessed { _ in
        // 파일 데이터 전송
        connection.send(content: data, completion: .contentProcessed { error in
            if let error = error {
                print("파일 전송 실패: \(error)")
            }
        })
    })
}

func receiveFile(from connection: NWConnection) {
    // 파일 크기 수신
    connection.receive(minimumIncompleteLength: 8, maximumLength: 8) { content, _, _, _ in
        guard let sizeData = content else { return }
        let size = sizeData.withUnsafeBytes { $0.load(as: UInt64.self) }
        
        // 파일 데이터 수신
        connection.receive(minimumIncompleteLength: Int(size), maximumLength: Int(size)) { content, _, _, _ in
            if let data = content {
                // 파일 저장
                self.saveFile(data)
            }
        }
    }
}
```

## 주의사항

1. **iOS 버전**
   - Wi-Fi Aware: iOS 18+
   - DeviceDiscoveryUI: iOS 16+

2. **기기 지원**
   - 모든 기기가 Wi-Fi Aware 지원하지 않음
   - `fallback` 뷰 필수 제공

3. **전력 소비**
   - Wi-Fi Aware는 배터리 소모 큼
   - 필요 시에만 활성화

4. **거리 제한**
   - 일반적으로 수십 미터 범위
   - 환경에 따라 다름

5. **시뮬레이터**
   - Wi-Fi Aware 미지원
   - 실기기 테스트 필수
