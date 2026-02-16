import MusicKit

// 검색 옵션 설정 - limit, offset

class MusicSearchManager {
    private var currentOffset = 0
    private let pageSize = 25
    private var searchTerm = ""
    
    // 첫 페이지 검색
    func search(term: String) async throws -> [Song] {
        searchTerm = term
        currentOffset = 0
        return try await fetchPage()
    }
    
    // 다음 페이지 로드
    func loadMore() async throws -> [Song] {
        currentOffset += pageSize
        return try await fetchPage()
    }
    
    private func fetchPage() async throws -> [Song] {
        var request = MusicCatalogSearchRequest(
            term: searchTerm,
            types: [Song.self]
        )
        
        // 페이지네이션 옵션
        request.limit = pageSize
        request.offset = currentOffset
        
        let response = try await request.response()
        return Array(response.songs)
    }
    
    // 결과가 더 있는지 확인
    var hasMore: Bool {
        // Apple Music은 보통 최대 결과 수가 있음
        // 실제로는 응답의 결과 수로 판단
        true
    }
}
