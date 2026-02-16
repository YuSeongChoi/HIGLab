import SwiftUI
import MapKit
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var searchResults: [Restaurant] = []
    @Published var isSearching = false
    
    private let searchService = SearchService()
    private var searchTask: Task<Void, Never>?
    
    var currentRegion: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.4979, longitude: 127.0276),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    /// 검색 실행 (debounce 적용)
    func search() {
        // 이전 검색 취소
        searchTask?.cancel()
        
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        
        // 300ms debounce
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(300))
            
            guard !Task.isCancelled else { return }
            
            isSearching = true
            defer { isSearching = false }
            
            do {
                let items = try await searchService.search(
                    query: searchText,
                    region: currentRegion
                )
                
                guard !Task.isCancelled else { return }
                
                searchResults = searchService.convertToRestaurants(items)
            } catch {
                print("검색 오류: \(error)")
            }
        }
    }
}
