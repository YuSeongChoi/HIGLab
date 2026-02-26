# ShazamKit AI Reference

> Music recognition app implementation guide. You can generate ShazamKit code by reading this document.

## Overview

ShazamKit is a framework that provides music recognition capabilities, leveraging Shazam's extensive music database.
It supports audio matching, custom catalogs, and adding to music library.

## Required Import

```swift
import ShazamKit
import AVFoundation  // For audio capture
```

## Project Setup

### 1. Add Capability
Xcode > Signing & Capabilities > + ShazamKit

### 2. Permission Setup

```xml
<!-- Info.plist -->
<key>NSMicrophoneUsageDescription</key>
<string>Microphone access is required to recognize music.</string>
```

## Core Components

### 1. SHSession (Recognition Session)

```swift
import ShazamKit

let session = SHSession()

// Set delegate
session.delegate = self

// SHSessionDelegate
func session(_ session: SHSession, didFind match: SHMatch) {
    // Match found
    if let mediaItem = match.mediaItems.first {
        print("Title: \(mediaItem.title ?? "Unknown")")
        print("Artist: \(mediaItem.artist ?? "Unknown")")
    }
}

func session(_ session: SHSession, didNotFindMatchFor signature: SHSignature, error: Error?) {
    // Match not found
}
```

### 2. SHManagedSession (Auto-managed Session)

```swift
// iOS 17+ simplified API
let managedSession = SHManagedSession()

// Automatically requests microphone permission and captures audio
let result = await managedSession.result()

switch result {
case .match(let match):
    print("Found: \(match.mediaItems.first?.title ?? "")")
case .noMatch(_):
    print("No match found")
case .error(let error, _):
    print("Error: \(error)")
}
```

### 3. SHMediaItem (Recognition Result)

```swift
let item: SHMediaItem

item.title          // Song title
item.artist         // Artist
item.artworkURL     // Album art URL
item.appleMusicURL  // Apple Music link
item.appleMusicID   // Apple Music ID
item.isrc           // International Standard Recording Code
item.genres         // Genre array
item.videoURL       // Music video URL (if available)
```

## Complete Working Example

```swift
import SwiftUI
import ShazamKit
import AVFoundation

// MARK: - Shazam Manager
@Observable
class ShazamManager: NSObject {
    var isListening = false
    var matchedSong: SHMediaItem?
    var errorMessage: String?
    var isLoading = false
    
    private var session: SHSession?
    private var audioEngine: AVAudioEngine?
    
    override init() {
        super.init()
        session = SHSession()
        session?.delegate = self
    }
    
    func startListening() {
        guard !isListening else { return }
        
        matchedSong = nil
        errorMessage = nil
        isLoading = true
        
        // Setup audio engine
        audioEngine = AVAudioEngine()
        let inputNode = audioEngine!.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        // Install audio tap
        inputNode.installTap(onBus: 0, bufferSize: 2048, format: recordingFormat) { [weak self] buffer, time in
            self?.session?.matchStreamingBuffer(buffer, at: time)
        }
        
        // Setup audio session
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setActive(true)
            
            try audioEngine?.start()
            isListening = true
        } catch {
            errorMessage = "Microphone access failed: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func stopListening() {
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine?.stop()
        audioEngine = nil
        isListening = false
        isLoading = false
    }
}

// MARK: - SHSessionDelegate
extension ShazamManager: SHSessionDelegate {
    func session(_ session: SHSession, didFind match: SHMatch) {
        DispatchQueue.main.async {
            self.matchedSong = match.mediaItems.first
            self.isLoading = false
            self.stopListening()
        }
    }
    
    func session(_ session: SHSession, didNotFindMatchFor signature: SHSignature, error: Error?) {
        DispatchQueue.main.async {
            self.errorMessage = error?.localizedDescription ?? "Could not find music"
            self.isLoading = false
        }
    }
}

// MARK: - Main View
struct ShazamView: View {
    @State private var manager = ShazamManager()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                // Result or status display
                if let song = manager.matchedSong {
                    SongResultView(song: song)
                } else if manager.isLoading {
                    ListeningView()
                } else if let error = manager.errorMessage {
                    ErrorView(message: error) {
                        manager.errorMessage = nil
                    }
                } else {
                    ReadyView()
                }
                
                Spacer()
                
                // Recognition button
                Button {
                    if manager.isListening {
                        manager.stopListening()
                    } else {
                        manager.startListening()
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(manager.isListening ? .red : .blue)
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: manager.isListening ? "stop.fill" : "shazam.logo.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.white)
                    }
                }
                .padding(.bottom, 48)
            }
            .padding()
            .navigationTitle("Music Recognition")
        }
    }
}

// MARK: - Song Result View
struct SongResultView: View {
    let song: SHMediaItem
    
    var body: some View {
        VStack(spacing: 16) {
            // Album art
            AsyncImage(url: song.artworkURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.quaternary)
                    .overlay {
                        Image(systemName: "music.note")
                            .font(.largeTitle)
                    }
            }
            .frame(width: 200, height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 10)
            
            // Song info
            VStack(spacing: 8) {
                Text(song.title ?? "Unknown Title")
                    .font(.title2.bold())
                
                Text(song.artist ?? "Unknown Artist")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                
                if let genres = song.genres, !genres.isEmpty {
                    Text(genres.joined(separator: ", "))
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                }
            }
            
            // Action buttons
            HStack(spacing: 16) {
                if let appleMusicURL = song.appleMusicURL {
                    Link(destination: appleMusicURL) {
                        Label("Apple Music", systemImage: "apple.logo")
                            .padding()
                            .background(.pink)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                }
                
                Button {
                    addToShazamLibrary(song)
                } label: {
                    Label("Add to Library", systemImage: "plus")
                        .padding()
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
        }
    }
    
    func addToShazamLibrary(_ item: SHMediaItem) {
        Task {
            do {
                try await SHMediaLibrary.default.add([item])
            } catch {
                print("Failed to add to library: \(error)")
            }
        }
    }
}

// MARK: - Listening View
struct ListeningView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                ForEach(0..<3) { i in
                    Circle()
                        .stroke(lineWidth: 2)
                        .foregroundStyle(.blue.opacity(0.5))
                        .scaleEffect(isAnimating ? 2 : 1)
                        .opacity(isAnimating ? 0 : 1)
                        .animation(
                            .easeOut(duration: 1.5)
                            .repeatForever(autoreverses: false)
                            .delay(Double(i) * 0.5),
                            value: isAnimating
                        )
                }
                
                Image(systemName: "waveform")
                    .font(.system(size: 40))
                    .foregroundStyle(.blue)
            }
            .frame(width: 120, height: 120)
            
            Text("Listening...")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .onAppear { isAnimating = true }
    }
}

// MARK: - Ready View
struct ReadyView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "shazam.logo")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
            
            Text("Tap the button to recognize music")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Error View
struct ErrorView: View {
    let message: String
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundStyle(.orange)
            
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            
            Button("Try Again", action: onDismiss)
                .buttonStyle(.bordered)
        }
    }
}

#Preview {
    ShazamView()
}
```

