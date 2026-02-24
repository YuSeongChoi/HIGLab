# AccessorySetupKit AI Reference

> Accessory connection and setup guide. Read this document to generate AccessorySetupKit code.

## Overview

AccessorySetupKit is a Bluetooth/Wi-Fi accessory pairing framework available on iOS 18+.
It provides a user-friendly accessory discovery, pairing, and setup experience through system UI.
It supports easier and more secure connections compared to traditional CoreBluetooth.

## Required Import

```swift
import AccessorySetupKit
```

## Project Setup

### 1. Info.plist

```xml
<!-- Bluetooth Permission -->
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Bluetooth is required to connect accessories.</string>

<!-- Local Network (Wi-Fi Accessories) -->
<key>NSLocalNetworkUsageDescription</key>
<string>Local network access is required to find Wi-Fi accessories.</string>

<!-- Bonjour Services -->
<key>NSBonjourServices</key>
<array>
    <string>_myaccessory._tcp</string>
</array>
```

### 2. Capability
- Wireless Accessory Configuration (if needed)

## Core Components

### 1. ASAccessorySession (Session)

```swift
import AccessorySetupKit

// Create session
let session = ASAccessorySession()

// Event handler
session.eventHandler = { event in
    switch event {
    case .accessoryAdded(let accessory):
        print("Accessory added: \(accessory.displayName)")
    case .accessoryRemoved(let accessory):
        print("Accessory removed: \(accessory.displayName)")
    case .accessoryChanged(let accessory):
        print("Accessory changed: \(accessory.displayName)")
    case .activated:
        print("Session activated")
    case .invalidated(let error):
        print("Session invalidated: \(error?.localizedDescription ?? "")")
    @unknown default:
        break
    }
}

// Activate session
session.activate(on: DispatchQueue.main)
```

### 2. ASPickerDisplayItem (Picker Item)

```swift
// Bluetooth accessory
let bluetoothItem = ASPickerDisplayItem(
    name: "My Smart Device",
    productImage: UIImage(named: "device-icon")!,
    descriptor: ASDiscoveryDescriptor(bluetoothServiceUUID: CBUUID(string: "180A"))
)

// Wi-Fi accessory
let wifiItem = ASPickerDisplayItem(
    name: "Smart Home Hub",
    productImage: UIImage(named: "hub-icon")!,
    descriptor: ASDiscoveryDescriptor(
        ssid: ASDiscoveryDescriptor.ssidPrefix("SmartHub-"),
        supportedOptions: .ssidPrefix
    )
)
```

### 3. ASAccessory (Connected Accessory)

```swift
// Connected accessory information
let accessory: ASAccessory

accessory.displayName          // Display name
accessory.state               // Connection state
accessory.bluetoothIdentifier // Bluetooth UUID
accessory.ssid                // Wi-Fi SSID
```

## Complete Working Example

