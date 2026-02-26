# Core NFC AI Reference

> NFC tag read/write guide. Read this document to generate Core NFC code.

## Overview

Core NFC is a framework that uses iPhone's NFC reader to read and write NDEF tags.
It supports various data formats including URLs, text, contacts, and also supports ISO 7816, ISO 15693, and FeliCa tags.

## Required Import

```swift
import CoreNFC
```

## Project Setup

### 1. Add Capability
Xcode > Signing & Capabilities > + Near Field Communication Tag Reading

### 2. Info.plist Setup

```xml
<!-- NFC usage description -->
<key>NFCReaderUsageDescription</key>
<string>Required to read NFC tags.</string>

<!-- Tag types to read (ISO 7816, etc.) -->
<key>com.apple.developer.nfc.readersession.iso7816.select-identifiers</key>
<array>
    <string>A0000002471001</string>
</array>

<!-- FeliCa system codes -->
<key>com.apple.developer.nfc.readersession.felica.systemcodes</key>
<array>
    <string>12FC</string>
</array>
```

## Core Components

### 1. NFCNDEFReaderSession (NDEF Reading)

```swift
import CoreNFC

class NFCReader: NSObject, NFCNDEFReaderSessionDelegate {
    var session: NFCNDEFReaderSession?
    
    func startScanning() {
        guard NFCNDEFReaderSession.readingAvailable else {
            print("NFC is not available")
            return
        }
        
        session = NFCNDEFReaderSession(
            delegate: self,
            queue: nil,
            invalidateAfterFirstRead: true
        )
        session?.alertMessage = "Hold your iPhone near the NFC tag"
        session?.begin()
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        for message in messages {
            for record in message.records {
                // Process record
            }
        }
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print("Session ended: \(error.localizedDescription)")
    }
}
```

### 2. NFCNDEFMessage (NDEF Message)

```swift
// NDEF record types
let record = message.records.first!

record.typeNameFormat  // TNF (well-known, media, etc.)
record.type           // Record type (T, U, Sp, etc.)
record.identifier     // Identifier
record.payload        // Actual data

// Parse URL
if let url = record.wellKnownTypeURIPayload() {
    print("URL: \(url)")
}

// Parse text
if let (text, locale) = record.wellKnownTypeTextPayload() {
    print("Text: \(text), Language: \(locale)")
}
```

### 3. NFCTagReaderSession (Advanced Tags)

```swift
class AdvancedNFCReader: NSObject, NFCTagReaderSessionDelegate {
    var session: NFCTagReaderSession?
    
    func startScanning() {
        session = NFCTagReaderSession(
            pollingOption: [.iso14443, .iso15693, .iso18092],
            delegate: self
        )
        session?.alertMessage = "Scan a tag"
        session?.begin()
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        guard let tag = tags.first else { return }
        
        session.connect(to: tag) { error in
            if let error = error {
                session.invalidate(errorMessage: "Connection failed")
                return
            }
            
            switch tag {
            case .miFare(let miFareTag):
                self.handleMiFare(miFareTag)
            case .iso7816(let iso7816Tag):
                self.handleISO7816(iso7816Tag)
            case .iso15693(let iso15693Tag):
                self.handleISO15693(iso15693Tag)
            case .feliCa(let feliCaTag):
                self.handleFeliCa(feliCaTag)
            @unknown default:
                break
            }
        }
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        print("Error: \(error)")
    }
    
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        print("NFC session activated")
    }
}
```

## Complete Working Example

