# Wi-Fi Aware AI Reference

> Wi-Fi Aware based device discovery guide. Read this document to generate Wi-Fi Aware code.

## Overview

Wi-Fi Aware (NAN - Neighbor Awareness Networking) is a proximity device discovery technology supported in iOS 18+.
You can discover nearby devices and connect directly through Wi-Fi without internet or access points.

## Required Import

```swift
import DeviceDiscoveryUI
import Network
```

## Project Setup

```xml
<!-- Info.plist -->
<key>NSLocalNetworkUsageDescription</key>
<string>Local network access is required to find nearby devices.</string>

<key>NSBonjourServices</key>
<array>
    <string>_myapp._tcp</string>
    <string>_myapp._udp</string>
</array>
```

### Add Capability
- Wireless Accessory Configuration (if needed)

## Core Components

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
            // Device selected
            selectedEndpoint = endpoint
            connectToDevice(endpoint)
        } label: {
            Label("Find Device", systemImage: "antenna.radiowaves.left.and.right")
        } fallback: {
            // Fallback UI when Wi-Fi Aware not supported
            Text("Wi-Fi Aware is not available on this device")
        } parameters: {
            // Customize browse parameters
            $0.includePeerToPeer = true
        }
    }
    
    func connectToDevice(_ endpoint: NWEndpoint) {
        let connection = NWConnection(to: endpoint, using: .applicationService)
        connection.start(queue: .main)
    }
}
```

### 2. NWBrowser (Device Discovery)

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
                    print("Discovered: \(name).\(type).\(domain)")
                default:
                    break
                }
            }
        }
        
        browser?.stateUpdateHandler = { state in
            print("Browser state: \(state)")
        }
        
        browser?.start(queue: .main)
    }
}
```

### 3. NWListener (Service Advertising)

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
        print("Listener state: \(state)")
    }
    
    listener?.start(queue: .main)
}
```

## Complete Working Example

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
    
    // MARK: - Start Advertising
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
            print("Failed to start advertising: \(error)")
        }
    }
    
    func stopAdvertising() {
        listener?.cancel()
        listener = nil
        isAdvertising = false
    }
    
    // MARK: - Start Browsing
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
    
    // MARK: - Connect
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
    
    // MARK: - Send/Receive Messages
    func send(_ message: String) {
        guard let data = message.data(using: .utf8) else { return }
        
        connection?.send(content: data, completion: .contentProcessed { error in
            if let error = error {
                print("Send failed: \(error)")
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
        // Reject new connection if already connected
        if connection != nil {
            newConnection.cancel()
            return
        }
        
        connection = newConnection
        
        connection?.stateUpdateHandler = { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                case .ready:
                    self?.connectedDevice = DiscoveredDevice(name: "Incoming Connection", endpoint: newConnection.endpoint!)
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
                // Status section
                Section("Status") {
                    Toggle("Advertising", isOn: Binding(
                        get: { manager.isAdvertising },
                        set: { $0 ? manager.startAdvertising() : manager.stopAdvertising() }
                    ))
                    
                    Toggle("Browsing", isOn: Binding(
                        get: { manager.isBrowsing },
                        set: { $0 ? manager.startBrowsing() : manager.stopBrowsing() }
                    ))
                }
                
                // Discovered devices
                if manager.isBrowsing {
                    Section("Discovered Devices") {
                        if manager.discoveredDevices.isEmpty {
                            Text("Searching...")
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
                Section("System UI") {
                    DevicePicker(
                        browseDescriptor: .applicationService(name: "WiFiAwareDemo"),
                        parameters: .applicationService
                    ) { endpoint in
                        print("Selected: \(endpoint)")
                    } label: {
                        Label("Select Device", systemImage: "antenna.radiowaves.left.and.right")
                    } fallback: {
                        Text("Wi-Fi Aware not supported")
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Connected device and messaging
                if let device = manager.connectedDevice {
                    Section("Connected: \(device.name)") {
                        HStack {
                            TextField("Message", text: $messageToSend)
                            Button("Send") {
                                manager.send(messageToSend)
                                messageToSend = ""
                            }
                            .disabled(messageToSend.isEmpty)
                        }
                        
                        Button("Disconnect", role: .destructive) {
                            manager.disconnect()
                        }
                    }
                }
                
                // Received messages
                if !manager.receivedMessages.isEmpty {
                    Section("Received Messages") {
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

## Advanced Patterns

### 1. Custom DevicePicker Style

```swift
DevicePicker(
    browseDescriptor: .applicationService(name: "MyApp"),
    parameters: .applicationService
) { endpoint in
    handleSelection(endpoint)
} label: {
    // Custom label
    HStack {
        Image(systemName: "wifi")
        Text("Connect Nearby Device")
    }
    .padding()
    .background(.blue)
    .foregroundStyle(.white)
    .clipShape(RoundedRectangle(cornerRadius: 12))
} fallback: {
    // Fallback UI
    Button("Connect via Bluetooth") {
        // Use MultipeerConnectivity or CoreBluetooth
    }
} parameters: { params in
    // Customize parameters
    params.includePeerToPeer = true
    params.requiredInterfaceType = .wifi
}
```

### 2. Pass Additional Info with TXT Record

```swift
// Add metadata when advertising service
func advertiseWithMetadata() throws {
    let params = NWParameters.applicationService
    
    listener = try NWListener(using: params)
    
    // Set TXT record
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

// Read metadata when browsing
browser?.browseResultsChangedHandler = { results, _ in
    for result in results {
        if case .service(_, _, _, let interface) = result.endpoint {
            // TXT record accessible after connection
        }
    }
}
```

### 3. File Transfer

```swift
func sendFile(url: URL, over connection: NWConnection) {
    guard let data = try? Data(contentsOf: url) else { return }
    
    // Send file size first
    var size = UInt64(data.count)
    let sizeData = Data(bytes: &size, count: 8)
    
    connection.send(content: sizeData, completion: .contentProcessed { _ in
        // Send file data
        connection.send(content: data, completion: .contentProcessed { error in
            if let error = error {
                print("File transfer failed: \(error)")
            }
        })
    })
}

func receiveFile(from connection: NWConnection) {
    // Receive file size
    connection.receive(minimumIncompleteLength: 8, maximumLength: 8) { content, _, _, _ in
        guard let sizeData = content else { return }
        let size = sizeData.withUnsafeBytes { $0.load(as: UInt64.self) }
        
        // Receive file data
        connection.receive(minimumIncompleteLength: Int(size), maximumLength: Int(size)) { content, _, _, _ in
            if let data = content {
                // Save file
                self.saveFile(data)
            }
        }
    }
}
```

## Important Notes

1. **iOS Version**
   - Wi-Fi Aware: iOS 18+
   - DeviceDiscoveryUI: iOS 16+

2. **Device Support**
   - Not all devices support Wi-Fi Aware
   - `fallback` view is required

3. **Power Consumption**
   - Wi-Fi Aware has high battery consumption
   - Only activate when needed

4. **Range Limitations**
   - Typically within tens of meters
   - Varies by environment

5. **Simulator**
   - Wi-Fi Aware not supported
   - Real device testing required