## Advanced Patterns

### 1. SHManagedSession (iOS 17+)

```swift
// Simple auto-managed session
@Observable
class SimpleShazamManager {
    var result: SHManagedSession.Result?
    private let session = SHManagedSession()
    
    func recognize() async {
        // Automatically requests microphone permission and captures audio
        result = await session.result()
    }
    
    func cancel() {
        session.cancel()
    }
}

// Usage
struct SimpleShazamView: View {
    @State private var manager = SimpleShazamManager()
    
    var body: some View {
        Button("Recognize") {
            Task {
                await manager.recognize()
            }
        }
    }
}
```

### 2. Custom Catalog

```swift
// Create custom catalog from your own audio files
func createCustomCatalog() async throws -> SHCustomCatalog {
    let catalog = SHCustomCatalog()
    
    // Generate signature from audio file
    let audioURL = Bundle.main.url(forResource: "mysong", withExtension: "mp3")!
    let signatureGenerator = SHSignatureGenerator()
    
    try await signatureGenerator.generateSignature(from: audioURL)
    
    if let signature = signatureGenerator.signature {
        // Associate metadata
        let mediaItem = SHMediaItem(properties: [
            .title: "My Song",
            .artist: "My Artist",
            .artworkURL: URL(string: "https://...")!
        ])
        
        try catalog.addReferenceSignature(signature, representing: [mediaItem])
    }
    
    return catalog
}

// Create session with custom catalog
let session = SHSession(catalog: customCatalog)
```

### 3. Background Recognition

```swift
// Continuous recognition in Scene Delegate
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    let session = SHManagedSession()
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        Task {
            // Keep recognizing
            for await result in session.results {
                switch result {
                case .match(let match):
                    handleMatch(match)
                case .noMatch:
                    continue
                case .error(let error, _):
                    print("Error: \(error)")
                }
            }
        }
    }
}
```

### 4. Recognize from File

```swift
// Recognize from recorded audio file
func recognizeFromFile(url: URL) async throws -> SHMatch? {
    let session = SHSession()
    
    // Generate signature from file
    let generator = SHSignatureGenerator()
    try await generator.generateSignature(from: url)
    
    guard let signature = generator.signature else { return nil }
    
    // Request match
    return try await withCheckedThrowingContinuation { continuation in
        session.delegate = SignatureDelegate { match in
            continuation.resume(returning: match)
        } onError: { error in
            continuation.resume(throwing: error ?? ShazamError.unknown)
        }
        
        session.match(signature)
    }
}
```

### 5. Shazam Library Management

```swift
// Add song to library
func addToLibrary(_ items: [SHMediaItem]) async throws {
    try await SHMediaLibrary.default.add(items)
}

// Read library items (only those added by app)
func getLibraryItems() async -> [SHMediaItem] {
    var items: [SHMediaItem] = []
    
    for await itemCollection in SHMediaLibrary.default.items {
        items.append(contentsOf: itemCollection)
    }
    
    return items
}
```

## Notes

1. **Microphone Permission**
   ```swift
   // Check permission status
   switch AVAudioSession.sharedInstance().recordPermission {
   case .granted:
       startListening()
   case .denied:
       showPermissionAlert()
   case .undetermined:
       AVAudioSession.sharedInstance().requestRecordPermission { granted in
           // Handle
       }
   }
   ```

2. **API Call Limits**
   - Shazam catalog queries have limits
   - Check free tier limitations

3. **Custom Catalog**
   - Maximum 100 reference signatures
   - Can be saved locally or shared

4. **Background**
   - Requires background audio permission
   - Watch battery consumption

5. **Simulator**
   - Limited microphone input
   - Recommended to test with files
