# MultipeerConnectivity AI Reference

> P2P communication app implementation guide. Read this document to generate MultipeerConnectivity code.

## Overview

MultipeerConnectivity provides direct communication between nearby devices via Wi-Fi, Bluetooth, and P2P Wi-Fi.
Messages, files, and stream data can be exchanged without an internet connection.

## Required Import

```swift
import MultipeerConnectivity
```

## Project Setup

```xml
<!-- Info.plist -->
<!-- For Bluetooth usage -->
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Bluetooth is required to connect with nearby devices.</string>

<!-- For local network usage -->
<key>NSLocalNetworkUsageDescription</key>
<string>Local network access is required to find nearby devices.</string>

<!-- Bonjour services -->
<key>NSBonjourServices</key>
<array>
    <string>_myapp._tcp</string>
    <string>_myapp._udp</string>
</array>
```

## Core Components

### 1. MCPeerID (Device Identification)

```swift
// Current device ID
let peerID = MCPeerID(displayName: UIDevice.current.name)

// Custom name
let peerID = MCPeerID(displayName: "Player1")
```

### 2. MCSession (Session Management)

```swift
let session = MCSession(
    peer: myPeerID,
    securityIdentity: nil,
    encryptionPreference: .required
)
session.delegate = self
```

### 3. MCNearbyServiceAdvertiser (Advertising)

```swift
// Advertise my device
let advertiser = MCNearbyServiceAdvertiser(
    peer: myPeerID,
    discoveryInfo: ["role": "host"],  // Additional info
    serviceType: "my-app"  // 1-15 chars, lowercase/numbers/hyphens
)
advertiser.delegate = self
advertiser.startAdvertisingPeer()
```

### 4. MCNearbyServiceBrowser (Browsing)

```swift
// Browse for nearby devices
let browser = MCNearbyServiceBrowser(
    peer: myPeerID,
    serviceType: "my-app"
)
browser.delegate = self
browser.startBrowsingForPeers()
```

## Complete Working Example

```swift
import SwiftUI
import MultipeerConnectivity

// MARK: - Multipeer Manager
@Observable
class MultipeerManager: NSObject {
    var connectedPeers: [MCPeerID] = []
    var availablePeers: [MCPeerID] = []
    var receivedMessages: [ChatMessage] = []
    var isAdvertising = false
    var isBrowsing = false
    
    private let serviceType = "chat-app"
    private let myPeerID: MCPeerID
    private var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser!
    private var browser: MCNearbyServiceBrowser!
    
    override init() {
        myPeerID = MCPeerID(displayName: UIDevice.current.name)
        super.init()
        
        session = MCSession(
            peer: myPeerID,
            securityIdentity: nil,
            encryptionPreference: .required
        )
        session.delegate = self
        
        advertiser = MCNearbyServiceAdvertiser(
            peer: myPeerID,
            discoveryInfo: nil,
            serviceType: serviceType
        )
        advertiser.delegate = self
        
        browser = MCNearbyServiceBrowser(
            peer: myPeerID,
            serviceType: serviceType
        )
        browser.delegate = self
    }
    
    // MARK: - Start/Stop Advertising
    func startAdvertising() {
        advertiser.startAdvertisingPeer()
        isAdvertising = true
    }
    
    func stopAdvertising() {
        advertiser.stopAdvertisingPeer()
        isAdvertising = false
    }
    
    // MARK: - Start/Stop Browsing
    func startBrowsing() {
        browser.startBrowsingForPeers()
        isBrowsing = true
    }
    
    func stopBrowsing() {
        browser.stopBrowsingForPeers()
        isBrowsing = false
    }
    
    // MARK: - Connection Request
    func invitePeer(_ peer: MCPeerID) {
        browser.invitePeer(
            peer,
            to: session,
            withContext: nil,
            timeout: 30
        )
    }
    
    // MARK: - Send Message
    func send(_ message: String) {
        guard !session.connectedPeers.isEmpty else { return }
        
        let chatMessage = ChatMessage(
            sender: myPeerID.displayName,
            content: message,
            timestamp: Date()
        )
        
        if let data = try? JSONEncoder().encode(chatMessage) {
            try? session.send(data, toPeers: session.connectedPeers, with: .reliable)
            receivedMessages.append(chatMessage)
        }
    }
    
    // MARK: - Send File
    func sendFile(url: URL, to peer: MCPeerID) {
        session.sendResource(
            at: url,
            withName: url.lastPathComponent,
            toPeer: peer
        ) { error in
            if let error = error {
                print("File transfer failed: \(error)")
            }
        }
    }
    
    // MARK: - Disconnect
    func disconnect() {
        session.disconnect()
    }
}

// MARK: - MCSessionDelegate
extension MultipeerManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                if !self.connectedPeers.contains(peerID) {
                    self.connectedPeers.append(peerID)
                }
                self.availablePeers.removeAll { $0 == peerID }
            case .notConnected:
                self.connectedPeers.removeAll { $0 == peerID }
            case .connecting:
                print("\(peerID.displayName) connecting...")
            @unknown default:
                break
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let message = try? JSONDecoder().decode(ChatMessage.self, from: data) {
            DispatchQueue.main.async {
                self.receivedMessages.append(message)
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // Handle stream reception
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("Started receiving file: \(resourceName)")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        if let url = localURL {
            print("Finished receiving file: \(url)")
        }
    }
}

// MARK: - MCNearbyServiceAdvertiserDelegate
extension MultipeerManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // Auto accept (or confirm via UI)
        invitationHandler(true, session)
    }
}

// MARK: - MCNearbyServiceBrowserDelegate
extension MultipeerManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        DispatchQueue.main.async {
            if !self.availablePeers.contains(peerID) && !self.connectedPeers.contains(peerID) {
                self.availablePeers.append(peerID)
            }
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.availablePeers.removeAll { $0 == peerID }
        }
    }
}

// MARK: - Chat Message Model
struct ChatMessage: Codable, Identifiable {
    let id = UUID()
    let sender: String
    let content: String
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case sender, content, timestamp
    }
}

// MARK: - Main View
struct MultipeerChatView: View {
    @State private var manager = MultipeerManager()
    @State private var messageText = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Connected peers
                if !manager.connectedPeers.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(manager.connectedPeers, id: \.displayName) { peer in
                                Label(peer.displayName, systemImage: "person.fill")
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(.green.opacity(0.2))
                                    .clipShape(Capsule())
                            }
                        }
                        .padding()
                    }
                    .background(.bar)
                }
                
                // Message list
                List(manager.receivedMessages) { message in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(message.sender)
                                .font(.caption.bold())
                            Spacer()
                            Text(message.timestamp, style: .time)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        Text(message.content)
                    }
                }
                .listStyle(.plain)
                
                // Message input
                HStack {
                    TextField("Message", text: $messageText)
                        .textFieldStyle(.roundedBorder)
                    
                    Button {
                        manager.send(messageText)
                        messageText = ""
                    } label: {
                        Image(systemName: "paperplane.fill")
                    }
                    .disabled(messageText.isEmpty || manager.connectedPeers.isEmpty)
                }
                .padding()
                .background(.bar)
            }
            .navigationTitle("P2P Chat")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Toggle("Advertise", isOn: Binding(
                            get: { manager.isAdvertising },
                            set: { $0 ? manager.startAdvertising() : manager.stopAdvertising() }
                        ))
                        Toggle("Browse", isOn: Binding(
                            get: { manager.isBrowsing },
                            set: { $0 ? manager.startBrowsing() : manager.stopBrowsing() }
                        ))
                    } label: {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Section("Discovered Devices") {
                            ForEach(manager.availablePeers, id: \.displayName) { peer in
                                Button(peer.displayName) {
                                    manager.invitePeer(peer)
                                }
                            }
                            if manager.availablePeers.isEmpty {
                                Text("None")
                            }
                        }
                    } label: {
                        Image(systemName: "person.2")
                    }
                }
            }
            .onAppear {
                manager.startAdvertising()
                manager.startBrowsing()
            }
            .onDisappear {
                manager.stopAdvertising()
                manager.stopBrowsing()
                manager.disconnect()
            }
        }
    }
}

#Preview {
    MultipeerChatView()
}
```

