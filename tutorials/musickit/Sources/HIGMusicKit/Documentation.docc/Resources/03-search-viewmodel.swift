import SwiftUI
import MusicKit
import Combine

@Observable
class SearchViewModel {
    var searchText = ""
    var songs: [Song] = []
    var isLoading = false
    var errorMessage: String?
    
    private var searchTask: Task<Void, Never>?
    
    func search() {
        // 이전 검색 취소
        searchTask?.cancel()
        
        guard !searchText.isEmpty else {
            songs = []
            return
        }
        
        searchTask = Task {
            await performSearch()
        }
    }
    
    private func performSearch() async {
        isLoading = true
        errorMessage = nil
        
        do {
            var request = MusicCatalogSearchRequest(
                term: searchText,
                types: [Song.self]
            )
            request.limit = 25
            
            let response = try await request.response()
            
            // Task가 취소되지 않았는지 확인
            if !Task.isCancelled {
                songs = Array(response.songs)
            }
        } catch {
            if !Task.isCancelled {
                errorMessage = error.localizedDescription
            }
        }
        
        isLoading = false
    }
}

// Debounce가 적용된 버전
@Observable
class DebouncedSearchViewModel {
    var searchText = "" {
        didSet {
            debounceSearch()
        }
    }
    var songs: [Song] = []
    var isLoading = false
    
    private var searchTask: Task<Void, Never>?
    
    private func debounceSearch() {
        searchTask?.cancel()
        
        searchTask = Task {
            // 300ms 대기
            try? await Task.sleep(for: .milliseconds(300))
            
            if !Task.isCancelled {
                await performSearch()
            }
        }
    }
    
    private func performSearch() async {
        guard !searchText.isEmpty else {
            songs = []
            return
        }
        
        isLoading = true
        
        do {
            var request = MusicCatalogSearchRequest(
                term: searchText,
                types: [Song.self]
            )
            request.limit = 25
            
            let response = try await request.response()
            songs = Array(response.songs)
        } catch {
            // 에러 처리
        }
        
        isLoading = false
    }
}
