import SwiftUI
import MusicKit

struct SearchView: View {
    @State private var viewModel = SearchViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                if viewModel.isLoading {
                    HStack {
                        Spacer()
                        ProgressView("검색 중...")
                        Spacer()
                    }
                } else if let error = viewModel.errorMessage {
                    ErrorRow(message: error) {
                        viewModel.search()
                    }
                } else if viewModel.songs.isEmpty && !viewModel.searchText.isEmpty {
                    ContentUnavailableView(
                        "검색 결과 없음",
                        systemImage: "magnifyingglass",
                        description: Text("'\(viewModel.searchText)'에 대한 결과가 없습니다.")
                    )
                } else {
                    ForEach(viewModel.songs, id: \.id) { song in
                        SongRow(song: song) {
                            playSong(song)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("검색")
            .searchable(
                text: $viewModel.searchText,
                prompt: "노래, 아티스트, 앨범 검색"
            )
            .onSubmit(of: .search) {
                viewModel.search()
            }
            .onChange(of: viewModel.searchText) { _, _ in
                viewModel.search()
            }
        }
    }
    
    private func playSong(_ song: Song) {
        Task {
            let player = ApplicationMusicPlayer.shared
            player.queue = [song]
            try? await player.play()
        }
    }
}

struct ErrorRow: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Text(message)
                .foregroundStyle(.secondary)
            
            Button("다시 시도", action: onRetry)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}