## Advanced Patterns

### 1. Stream Data Transfer

```swift
// Start stream
func startStream(to peer: MCPeerID) throws -> OutputStream {
    try session.startStream(withName: "video", toPeer: peer)
}

// Receive stream
func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    stream.delegate = self
    stream.schedule(in: .main, forMode: .default)
    stream.open()
}

// StreamDelegate
extension MultipeerManager: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case .hasBytesAvailable:
            if let inputStream = aStream as? InputStream {
                var buffer = [UInt8](repeating: 0, count: 1024)
                let bytesRead = inputStream.read(&buffer, maxLength: buffer.count)
                if bytesRead > 0 {
                    let data = Data(bytes: buffer, count: bytesRead)
                    // Process data
                }
            }
        case .endEncountered:
            aStream.close()
        default:
            break
        }
    }
}
```

### 2. Invitation UI (MCBrowserViewController)

```swift
import UIKit
import MultipeerConnectivity

class PeerBrowserVC: UIViewController {
    var session: MCSession!
    var peerID: MCPeerID!
    
    func showBrowser() {
        let browserVC = MCBrowserViewController(
            serviceType: "my-app",
            session: session
        )
        browserVC.delegate = self
        browserVC.minimumNumberOfPeers = 1
        browserVC.maximumNumberOfPeers = 4
        
        present(browserVC, animated: true)
    }
}

extension PeerBrowserVC: MCBrowserViewControllerDelegate {
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
}
```

### 3. Secure Connection

```swift
// Certificate-based security
func setupSecureSession() -> MCSession {
    // Load certificate
    guard let certificateURL = Bundle.main.url(forResource: "cert", withExtension: "p12"),
          let certificateData = try? Data(contentsOf: certificateURL) else {
        fatalError("Certificate not found")
    }
    
    var items: CFArray?
    let options = [kSecImportExportPassphrase: "password"]
    SecPKCS12Import(certificateData as CFData, options as CFDictionary, &items)
    
    let identityDict = (items as! [[String: Any]])[0]
    let identity = identityDict[kSecImportItemIdentity as String] as! SecIdentity
    
    return MCSession(
        peer: myPeerID,
        securityIdentity: [identity],
        encryptionPreference: .required
    )
}

// Certificate verification
func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
    // Certificate verification logic
    certificateHandler(true)  // Or false to reject
}
```

## Important Notes

1. **Service Type Rules**
   ```swift
   // 1-15 chars, lowercase/numbers/hyphens only
   // First char must be a letter
   let serviceType = "my-game"  // ✅
   let serviceType = "MyGame"   // ❌ Uppercase
   let serviceType = "1game"    // ❌ Starts with number
   ```

2. **Background Limitations**
   - Connection drops when app goes to background
   - Can extend partially with Background Modes

3. **Battery Consumption**
   - Advertising/browsing consumes significant battery
   - Only enable when needed

4. **Peer Limit**
   - Maximum 8 peer connections recommended
   - Performance degrades beyond that

5. **Info.plist Required**
   - Must register service type in NSBonjourServices
   - Format: `_servicetype._tcp`
