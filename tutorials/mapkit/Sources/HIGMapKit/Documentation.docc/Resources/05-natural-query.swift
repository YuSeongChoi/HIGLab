import MapKit

extension SearchService {
    /// 자연어 쿼리 + 카테고리 필터 조합
    func searchWithQuery(
        query: String,          // 예: "이탈리안", "비건"
        categories: [MKPointOfInterestCategory],
        region: MKCoordinateRegion
    ) async throws -> [MKMapItem] {
        
        let request = MKLocalSearch.Request()
        
        // 자연어 검색어
        request.naturalLanguageQuery = query
        
        // 검색 영역
        request.region = region
        
        // POI만 반환
        request.resultTypes = .pointOfInterest
        
        // 카테고리 필터 (선택적)
        if !categories.isEmpty {
            request.pointOfInterestFilter = MKPointOfInterestFilter(
                including: categories
            )
        }
        
        let search = MKLocalSearch(request: request)
        let response = try await search.start()
        
        return response.mapItems
    }
}

// 검색 예시:
// "이탈리안 레스토랑" + .restaurant → 이탈리안 음식점
// "비건 카페" + .cafe → 비건 카페
// "삼겹살" + [.restaurant] → 삼겹살집
