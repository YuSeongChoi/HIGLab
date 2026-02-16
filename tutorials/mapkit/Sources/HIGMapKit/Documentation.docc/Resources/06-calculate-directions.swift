import MapKit

extension DirectionsService {
    /// 경로 계산 실행
    func calculateRoute(
        from source: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D,
        transportType: MKDirectionsTransportType = .walking
    ) async throws -> [MKRoute] {
        
        let request = createRequest(
            from: source,
            to: destination,
            transportType: transportType
        )
        
        // MKDirections 인스턴스 생성
        let directions = MKDirections(request: request)
        
        // 경로 계산 (async/await)
        let response = try await directions.calculate()
        
        // 여러 대안 경로가 반환될 수 있음
        return response.routes
    }
}

// 사용 예시:
// Task {
//     let routes = try await service.calculateRoute(
//         from: 현재위치,
//         to: 맛집위치,
//         transportType: .walking
//     )
//     let bestRoute = routes.first  // 가장 빠른 경로
// }
