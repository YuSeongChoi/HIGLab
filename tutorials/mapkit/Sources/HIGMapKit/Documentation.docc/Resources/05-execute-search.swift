import MapKit

class SearchService {
    /// 검색 실행
    func search(query: String, region: MKCoordinateRegion) async throws -> [MKMapItem] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = region
        request.resultTypes = .pointOfInterest
        
        // MKLocalSearch 인스턴스 생성
        let search = MKLocalSearch(request: request)
        
        // async/await로 검색 실행
        let response = try await search.start()
        
        // 결과 반환
        return response.mapItems
    }
}

// 사용 예시:
// Task {
//     let service = SearchService()
//     let items = try await service.search(query: "맛집", region: currentRegion)
//     print("검색 결과: \(items.count)개")
// }
