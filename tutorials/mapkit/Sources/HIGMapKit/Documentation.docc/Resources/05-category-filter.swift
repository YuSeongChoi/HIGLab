import MapKit

extension SearchService {
    /// 카테고리 기반 검색
    func searchByCategory(
        category: MKPointOfInterestCategory,
        region: MKCoordinateRegion
    ) async throws -> [MKMapItem] {
        
        let request = MKLocalSearch.Request()
        request.region = region
        request.resultTypes = .pointOfInterest
        
        // 특정 카테고리만 포함
        request.pointOfInterestFilter = MKPointOfInterestFilter(
            including: [category]
        )
        
        let search = MKLocalSearch(request: request)
        let response = try await search.start()
        
        return response.mapItems
    }
}

// 음식 관련 카테고리:
// .restaurant   - 레스토랑
// .cafe         - 카페
// .bakery       - 베이커리
// .brewery      - 양조장/맥주집
// .winery       - 와이너리
// .foodMarket   - 식품점
// .nightlife    - 나이트라이프
