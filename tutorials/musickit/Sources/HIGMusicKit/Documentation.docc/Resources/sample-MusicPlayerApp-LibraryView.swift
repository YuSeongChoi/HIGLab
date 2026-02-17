import SwiftUI
import MusicKit

// MARK: - Library View
// 사용자의 Apple Music 보관함

struct LibraryView: View {
    @EnvironmentObject var musicService: MusicService
    @EnvironmentObject var playerManager: PlayerManager
    
    @State private var selectedSection: LibrarySection = .songs
    @State private var songs: [SongItem] = []
    @State private var albums: [AlbumItem] = []
    @State private var recentlyPlayed: [SongItem] = []
    
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    enum LibrarySection: String, CaseIterable, Identifiable {
        case songs = "노래"
        case albums = "앨범"
        case recentlyPlayed = "최근 재생"
        
        var id: String { rawValue }
        
        var systemImage: String {
            switch self {
            case .songs: return "music.note"
            case .albums: return "square.stack"
            case .recentlyPlayed: return "clock"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 섹션 선택
                Picker("보관함 섹션", selection: $selectedSection) {
                    ForEach(LibrarySection.allCases) { section in
                        Label(section.rawValue, systemImage: section.systemImage)
                            .tag(section)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // 콘텐츠
                Group {
                    if isLoading {
                        ProgressView("불러오는 중...")
                            .frame(maxHeight: .infinity)
                    } else if let error = errorMessage {
                        ContentUnavailableView(
                            "오류 발생",
                            systemImage: "exclamationmark.triangle",
                            description: Text(error)
                        )
                    } else if musicService.authorizationStatus != .authorized {
                        ContentUnavailableView(
                            "보관함 접근 불가",
                            systemImage: "lock.shield",
                            description: Text("Apple Music 권한이 필요합니다.")
                        )
                    } else {
                        libraryContent
                    }
                }
            }
            .navigationTitle("보관함")
            .task {
                await loadLibrary()
            }
            .onChange(of: selectedSection) { _, _ in
                Task {
                    await loadLibrary()
                }
            }
            .refreshable {
                await loadLibrary()
            }
        }
    }
    
    // MARK: - Library Content
    
    @ViewBuilder
    private var libraryContent: some View {
        switch selectedSection {
        case .songs:
            songsList
        case .albums:
            albumsList
        case .recentlyPlayed:
            recentlyPlayedList
        }
    }
    
    // MARK: - Songs List
    
    @ViewBuilder
    private var songsList: some View {
        if songs.isEmpty {
            ContentUnavailableView(
                "보관함에 노래가 없습니다",
                systemImage: "music.note",
                description: Text("Apple Music에서 노래를 추가해보세요.")
            )
        } else {
            List {
                ForEach(songs) { song in
                    SongRow(song: song)
                        .onTapGesture {
                            playSong(song)
                        }
                }
            }
            .listStyle(.plain)
        }
    }
    
    // MARK: - Albums List
    
    @ViewBuilder
    private var albumsList: some View {
        if albums.isEmpty {
            ContentUnavailableView(
                "보관함에 앨범이 없습니다",
                systemImage: "square.stack",
                description: Text("Apple Music에서 앨범을 추가해보세요.")
            )
        } else {
            ScrollView {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ],
                    spacing: 20
                ) {
                    ForEach(albums) { album in
                        AlbumGridItem(album: album)
                    }
                }
                .padding()
            }
        }
    }
    
    // MARK: - Recently Played List
    
    @ViewBuilder
    private var recentlyPlayedList: some View {
        if recentlyPlayed.isEmpty {
            ContentUnavailableView(
                "최근 재생 기록이 없습니다",
                systemImage: "clock",
                description: Text("음악을 재생하면 여기에 표시됩니다.")
            )
        } else {
            List {
                ForEach(recentlyPlayed) { song in
                    SongRow(song: song)
                        .onTapGesture {
                            playSong(song)
                        }
                }
            }
            .listStyle(.plain)
        }
    }
    
    // MARK: - Load Library
    
    private func loadLibrary() async {
        guard musicService.authorizationStatus == .authorized else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            switch selectedSection {
            case .songs:
                songs = try await musicService.fetchLibrarySongs()
            case .albums:
                albums = try await musicService.fetchLibraryAlbums()
            case .recentlyPlayed:
                recentlyPlayed = try await musicService.fetchRecentlyPlayed()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
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

// MARK: - Album Grid Item

struct AlbumGridItem: View {
    let album: AlbumItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 앨범 아트워크
            if let artwork = album.artwork {
                ArtworkImage(artwork, width: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.tertiary)
                    .aspectRatio(1, contentMode: .fit)
                    .overlay {
                        Image(systemName: "square.stack")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                    }
            }
            
            // 앨범 정보
            VStack(alignment: .leading, spacing: 2) {
                Text(album.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(album.artistName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }
}

#Preview {
    LibraryView()
        .environmentObject(MusicService.shared)
        .environmentObject(PlayerManager.shared)
}
