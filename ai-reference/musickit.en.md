# MusicKit AI Reference

> Apple Music integration guide. Read this document to generate MusicKit code.

## Overview

MusicKit is a framework that supports Apple Music catalog search, library access, and music playback.
It provides full functionality to Apple Music subscribers.

## Required Import

```swift
import MusicKit
```

## Project Setup

1. **Capabilities**: Add Media & Apple Music
2. **Info.plist**:
```xml
<key>NSAppleMusicUsageDescription</key>
<string>Required to access your music library.</string>
```

## Core Components

### 1. Request Permission

```swift
func requestMusicAuthorization() async -> MusicAuthorization.Status {
    let status = await MusicAuthorization.request()
    return status
}

// Check status
switch MusicAuthorization.currentStatus {
case .authorized: // Granted
case .denied: // Denied
case .notDetermined: // Not determined
case .restricted: // Restricted
@unknown default: break
}
```

### 2. Search Music

```swift
func searchSongs(term: String) async throws -> MusicItemCollection<Song> {
    var request = MusicCatalogSearchRequest(term: term, types: [Song.self])
    request.limit = 25
    
    let response = try await request.response()
    return response.songs
}

// Search artists
func searchArtists(term: String) async throws -> MusicItemCollection<Artist> {
    var request = MusicCatalogSearchRequest(term: term, types: [Artist.self])
    request.limit = 10
    
    let response = try await request.response()
    return response.artists
}
```

### 3. Play Music

```swift
let player = ApplicationMusicPlayer.shared

// Play song
func playSong(_ song: Song) async throws {
    player.queue = [song]
    try await player.play()
}

// Play album
func playAlbum(_ album: Album) async throws {
    player.queue = ApplicationMusicPlayer.Queue(album: album)
    try await player.play()
}

// Playback controls
player.pause()
try await player.skipToNextEntry()
try await player.skipToPreviousEntry()
```

## Complete Working Example

```swift
import SwiftUI
import MusicKit

// MARK: - Music Manager
@Observable
class MusicManager {
    var authorizationStatus: MusicAuthorization.Status = .notDetermined
    var searchResults: MusicItemCollection<Song> = []
    var isPlaying = false
    var currentSong: Song?
    var searchText = ""
    
    private let player = ApplicationMusicPlayer.shared
    
    init() {
        authorizationStatus = MusicAuthorization.currentStatus
        observePlayer()
    }
    
    func requestAuthorization() async {
        authorizationStatus = await MusicAuthorization.request()
    }
    
    func search() async {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        
        do {
            var request = MusicCatalogSearchRequest(term: searchText, types: [Song.self])
            request.limit = 25
            
            let response = try await request.response()
            searchResults = response.songs
        } catch {
            print("Search failed: \(error)")
        }
    }
    
    func play(_ song: Song) async {
        do {
            player.queue = [song]
            try await player.play()
            currentSong = song
        } catch {
            print("Playback failed: \(error)")
        }
    }
    
    func togglePlayPause() {
        if isPlaying {
            player.pause()
        } else {
            Task {
                try? await player.play()
            }
        }
    }
    
    func skipNext() async {
        try? await player.skipToNextEntry()
    }
    
    func skipPrevious() async {
        try? await player.skipToPreviousEntry()
    }
    
    private func observePlayer() {
        // Observe playback state
        Task {
            for await state in player.state.objectWillChange.values {
                await MainActor.run {
                    isPlaying = player.state.playbackStatus == .playing
                }
            }
        }
    }
}

// MARK: - Views
struct MusicPlayerView: View {
    @State private var manager = MusicManager()
    
    var body: some View {
        NavigationStack {
            Group {
                switch manager.authorizationStatus {
                case .authorized:
                    musicContentView
                case .notDetermined:
                    requestAuthView
                default:
                    deniedView
                }
            }
            .navigationTitle("Music")
        }
    }
    
    var musicContentView: some View {
        VStack(spacing: 0) {
            // Search
            List {
                ForEach(manager.searchResults, id: \.id) { song in
                    SongRow(song: song) {
                        Task { await manager.play(song) }
                    }
                }
            }
            .searchable(text: $manager.searchText, prompt: "Search songs")
            .onChange(of: manager.searchText) { _, _ in
                Task { await manager.search() }
            }
            
            // Mini player
            if let song = manager.currentSong {
                MiniPlayerView(song: song, manager: manager)
            }
        }
    }
    
    var requestAuthView: some View {
        ContentUnavailableView {
            Label("Apple Music Access Required", systemImage: "music.note")
        } description: {
            Text("Permission is required to play music")
        } actions: {
            Button("Request Permission") {
                Task { await manager.requestAuthorization() }
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    var deniedView: some View {
        ContentUnavailableView {
            Label("Access Denied", systemImage: "music.note.slash")
        } description: {
            Text("Please allow Apple Music access in Settings")
        } actions: {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
}

struct SongRow: View {
    let song: Song
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Album art
                if let artwork = song.artwork {
                    ArtworkImage(artwork, width: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                } else {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.gray.opacity(0.3))
                        .frame(width: 50, height: 50)
                }
                
                VStack(alignment: .leading) {
                    Text(song.title)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text(song.artistName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                if let duration = song.duration {
                    Text(formatDuration(duration))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .buttonStyle(.plain)
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct MiniPlayerView: View {
    let song: Song
    let manager: MusicManager
    
    var body: some View {
        HStack(spacing: 16) {
            if let artwork = song.artwork {
                ArtworkImage(artwork, width: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            
            VStack(alignment: .leading) {
                Text(song.title)
                    .font(.headline)
                    .lineLimit(1)
                Text(song.artistName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 20) {
                Button {
                    Task { await manager.skipPrevious() }
                } label: {
                    Image(systemName: "backward.fill")
                }
                
                Button {
                    manager.togglePlayPause()
                } label: {
                    Image(systemName: manager.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title2)
                }
                
                Button {
                    Task { await manager.skipNext() }
                } label: {
                    Image(systemName: "forward.fill")
                }
            }
            .foregroundStyle(.primary)
        }
        .padding()
        .background(.ultraThinMaterial)
    }
}
```

