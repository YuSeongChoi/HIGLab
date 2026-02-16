import MapKit

extension SearchService {
    /// 여러 음식점 카테고리 동시 검색
    func searchFoodPlaces(region: MKCoordinateRegion) async throws -> [MKMapItem] {
        let request = MKLocalSearch.Request()
        request.region = region
        request.resultTypes = .pointOfInterest
        
        // 음식 관련 모든 카테고리 포함
        let foodCategories: [MKPointOfInterestCategory] = [
            .restaurant,
            .cafe,
            .bakery,
            .brewery,
            .winery,
            .foodMarket
        ]
        
        request.pointOfInterestFilter = MKPointOfInterestFilter(
            including: foodCategories
        )
        
        let search = MKLocalSearch(request: request)
        let response = try await search.start()
        
        return response.mapItems
    }
    
    /// 특정 카테고리 제외 검색
    func searchExcluding(
        categories: [MKPointOfInterestCategory],
        region: MKCoordinateRegion
    ) async throws -> [MKMapItem] {
        
        let request = MKLocalSearch.Request()
        request.region = region
        request.resultTypes = .pointOfInterest
        
        // 특정 카테고리 제외
        request.pointOfInterestFilter = MKPointOfInterestFilter(
            excluding: categories
        )
        
        let search = MKLocalSearch(request: request)
        let response = try await search.start()
        
        return response.mapItems
    }
}