```swift
import SwiftUI
import AccessorySetupKit
import CoreBluetooth

// MARK: - Accessory Manager
@Observable
class AccessoryManager {
    var accessories: [ASAccessory] = []
    var isSessionActive = false
    var isShowingPicker = false
    var errorMessage: String?
    
    private var session: ASAccessorySession?
    
    var isSupported: Bool {
        ASAccessorySession.isSupported
    }
    
    func activateSession() {
        session = ASAccessorySession()
        
        session?.eventHandler = { [weak self] event in
            DispatchQueue.main.async {
                self?.handleEvent(event)
            }
        }
        
        session?.activate(on: .main)
    }
    
    private func handleEvent(_ event: ASAccessoryEvent) {
        switch event {
        case .activated:
            isSessionActive = true
            // Load already paired accessories
            loadPairedAccessories()
            
        case .invalidated(let error):
            isSessionActive = false
            if let error = error {
                errorMessage = error.localizedDescription
            }
            
        case .accessoryAdded(let accessory):
            if !accessories.contains(where: { $0.bluetoothIdentifier == accessory.bluetoothIdentifier }) {
                accessories.append(accessory)
            }
            
        case .accessoryRemoved(let accessory):
            accessories.removeAll { $0.bluetoothIdentifier == accessory.bluetoothIdentifier }
            
        case .accessoryChanged(let accessory):
            if let index = accessories.firstIndex(where: { $0.bluetoothIdentifier == accessory.bluetoothIdentifier }) {
                accessories[index] = accessory
            }
            
        @unknown default:
            break
        }
    }
    
    private func loadPairedAccessories() {
        // Restore previously paired accessories
        accessories = session?.accessories ?? []
    }
    
    // MARK: - Search and Add Accessories
    func showAccessoryPicker() {
        guard let session = session else { return }
        
        // Define accessories to search for
        let items = [
            // Bluetooth device
            ASPickerDisplayItem(
                name: "Smart Sensor",
                productImage: UIImage(systemName: "sensor.fill")!,
                descriptor: ASDiscoveryDescriptor(
                    bluetoothServiceUUID: CBUUID(string: "180A")
                )
            ),
            // Custom Bluetooth service
            ASPickerDisplayItem(
                name: "Fitness Band",
                productImage: UIImage(systemName: "figure.run")!,
                descriptor: ASDiscoveryDescriptor(
                    bluetoothServiceUUID: CBUUID(string: "180D"),  // Heart Rate
                    bluetoothCompanyIdentifier: ASDiscoveryDescriptor.bluetoothCompanyIdentifierApple
                )
            )
        ]
        
        // Show picker
        session.showPicker(for: items) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Picker error: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // MARK: - Remove Accessory
    func removeAccessory(_ accessory: ASAccessory) {
        session?.removeAccessory(accessory) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Remove failed: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // MARK: - Rename Accessory
    func renameAccessory(_ accessory: ASAccessory, to newName: String) {
        session?.renameAccessory(accessory, to: newName) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Rename failed: \(error.localizedDescription)"
                }
            }
        }
    }
    
    deinit {
        session?.invalidate()
    }
}

// MARK: - Main View
struct AccessorySetupView: View {
    @State private var manager = AccessoryManager()
    @State private var showingRenameSheet = false
    @State private var accessoryToRename: ASAccessory?
    @State private var newName = ""
    
    var body: some View {
        NavigationStack {
            Group {
                if !manager.isSupported {
                    ContentUnavailableView(
                        "Not Supported",
                        systemImage: "antenna.radiowaves.left.and.right.slash",
                        description: Text("AccessorySetupKit is not available on this device")
                    )
                } else if !manager.isSessionActive {
                    VStack(spacing: 20) {
                        ProgressView()
                        Text("Activating session...")
                    }
                } else if manager.accessories.isEmpty {
                    ContentUnavailableView(
                        "No Connected Accessories",
                        systemImage: "antenna.radiowaves.left.and.right",
                        description: Text("Add a new accessory")
                    )
                } else {
                    List {
                        ForEach(manager.accessories, id: \.displayName) { accessory in
                            AccessoryRow(accessory: accessory)
                                .contextMenu {
                                    Button {
                                        accessoryToRename = accessory
                                        newName = accessory.displayName
                                        showingRenameSheet = true
                                    } label: {
                                        Label("Rename", systemImage: "pencil")
                                    }
                                    
                                    Button(role: .destructive) {
                                        manager.removeAccessory(accessory)
                                    } label: {
                                        Label("Remove", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
            }
            .navigationTitle("Accessories")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        manager.showAccessoryPicker()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .disabled(!manager.isSessionActive)
                }
            }
            .alert("Error", isPresented: Binding(
                get: { manager.errorMessage != nil },
                set: { if !$0 { manager.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(manager.errorMessage ?? "")
            }
            .sheet(isPresented: $showingRenameSheet) {
                RenameSheet(
                    name: $newName,
                    onSave: {
                        if let accessory = accessoryToRename {
                            manager.renameAccessory(accessory, to: newName)
                        }
                        showingRenameSheet = false
                    },
                    onCancel: {
                        showingRenameSheet = false
                    }
                )
            }
            .task {
                manager.activateSession()
            }
        }
    }
}

// MARK: - Accessory Row
struct AccessoryRow: View {
    let accessory: ASAccessory
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: iconForAccessory)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 44, height: 44)
                .background(.blue.opacity(0.1), in: Circle())
            
            // Information
            VStack(alignment: .leading, spacing: 4) {
                Text(accessory.displayName)
                    .font(.headline)
                
                HStack {
                    Circle()
                        .fill(stateColor)
                        .frame(width: 8, height: 8)
                    Text(stateText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // Connection type indicator
            if accessory.bluetoothIdentifier != nil {
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    var iconForAccessory: String {
        // Icon based on accessory type
        if accessory.displayName.lowercased().contains("sensor") {
            return "sensor.fill"
        } else if accessory.displayName.lowercased().contains("band") {
            return "figure.run"
        } else {
            return "antenna.radiowaves.left.and.right"
        }
    }
    
    var stateColor: Color {
        switch accessory.state {
        case .connected: return .green
        case .connecting: return .orange
        case .disconnected: return .red
        @unknown default: return .gray
        }
    }
    
    var stateText: String {
        switch accessory.state {
        case .connected: return "Connected"
        case .connecting: return "Connecting..."
        case .disconnected: return "Disconnected"
        @unknown default: return "Unknown"
        }
    }
}

// MARK: - Rename Sheet
struct RenameSheet: View {
    @Binding var name: String
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Accessory Name", text: $name)
            }
            .navigationTitle("Rename")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: onSave)
                        .disabled(name.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    AccessorySetupView()
}
```

