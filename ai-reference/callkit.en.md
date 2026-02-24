# CallKit AI Reference

> VoIP calling app implementation guide. Read this document to generate CallKit code.

## Overview

CallKit is a framework that allows VoIP apps to integrate with the system calling UI.
It provides the same experience as the native Phone app, including incoming/outgoing call screens, contact blocking, and caller identification.

## Required Imports

```swift
import CallKit
import AVFoundation  // Audio session
import PushKit       // VoIP push
```

## Project Setup

### 1. Add Capabilities
- Background Modes > Voice over IP
- Background Modes > Remote notifications
- Push Notifications

### 2. Info.plist

```xml
<!-- Microphone Permission -->
<key>NSMicrophoneUsageDescription</key>
<string>Microphone access is required for calls.</string>
```

## Core Components

### 1. CXProvider (Call Events)

```swift
import CallKit

class CallManager: NSObject {
    let provider: CXProvider
    let callController = CXCallController()
    
    override init() {
        let config = CXProviderConfiguration()
        config.localizedName = "My VoIP App"
        config.supportsVideo = true
        config.maximumCallsPerCallGroup = 1
        config.supportedHandleTypes = [.phoneNumber, .generic]
        config.iconTemplateImageData = UIImage(named: "CallIcon")?.pngData()
        config.ringtoneSound = "ringtone.wav"
        
        provider = CXProvider(configuration: config)
        super.init()
        provider.setDelegate(self, queue: nil)
    }
}
```

### 2. CXCallController (Call Control)

```swift
// Start outgoing call
func startCall(handle: String, video: Bool = false) {
    let uuid = UUID()
    let handle = CXHandle(type: .phoneNumber, value: handle)
    let startCallAction = CXStartCallAction(call: uuid, handle: handle)
    startCallAction.isVideo = video
    
    let transaction = CXTransaction(action: startCallAction)
    callController.request(transaction) { error in
        if let error = error {
            print("Outgoing call failed: \(error)")
        }
    }
}

// End call
func endCall(uuid: UUID) {
    let endCallAction = CXEndCallAction(call: uuid)
    let transaction = CXTransaction(action: endCallAction)
    callController.request(transaction) { error in
        if let error = error {
            print("End call failed: \(error)")
        }
    }
}
```

### 3. Report Incoming Call

```swift
// Report incoming call to system
func reportIncomingCall(uuid: UUID, handle: String, hasVideo: Bool, completion: @escaping (Error?) -> Void) {
    let update = CXCallUpdate()
    update.remoteHandle = CXHandle(type: .phoneNumber, value: handle)
    update.hasVideo = hasVideo
    update.localizedCallerName = "Caller Name"
    
    provider.reportNewIncomingCall(with: uuid, update: update) { error in
        completion(error)
    }
}
```

## Complete Working Example