```swift
import SwiftUI
import CoreNFC

// MARK: - NFC Manager
@Observable
class NFCManager: NSObject {
    var scannedMessage: String = ""
    var scannedURL: URL?
    var isScanning = false
    var errorMessage: String?
    var isNFCAvailable: Bool {
        NFCNDEFReaderSession.readingAvailable
    }
    
    private var session: NFCNDEFReaderSession?
    private var writeSession: NFCNDEFReaderSession?
    private var messageToWrite: NFCNDEFMessage?
    
    // MARK: - Reading
    func startScanning() {
        guard isNFCAvailable else {
            errorMessage = "This device does not support NFC"
            return
        }
        
        scannedMessage = ""
        scannedURL = nil
        errorMessage = nil
        
        session = NFCNDEFReaderSession(
            delegate: self,
            queue: nil,
            invalidateAfterFirstRead: true
        )
        session?.alertMessage = "Hold your iPhone near the NFC tag"
        session?.begin()
        isScanning = true
    }
    
    // MARK: - Writing
    func writeURL(_ url: URL) {
        guard isNFCAvailable else { return }
        
        // Create URL record
        guard let payload = NFCNDEFPayload.wellKnownTypeURIPayload(url: url) else { return }
        messageToWrite = NFCNDEFMessage(records: [payload])
        
        writeSession = NFCNDEFReaderSession(
            delegate: self,
            queue: nil,
            invalidateAfterFirstRead: false
        )
        writeSession?.alertMessage = "Hold your iPhone near the tag to write"
        writeSession?.begin()
        isScanning = true
    }
    
    func writeText(_ text: String) {
        guard isNFCAvailable else { return }
        
        // Create text record
        guard let payload = NFCNDEFPayload.wellKnownTypeTextPayload(
            string: text,
            locale: Locale.current
        ) else { return }
        
        messageToWrite = NFCNDEFMessage(records: [payload])
        
        writeSession = NFCNDEFReaderSession(
            delegate: self,
            queue: nil,
            invalidateAfterFirstRead: false
        )
        writeSession?.alertMessage = "Hold your iPhone near the tag to write"
        writeSession?.begin()
        isScanning = true
    }
}

// MARK: - NFCNDEFReaderSessionDelegate
extension NFCManager: NFCNDEFReaderSessionDelegate {
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        print("NFC session activated")
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        // Read-only mode
        for message in messages {
            processMessage(message)
        }
        
        DispatchQueue.main.async {
            self.isScanning = false
        }
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCTag]) {
        guard let tag = tags.first else {
            session.invalidate(errorMessage: "Tag not found")
            return
        }
        
        session.connect(to: tag) { error in
            if let error = error {
                session.invalidate(errorMessage: "Connection failed: \(error.localizedDescription)")
                return
            }
            
            // Get NDEF handle based on tag type
            var ndefTag: NFCNDEFTag?
            switch tag {
            case .miFare(let miFareTag):
                ndefTag = miFareTag
            case .iso7816(let iso7816Tag):
                ndefTag = iso7816Tag
            case .iso15693(let iso15693Tag):
                ndefTag = iso15693Tag
            case .feliCa(let feliCaTag):
                ndefTag = feliCaTag
            @unknown default:
                session.invalidate(errorMessage: "Unsupported tag")
                return
            }
            
            guard let ndef = ndefTag else { return }
            
            // Write mode
            if let message = self.messageToWrite {
                self.writeToTag(ndef, message: message, session: session)
            } else {
                // Read mode
                self.readFromTag(ndef, session: session)
            }
        }
    }
    
    private func readFromTag(_ tag: NFCNDEFTag, session: NFCNDEFReaderSession) {
        tag.readNDEF { message, error in
            if let error = error {
                session.invalidate(errorMessage: "Read failed: \(error.localizedDescription)")
                return
            }
            
            if let message = message {
                self.processMessage(message)
                session.alertMessage = "Tag read successfully!"
                session.invalidate()
            }
        }
    }
    
    private func writeToTag(_ tag: NFCNDEFTag, message: NFCNDEFMessage, session: NFCNDEFReaderSession) {
        tag.queryNDEFStatus { status, capacity, error in
            if let error = error {
                session.invalidate(errorMessage: "Status check failed: \(error.localizedDescription)")
                return
            }
            
            switch status {
            case .notSupported:
                session.invalidate(errorMessage: "Tag does not support NDEF")
            case .readOnly:
                session.invalidate(errorMessage: "Tag is read-only")
            case .readWrite:
                tag.writeNDEF(message) { error in
                    if let error = error {
                        session.invalidate(errorMessage: "Write failed: \(error.localizedDescription)")
                    } else {
                        session.alertMessage = "Write complete!"
                        session.invalidate()
                        DispatchQueue.main.async {
                            self.messageToWrite = nil
                        }
                    }
                }
            @unknown default:
                session.invalidate(errorMessage: "Unknown status")
            }
            
            DispatchQueue.main.async {
                self.isScanning = false
            }
        }
    }
    
    private func processMessage(_ message: NFCNDEFMessage) {
        var texts: [String] = []
        
        for record in message.records {
            // URL
            if let url = record.wellKnownTypeURIPayload() {
                DispatchQueue.main.async {
                    self.scannedURL = url
                }
                texts.append("URL: \(url.absoluteString)")
            }
            
            // Text
            if let (text, locale) = record.wellKnownTypeTextPayload() {
                texts.append("[\(locale.identifier)] \(text)")
            }
        }
        
        DispatchQueue.main.async {
            self.scannedMessage = texts.joined(separator: "\n")
        }
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        DispatchQueue.main.async {
            self.isScanning = false
            
            if let nfcError = error as? NFCReaderError,
               nfcError.code != .readerSessionInvalidationErrorFirstNDEFTagRead &&
               nfcError.code != .readerSessionInvalidationErrorUserCanceled {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - Main View
struct NFCView: View {
    @State private var manager = NFCManager()
    @State private var textToWrite = ""
    @State private var urlToWrite = ""
    @State private var showWriteSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                // Status section
                Section {
                    HStack {
                        Image(systemName: manager.isNFCAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(manager.isNFCAvailable ? .green : .red)
                        Text(manager.isNFCAvailable ? "NFC Available" : "NFC Not Available")
                    }
                }
                
                // Read result
                if !manager.scannedMessage.isEmpty {
                    Section("Scanned Content") {
                        Text(manager.scannedMessage)
                        
                        if let url = manager.scannedURL {
                            Link("Open Link", destination: url)
                        }
                    }
                }
                
                // Error
                if let error = manager.errorMessage {
                    Section {
                        Label(error, systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.red)
                    }
                }
                
                // Actions
                Section {
                    Button {
                        manager.startScanning()
                    } label: {
                        Label("Read Tag", systemImage: "wave.3.right")
                    }
                    .disabled(manager.isScanning)
                    
                    Button {
                        showWriteSheet = true
                    } label: {
                        Label("Write to Tag", systemImage: "square.and.pencil")
                    }
                    .disabled(manager.isScanning)
                }
            }
            .navigationTitle("NFC")
            .overlay {
                if manager.isScanning {
                    VStack {
                        ProgressView()
                        Text("Scanning...")
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .sheet(isPresented: $showWriteSheet) {
                NavigationStack {
                    Form {
                        Section("Write Text") {
                            TextField("Text", text: $textToWrite)
                            Button("Write") {
                                manager.writeText(textToWrite)
                                showWriteSheet = false
                            }
                            .disabled(textToWrite.isEmpty)
                        }
                        
                        Section("Write URL") {
                            TextField("URL", text: $urlToWrite)
                                .keyboardType(.URL)
                                .autocapitalization(.none)
                            Button("Write") {
                                if let url = URL(string: urlToWrite) {
                                    manager.writeURL(url)
                                    showWriteSheet = false
                                }
                            }
                            .disabled(URL(string: urlToWrite) == nil)
                        }
                    }
                    .navigationTitle("Write to Tag")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showWriteSheet = false
                            }
                        }
                    }
                }
                .presentationDetents([.medium])
            }
        }
    }
}

#Preview {
    NFCView()
}
```