## Advanced Patterns

### 1. Access User Library

```swift
func fetchLibrarySongs() async throws -> MusicItemCollection<Song> {
    var request = MusicLibraryRequest<Song>()
    request.sort(by: \.dateAdded, ascending: false)
    request.limit = 50
    
    let response = try await request.response()
    return response.items
}

func fetchLibraryPlaylists() async throws -> MusicItemCollection<Playlist> {
    let request = MusicLibraryRequest<Playlist>()
    let response = try await request.response()
    return response.items
}
```

### 2. Recommendations

```swift
func fetchRecommendations() async throws -> MusicItemCollection<MusicPersonalRecommendation> {
    let request = MusicPersonalRecommendationsRequest()
    let response = try await request.response()
    return response.recommendations
}

func fetchCharts() async throws {
    let request = MusicCatalogChartsRequest(kinds: [.mostPlayed], types: [Song.self])
    let response = try await request.response()
    // response.songCharts
}
```

### 3. Add to Playlist

```swift
func addToLibrary(_ song: Song) async throws {
    try await MusicLibrary.shared.add(song)
}

func createPlaylist(name: String, songs: [Song]) async throws {
    try await MusicLibrary.shared.createPlaylist(name: name, items: songs)
}
```

### 4. Display Lyrics

```swift
func fetchLyrics(for song: Song) async throws -> String? {
    // If lyrics are included in the song
    let detailedSong = try await song.with([.lyrics])
    return detailedSong.lyrics
}
```

## Important Notes

1. **Apple Music Subscription Required**
   - Full song playback only for subscribers
   - Non-subscribers can only play previews (30 seconds)

2. **Background Playback**
   - Capabilities: Background Modes → Audio
   - Info.plist: `UIBackgroundModes` → `audio`

3. **Simulator Limitations**
   - Playback not available in simulator
   - Search/library queries work

4. **Artwork Size**
   ```swift
   // Load artwork at desired size
   if let artwork = song.artwork {
       ArtworkImage(artwork, width: 300, height: 300)
   }
   ```