```swift
import SwiftUI
import CallKit
import AVFoundation
import PushKit

// MARK: - Call Model
struct Call: Identifiable {
    let id: UUID
    let handle: String
    let isOutgoing: Bool
    var isOnHold: Bool = false
    var isMuted: Bool = false
    var startTime: Date?
}

// MARK: - Call Manager
@Observable
class CallManager: NSObject {
    var activeCalls: [Call] = []
    var callState: String = "Idle"
    
    private let provider: CXProvider
    private let callController = CXCallController()
    private var audioSession: AVAudioSession { AVAudioSession.sharedInstance() }
    
    override init() {
        let config = CXProviderConfiguration()
        config.localizedName = "VoIP Demo"
        config.supportsVideo = true
        config.maximumCallsPerCallGroup = 1
        config.maximumCallGroups = 1
        config.supportedHandleTypes = [.phoneNumber, .generic]
        config.includesCallsInRecents = true
        
        provider = CXProvider(configuration: config)
        super.init()
        provider.setDelegate(self, queue: nil)
    }
    
    // MARK: - Outgoing Call
    func startOutgoingCall(to handle: String, hasVideo: Bool = false) {
        let uuid = UUID()
        let cxHandle = CXHandle(type: .phoneNumber, value: handle)
        
        let startAction = CXStartCallAction(call: uuid, handle: cxHandle)
        startAction.isVideo = hasVideo
        
        let transaction = CXTransaction(action: startAction)
        callController.request(transaction) { [weak self] error in
            if let error = error {
                print("Outgoing call failed: \(error)")
                return
            }
            
            DispatchQueue.main.async {
                let call = Call(id: uuid, handle: handle, isOutgoing: true)
                self?.activeCalls.append(call)
                self?.callState = "Calling..."
            }
        }
    }
    
    // MARK: - Incoming Call (called from VoIP push)
    func reportIncomingCall(uuid: UUID, handle: String, hasVideo: Bool) {
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .phoneNumber, value: handle)
        update.hasVideo = hasVideo
        update.localizedCallerName = getContactName(for: handle)
        
        provider.reportNewIncomingCall(with: uuid, update: update) { [weak self] error in
            if let error = error {
                print("Incoming call report failed: \(error)")
                return
            }
            
            DispatchQueue.main.async {
                let call = Call(id: uuid, handle: handle, isOutgoing: false)
                self?.activeCalls.append(call)
                self?.callState = "Incoming..."
            }
        }
    }
    
    // MARK: - End Call
    func endCall(uuid: UUID) {
        let endAction = CXEndCallAction(call: uuid)
        let transaction = CXTransaction(action: endAction)
        
        callController.request(transaction) { error in
            if let error = error {
                print("End call failed: \(error)")
            }
        }
    }
    
    // MARK: - Hold
    func setHold(uuid: UUID, onHold: Bool) {
        let holdAction = CXSetHeldCallAction(call: uuid, onHold: onHold)
        let transaction = CXTransaction(action: holdAction)
        
        callController.request(transaction) { error in
            if let error = error {
                print("Hold failed: \(error)")
            }
        }
    }
    
    // MARK: - Mute
    func setMute(uuid: UUID, muted: Bool) {
        let muteAction = CXSetMutedCallAction(call: uuid, muted: muted)
        let transaction = CXTransaction(action: muteAction)
        
        callController.request(transaction) { error in
            if let error = error {
                print("Mute failed: \(error)")
            }
        }
    }
    
    // MARK: - DTMF
    func sendDTMF(uuid: UUID, digits: String) {
        let dtmfAction = CXPlayDTMFCallAction(call: uuid, digits: digits, type: .singleTone)
        let transaction = CXTransaction(action: dtmfAction)
        
        callController.request(transaction) { error in
            if let error = error {
                print("DTMF failed: \(error)")
            }
        }
    }
    
    // MARK: - Helpers
    private func getContactName(for handle: String) -> String {
        // Look up name from contacts
        return handle
    }
    
    private func configureAudioSession() {
        do {
            try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [.allowBluetooth, .defaultToSpeaker])
            try audioSession.setActive(true)
        } catch {
            print("Audio session setup failed: \(error)")
        }
    }
}

// MARK: - CXProviderDelegate
extension CallManager: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        // End all calls
        activeCalls.removeAll()
        callState = "Idle"
    }
    
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        // Start outgoing call
        configureAudioSession()
        
        // Start actual VoIP connection
        connectToVoIPServer(for: action.callUUID)
        
        action.fulfill()
        
        // Report connection started
        provider.reportOutgoingCall(with: action.callUUID, startedConnectingAt: Date())
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        // Answer incoming call
        configureAudioSession()
        
        // Actual VoIP connection
        connectToVoIPServer(for: action.callUUID)
        
        DispatchQueue.main.async {
            if let index = self.activeCalls.firstIndex(where: { $0.id == action.callUUID }) {
                self.activeCalls[index].startTime = Date()
            }
            self.callState = "On Call"
        }
        
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        // End call
        disconnectFromVoIPServer(for: action.callUUID)
        
        DispatchQueue.main.async {
            self.activeCalls.removeAll { $0.id == action.callUUID }
            self.callState = self.activeCalls.isEmpty ? "Idle" : "On Call"
        }
        
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        // Toggle hold
        DispatchQueue.main.async {
            if let index = self.activeCalls.firstIndex(where: { $0.id == action.callUUID }) {
                self.activeCalls[index].isOnHold = action.isOnHold
            }
        }
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        // Toggle mute
        DispatchQueue.main.async {
            if let index = self.activeCalls.firstIndex(where: { $0.id == action.callUUID }) {
                self.activeCalls[index].isMuted = action.isMuted
            }
        }
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        // Audio session activated - start audio stream
        startAudioStream()
    }
    
    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        // Audio session deactivated - stop audio stream
        stopAudioStream()
    }
    
    // MARK: - VoIP Connection (implementation required)
    private func connectToVoIPServer(for uuid: UUID) {
        // Implement actual connection with WebRTC, SIP, etc.
    }
    
    private func disconnectFromVoIPServer(for uuid: UUID) {
        // Disconnect
    }
    
    private func startAudioStream() {
        // Start audio stream
    }
    
    private func stopAudioStream() {
        // Stop audio stream
    }
}

// MARK: - VoIP Push (PushKit)
class PushKitManager: NSObject, PKPushRegistryDelegate {
    let callManager: CallManager
    let registry = PKPushRegistry(queue: .main)
    
    init(callManager: CallManager) {
        self.callManager = callManager
        super.init()
        
        registry.delegate = self
        registry.desiredPushTypes = [.voIP]
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        let token = pushCredentials.token.map { String(format: "%02x", $0) }.joined()
        print("VoIP push token: \(token)")
        // Register token with server
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        // VoIP push received
        let uuid = UUID()
        let handle = payload.dictionaryPayload["handle"] as? String ?? "Unknown"
        let hasVideo = payload.dictionaryPayload["hasVideo"] as? Bool ?? false
        
        // Must call reportNewIncomingCall (iOS 13+)
        callManager.reportIncomingCall(uuid: uuid, handle: handle, hasVideo: hasVideo)
        
        completion()
    }
}

// MARK: - Main View
struct CallView: View {
    @State private var callManager = CallManager()
    @State private var phoneNumber = ""
    
    var body: some View {
        NavigationStack {
            List {
                // Status
                Section {
                    LabeledContent("Status", value: callManager.callState)
                }
                
                // Outgoing
                Section("Outgoing Call") {
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                    
                    Button {
                        callManager.startOutgoingCall(to: phoneNumber)
                    } label: {
                        Label("Voice Call", systemImage: "phone.fill")
                    }
                    .disabled(phoneNumber.isEmpty)
                    
                    Button {
                        callManager.startOutgoingCall(to: phoneNumber, hasVideo: true)
                    } label: {
                        Label("Video Call", systemImage: "video.fill")
                    }
                    .disabled(phoneNumber.isEmpty)
                }
                
                // Active Calls
                if !callManager.activeCalls.isEmpty {
                    Section("Active Calls") {
                        ForEach(callManager.activeCalls) { call in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(call.handle)
                                        .font(.headline)
                                    Spacer()
                                    if call.isOnHold {
                                        Text("On Hold")
                                            .font(.caption)
                                            .foregroundStyle(.orange)
                                    }
                                }
                                
                                HStack(spacing: 16) {
                                    Button {
                                        callManager.setMute(uuid: call.id, muted: !call.isMuted)
                                    } label: {
                                        Image(systemName: call.isMuted ? "mic.slash.fill" : "mic.fill")
                                    }
                                    
                                    Button {
                                        callManager.setHold(uuid: call.id, onHold: !call.isOnHold)
                                    } label: {
                                        Image(systemName: call.isOnHold ? "play.fill" : "pause.fill")
                                    }
                                    
                                    Spacer()
                                    
                                    Button(role: .destructive) {
                                        callManager.endCall(uuid: call.id)
                                    } label: {
                                        Image(systemName: "phone.down.fill")
                                    }
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }
                }
                
                // Test Incoming (for development)
                #if DEBUG
                Section("Test") {
                    Button("Simulate Incoming Call") {
                        callManager.reportIncomingCall(
                            uuid: UUID(),
                            handle: "010-1234-5678",
                            hasVideo: false
                        )
                    }
                }
                #endif
            }
            .navigationTitle("VoIP")
        }
    }
}

#Preview {
    CallView()
}
```

