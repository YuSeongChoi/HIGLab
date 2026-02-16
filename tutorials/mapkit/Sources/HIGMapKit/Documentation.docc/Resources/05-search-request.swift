import MapKit

/// MKLocalSearch 검색 요청 생성
func createSearchRequest(
    query: String,
    region: MKCoordinateRegion
) -> MKLocalSearch.Request {
    
    let request = MKLocalSearch.Request()
    
    // 검색어 설정
    request.naturalLanguageQuery = query  // 예: "맛집", "카페"
    
    // 검색 영역 설정
    request.region = region
    
    // 결과 타입 설정 (POI만 반환)
    request.resultTypes = .pointOfInterest
    
    return request
}

// 사용 예시:
// let region = MKCoordinateRegion(
//     center: 강남역좌표,
//     span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
// )
// let request = createSearchRequest(query: "한식", region: region)
