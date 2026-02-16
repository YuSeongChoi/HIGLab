import SwiftUI
import MusicKit

// 검색 상태 관리

enum SearchState {
    case idle
    case loading
    case success([Song])
    case empty
    case error(String)
}

@Observable
class StatefulSearchViewModel {
    var searchText = ""
    var state: SearchState = .idle
    
    func search() async {
        guard !searchText.isEmpty else {
            state = .idle
            return
        }
        
        state = .loading
        
        do {
            var request = MusicCatalogSearchRequest(
                term: searchText,
                types: [Song.self]
            )
            request.limit = 25
            
            let response = try await request.response()
            let songs = Array(response.songs)
            
            state = songs.isEmpty ? .empty : .success(songs)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}

// 상태별 UI
struct SearchContentView: View {
    @State private var viewModel = StatefulSearchViewModel()
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .idle:
                IdleSearchView()
                
            case .loading:
                LoadingView()
                
            case .success(let songs):
                SongListView(songs: songs)
                
            case .empty:
                EmptySearchResultView(query: viewModel.searchText)
                
            case .error(let message):
                SearchErrorView(message: message) {
                    Task { await viewModel.search() }
                }
            }
        }
    }
}

struct IdleSearchView: View {
    var body: some View {
        ContentUnavailableView(
            "음악 검색",
            systemImage: "magnifyingglass",
            description: Text("검색어를 입력하세요")
        )
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("검색 중...")
                .foregroundStyle(.secondary)
        }
    }
}

struct SongListView: View {
    let songs: [Song]
    
    var body: some View {
        List(songs, id: \.id) { song in
            Text(song.title)
        }
    }
}

struct EmptySearchResultView: View {
    let query: String
    
    var body: some View {
        ContentUnavailableView(
            "결과 없음",
            systemImage: "music.note",
            description: Text("'\(query)'에 대한 결과가 없습니다.")
        )
    }
}

struct SearchErrorView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        ContentUnavailableView {
            Label("오류 발생", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("다시 시도", action: onRetry)
                .buttonStyle(.bordered)
        }
    }
}