## Advanced Patterns

### 1. Caller Identification (Call Directory Extension)

```swift
// CallDirectoryHandler.swift (Call Directory Extension)
import CallKit

class CallDirectoryHandler: CXCallDirectoryProvider {
    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        // Add blocked numbers
        addBlockedNumbers(to: context)
        
        // Add caller identification entries
        addIdentificationEntries(to: context)
        
        context.completeRequest()
    }
    
    private func addBlockedNumbers(to context: CXCallDirectoryExtensionContext) {
        let blockedNumbers: [CXCallDirectoryPhoneNumber] = [
            821012345678,  // Include country code, numbers only
            821087654321
        ]
        
        for number in blockedNumbers.sorted() {
            context.addBlockingEntry(withNextSequentialPhoneNumber: number)
        }
    }
    
    private func addIdentificationEntries(to context: CXCallDirectoryExtensionContext) {
        let phoneNumbers: [CXCallDirectoryPhoneNumber] = [821011112222]
        let labels = ["Suspected Spam"]
        
        for (number, label) in zip(phoneNumbers.sorted(), labels) {
            context.addIdentificationEntry(
                withNextSequentialPhoneNumber: number,
                label: label
            )
        }
    }
}
```

### 2. Call History Integration

```swift
// Set in CXProviderConfiguration
config.includesCallsInRecents = true

// Update call history when ending
func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
    // Include additional info in call history
    let update = CXCallUpdate()
    update.localizedCallerName = "Contact Name"
    
    provider.reportCall(with: action.callUUID, updated: update)
    action.fulfill()
}
```

## Important Notes

1. **VoIP Push Required** (iOS 13+)
   - Must call `reportNewIncomingCall` when receiving VoIP push
   - App will be terminated if not called

2. **Background Modes**
   - Voice over IP required
   - Remote notifications recommended

3. **Audio Session**
   - CallKit manages audio session
   - Control streams in `didActivate`/`didDeactivate`

4. **Simulator Limitations**
   - System call UI not displayed
   - Real device testing required

5. **China Restriction**
   - CallKit usage restricted in China
   - Alternative UI preparation needed
