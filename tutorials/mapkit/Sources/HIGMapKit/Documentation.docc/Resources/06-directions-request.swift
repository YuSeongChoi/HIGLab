import MapKit

class DirectionsService {
    /// 경로 요청 생성
    func createRequest(
        from source: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D,
        transportType: MKDirectionsTransportType = .walking
    ) -> MKDirections.Request {
        
        let request = MKDirections.Request()
        
        // 출발지 설정
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: source))
        
        // 목적지 설정
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        
        // 이동 수단 설정
        request.transportType = transportType
        // .automobile - 자동차
        // .walking    - 도보
        // .transit    - 대중교통
        // .any        - 모든 수단
        
        // 대안 경로 요청
        request.requestsAlternateRoutes = true
        
        return request
    }
}
