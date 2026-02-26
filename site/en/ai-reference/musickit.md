# MusicKit AI Reference

> Apple Music 통합 가이드. 이 문서를 읽고 MusicKit 코드를 생성할 수 있습니다.

## 개요

MusicKit은 Apple Music 카탈로그 검색, 라이브러리 접근, 음악 재생을 지원하는 프레임워크입니다.
Apple Music 구독자에게 전체 기능을 제공합니다.

## 필수 Import

```swift
import MusicKit
```

## 프로젝트 설정

1. **Capabilities**: Media & Apple Music 추가
2. **Info.plist**:
```xml
<key>NSAppleMusicUsageDescription</key>
<string>음악 라이브러리에 접근하기 위해 필요합니다.</string>
```

## 핵심 구성요소

### 1. 권한 요청

```swift
func requestMusicAuthorization() async -> MusicAuthorization.Status {
    let status = await MusicAuthorization.request()
    return status
}

// 상태 확인
switch MusicAuthorization.currentStatus {
case .authorized: // 허용됨
case .denied: // 거부됨
case .notDetermined: // 미결정
case .restricted: // 제한됨
@unknown default: break
}
```

### 2. 음악 검색

```swift
func searchSongs(term: String) async throws -> MusicItemCollection<Song> {
    var request = MusicCatalogSearchRequest(term: term, types: [Song.self])
    request.limit = 25
    
    let response = try await request.response()
    return response.songs
}

// 아티스트 검색
func searchArtists(term: String) async throws -> MusicItemCollection<Artist> {
    var request = MusicCatalogSearchRequest(term: term, types: [Artist.self])
    request.limit = 10
    
    let response = try await request.response()
    return response.artists
}
```

### 3. 음악 재생

```swift
let player = ApplicationMusicPlayer.shared

// 노래 재생
func playSong(_ song: Song) async throws {
    player.queue = [song]
    try await player.play()
}

// 앨범 재생
func playAlbum(_ album: Album) async throws {
    player.queue = ApplicationMusicPlayer.Queue(album: album)
    try await player.play()
}

// 재생 제어
player.pause()
try await player.skipToNextEntry()
try await player.skipToPreviousEntry()
```

## 전체 작동 예제

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
            print("검색 실패: \(error)")
        }
    }
    
    func play(_ song: Song) async {
        do {
            player.queue = [song]
            try await player.play()
            currentSong = song
        } catch {
            print("재생 실패: \(error)")
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
        // 재생 상태 관찰
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
            .navigationTitle("음악")
        }
    }
    
    var musicContentView: some View {
        VStack(spacing: 0) {
            // 검색
            List {
                ForEach(manager.searchResults, id: \.id) { song in
                    SongRow(song: song) {
                        Task { await manager.play(song) }
                    }
                }
            }
            .searchable(text: $manager.searchText, prompt: "노래 검색")
            .onChange(of: manager.searchText) { _, _ in
                Task { await manager.search() }
            }
            
            // 미니 플레이어
            if let song = manager.currentSong {
                MiniPlayerView(song: song, manager: manager)
            }
        }
    }
    
    var requestAuthView: some View {
        ContentUnavailableView {
            Label("Apple Music 접근 필요", systemImage: "music.note")
        } description: {
            Text("음악을 재생하려면 권한이 필요합니다")
        } actions: {
            Button("권한 요청") {
                Task { await manager.requestAuthorization() }
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    var deniedView: some View {
        ContentUnavailableView {
            Label("접근 거부됨", systemImage: "music.note.slash")
        } description: {
            Text("설정에서 Apple Music 접근을 허용해주세요")
        } actions: {
            Button("설정 열기") {
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
                // 앨범 아트
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

## 고급 패턴

### 1. 사용자 라이브러리 접근

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

### 2. 추천 음악

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

### 3. 플레이리스트에 추가

```swift
func addToLibrary(_ song: Song) async throws {
    try await MusicLibrary.shared.add(song)
}

func createPlaylist(name: String, songs: [Song]) async throws {
    try await MusicLibrary.shared.createPlaylist(name: name, items: songs)
}
```

### 4. 가사 표시

```swift
func fetchLyrics(for song: Song) async throws -> String? {
    // song에 가사가 포함된 경우
    let detailedSong = try await song.with([.lyrics])
    return detailedSong.lyrics
}
```

## 주의사항

1. **Apple Music 구독 필요**
   - 전체 노래 재생은 구독자만 가능
   - 미구독자는 미리듣기(30초)만 재생

2. **백그라운드 재생**
   - Capabilities: Background Modes → Audio 추가
   - Info.plist: `UIBackgroundModes` → `audio`

3. **시뮬레이터 제한**
   - 시뮬레이터에서는 재생 불가
   - 검색/라이브러리 조회는 가능

4. **아트워크 크기**
   ```swift
   // 원하는 크기로 아트워크 로드
   if let artwork = song.artwork {
       ArtworkImage(artwork, width: 300, height: 300)
   }
   ```