## Advanced Patterns

### 1. Background Tag Reading

```swift
// Setup in AppDelegate
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Background NDEF detection is automatic
    return true
}

// Handle in SceneDelegate
func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
    guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
          let url = userActivity.webpageURL else { return }
    
    // Handle NFC tag URL
    handleNFCURL(url)
}
```

### 2. ISO 7816 Smart Card

```swift
func handleISO7816(_ tag: NFCISO7816Tag) {
    // Select AID
    let selectAID = NFCISO7816APDU(
        instructionClass: 0x00,
        instructionCode: 0xA4,
        p1Parameter: 0x04,
        p2Parameter: 0x00,
        data: Data([0xA0, 0x00, 0x00, 0x02, 0x47, 0x10, 0x01]),
        expectedResponseLength: -1
    )
    
    tag.sendCommand(apdu: selectAID) { data, sw1, sw2, error in
        if sw1 == 0x90 && sw2 == 0x00 {
            print("Selection successful, data: \(data)")
        }
    }
}
```

### 3. FeliCa (Suica, etc.)

```swift
func handleFeliCa(_ tag: NFCFeliCaTag) {
    let serviceCode = Data([0x00, 0x0B])  // Service code
    
    tag.readWithoutEncryption(
        serviceCodeList: [serviceCode],
        blockList: [Data([0x80, 0x00])]
    ) { status1, status2, blocks, error in
        if let error = error {
            print("Read failed: \(error)")
            return
        }
        
        for block in blocks {
            print("Block data: \(block.hexString)")
        }
    }
}
```

## Important Notes

1. **Device Compatibility**
   ```swift
   // iPhone 7 and later, iOS 11+
   guard NFCNDEFReaderSession.readingAvailable else {
       // NFC not supported
       return
   }
   ```

2. **Session Limitations**
   - Only one NFC session at a time
   - 60-second timeout
   - Only works in foreground

3. **Tag Types**
   - NDEF: Most NFC tags
   - ISO 7816: Smart cards, credit cards
   - FeliCa: Japanese transit cards (Suica)
   - MIFARE: Access cards

4. **Background Tag Reading for Apps**
   - Supported on iOS 12+
   - Use Universal Links or URL Scheme
   - Entitlements required

5. **Simulator**
   - NFC not supported
   - Real device testing required
