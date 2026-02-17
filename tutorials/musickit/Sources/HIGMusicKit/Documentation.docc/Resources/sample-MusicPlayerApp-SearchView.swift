import SwiftUI
import MusicKit

// MARK: - Search View
// Apple Music 카탈로그 검색

struct SearchView: View {
    @EnvironmentObject var musicService: MusicService
    @EnvironmentObject var playerManager: PlayerManager
    
    @State private var searchText = ""
    @State private var selectedType: SearchResultType = .songs
    
    // 검색 결과
    @State private var songs: [SongItem] = []
    @State private var albums: [AlbumItem] = []
    @State private var artists: [ArtistItem] = []
    
    @State private var isSearching = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 검색 타입 필터
                Picker("검색 유형", selection: $selectedType) {
                    ForEach(SearchResultType.allCases) { type in
                        Label(type.rawValue, systemImage: type.systemImage)
                            .tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // 검색 결과
                Group {
                    if isSearching {
                        ProgressView("검색 중...")
                            .frame(maxHeight: .infinity)
                    } else if let error = errorMessage {
                        ContentUnavailableView(
                            "오류 발생",
                            systemImage: "exclamationmark.triangle",
                            description: Text(error)
                        )
                    } else if searchText.isEmpty {
                        ContentUnavailableView(
                            "검색어를 입력하세요",
                            systemImage: "magnifyingglass",
                            description: Text("Apple Music 카탈로그에서\n노래, 앨범, 아티스트를 검색합니다.")
                        )
                    } else if currentResults.isEmpty {
                        ContentUnavailableView.search(text: searchText)
                    } else {
                        searchResultsList
                    }
                }
            }
            .navigationTitle("검색")
            .searchable(text: $searchText, prompt: "Apple Music 검색")
            .onChange(of: searchText) { _, newValue in
                performSearch(query: newValue)
            }
            .onChange(of: selectedType) { _, _ in
                performSearch(query: searchText)
            }
        }
    }
    
    // MARK: - Search Results List
    
    @ViewBuilder
    private var searchResultsList: some View {
        List {
            switch selectedType {
            case .songs:
                ForEach(songs) { song in
                    SongRow(song: song)
                        .onTapGesture {
                            playSong(song)
                        }
                }
                
            case .albums:
                ForEach(albums) { album in
                    AlbumRow(album: album)
                }
                
            case .artists:
                ForEach(artists) { artist in
                    ArtistRow(artist: artist)
                }
            }
        }
        .listStyle(.plain)
    }
    
    // MARK: - Computed Properties
    
    private var currentResults: [any Identifiable] {
        switch selectedType {
        case .songs: return songs
        case .albums: return albums
        case .artists: return artists
        }
    }
    
    // MARK: - Search
    
    private func performSearch(query: String) {
        guard !query.isEmpty else {
            clearResults()
            return
        }
        
        // 디바운스: 빠른 타이핑 시 불필요한 요청 방지
        Task {
            try? await Task.sleep(for: .milliseconds(300))
            
            guard query == searchText else { return }
            
            isSearching = true
            errorMessage = nil
            
            do {
                switch selectedType {
                case .songs:
                    songs = try await musicService.searchSongs(query: query)
                case .albums:
                    albums = try await musicService.searchAlbums(query: query)
                case .artists:
                    artists = try await musicService.searchArtists(query: query)
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            
            isSearching = false
        }
    }
    
    private func clearResults() {
        songs = []
        albums = []
        artists = []
    }
    
    private func playSong(_ song: SongItem) {
        Task {
            do {
                try await playerManager.play(songItem: song)
            } catch {
                print("재생 실패: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Song Row

struct SongRow: View {
    let song: SongItem
    
    var body: some View {
        HStack(spacing: 12) {
            // 앨범 아트워크
            if let artwork = song.artwork {
                ArtworkImage(artwork, width: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            } else {
                RoundedRectangle(cornerRadius: 6)
                    .fill(.tertiary)
                    .frame(width: 50, height: 50)
                    .overlay {
                        Image(systemName: "music.note")
                            .foregroundStyle(.secondary)
                    }
            }
            
            // 곡 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(song.title)
                    .font(.body)
                    .lineLimit(1)
                
                Text(song.artistName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // 재생 시간
            Text(song.formattedDuration)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle())
    }
}

// MARK: - Album Row

struct AlbumRow: View {
    let album: AlbumItem
    
    var body: some View {
        HStack(spacing: 12) {
            if let artwork = album.artwork {
                ArtworkImage(artwork, width: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.tertiary)
                    .frame(width: 60, height: 60)
                    .overlay {
                        Image(systemName: "square.stack")
                            .foregroundStyle(.secondary)
                    }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(album.title)
                    .font(.body)
                    .lineLimit(1)
                
                Text(album.artistName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                if let year = album.releaseYear, let count = album.trackCount {
                    Text("\(year) · \(count)곡")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            
            Spacer()
        }
    }
}

// MARK: - Artist Row

struct ArtistRow: View {
    let artist: ArtistItem
    
    var body: some View {
        HStack(spacing: 12) {
            if let artwork = artist.artwork {
                ArtworkImage(artwork, width: 50)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(.tertiary)
                    .frame(width: 50, height: 50)
                    .overlay {
                        Image(systemName: "person.fill")
                            .foregroundStyle(.secondary)
                    }
            }
            
            Text(artist.name)
                .font(.body)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }
}

#Preview {
    SearchView()
        .environmentObject(MusicService.shared)
        .environmentObject(PlayerManager.shared)
}