## Advanced Patterns

### 1. Accessory Migration (CoreBluetooth → AccessorySetupKit)

```swift
import CoreBluetooth
import AccessorySetupKit

class AccessoryMigrationManager {
    let session = ASAccessorySession()
    
    func migrateExistingAccessory(peripheral: CBPeripheral) {
        // Migrate existing CoreBluetooth pairing to AccessorySetupKit
        let migrationItem = ASMigrationDisplayItem(
            name: peripheral.name ?? "Unknown Device",
            productImage: UIImage(systemName: "antenna.radiowaves.left.and.right")!,
            descriptor: ASDiscoveryDescriptor(
                bluetoothServiceUUID: CBUUID(string: "180A")
            )
        )
        
        session.showPicker(for: [migrationItem]) { error in
            if let error = error {
                print("Migration failed: \(error)")
            }
        }
    }
}
```

### 2. Wi-Fi Accessory Setup

```swift
func setupWiFiAccessory() {
    let wifiItem = ASPickerDisplayItem(
        name: "Smart Home Hub",
        productImage: UIImage(named: "hub")!,
        descriptor: ASDiscoveryDescriptor(
            ssid: ASDiscoveryDescriptor.ssidPrefix("SmartHub-"),
            supportedOptions: .ssidPrefix
        )
    )
    
    // Wi-Fi credential setup (optional)
    wifiItem.setupAssistant = { accessory, completion in
        // Request Wi-Fi password from user
        // Or execute provisioning protocol
        completion(.success)
    }
    
    session.showPicker(for: [wifiItem]) { error in
        // Handle
    }
}
```

### 3. Matter Device Integration

```swift
import HomeKit
import AccessorySetupKit

class MatterSetupManager {
    let session = ASAccessorySession()
    let homeManager = HMHomeManager()
    
    func setupMatterDevice() {
        // Matter protocol supporting accessory
        let matterItem = ASPickerDisplayItem(
            name: "Matter Smart Light",
            productImage: UIImage(systemName: "lightbulb.fill")!,
            descriptor: ASDiscoveryDescriptor(
                bluetoothServiceUUID: CBUUID(string: "FFF6")  // Matter BLE Service
            )
        )
        
        session.showPicker(for: [matterItem]) { [weak self] error in
            if error == nil {
                // Add to HomeKit
                self?.addToHomeKit()
            }
        }
    }
    
    private func addToHomeKit() {
        // HomeKit integration logic
    }
}
```

### 4. Accessory Firmware Update

```swift
func checkForFirmwareUpdate(accessory: ASAccessory) async {
    // Check firmware version via CoreBluetooth
    guard let identifier = accessory.bluetoothIdentifier else { return }
    
    // Check firmware update availability
    let currentVersion = await fetchFirmwareVersion(identifier)
    let latestVersion = await fetchLatestVersion()
    
    if latestVersion > currentVersion {
        // Show firmware update UI
        await showFirmwareUpdateUI(accessory: accessory, version: latestVersion)
    }
}
```

## Important Notes

1. **iOS Version**
   - AccessorySetupKit: Requires iOS 18+
   - Use CoreBluetooth for earlier versions

2. **Privacy Strings**
   - Bluetooth and local network permission descriptions are required
   - App will be rejected if missing

3. **System UI**
   - Picker uses system-provided UI
   - Limited customization

4. **Background Limitations**
   - Picker only works in foreground
   - Communication with connected accessories works in background

5. **Simulator**
   - Bluetooth features not supported
   - Real device testing required
