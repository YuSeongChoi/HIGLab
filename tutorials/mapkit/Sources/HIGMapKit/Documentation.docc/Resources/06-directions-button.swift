import SwiftUI
import MapKit

struct RestaurantDetailView: View {
    let restaurant: Restaurant
    @StateObject private var directionsService = DirectionsServiceViewModel()
    @State private var userLocation: CLLocationCoordinate2D?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 맛집 정보
            Text(restaurant.name)
                .font(.title)
                .fontWeight(.bold)
            
            // 길찾기 버튼
            Button {
                calculateDirections()
            } label: {
                Label("길찾기", systemImage: "arrow.triangle.turn.up.right.diamond")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(userLocation == nil)
            
            // 경로 정보 표시
            if let routeInfo = directionsService.routeInfo {
                RouteInfoCard(info: routeInfo)
            }
            
            if directionsService.isCalculating {
                ProgressView("경로 계산 중...")
            }
        }
        .padding()
        .task {
            // 현재 위치 가져오기 (LocationManager 사용)
            userLocation = await getCurrentLocation()
        }
    }
    
    private func calculateDirections() {
        guard let source = userLocation else { return }
        
        Task {
            await directionsService.calculate(
                from: source,
                to: restaurant.coordinate
            )
        }
    }
    
    private func getCurrentLocation() async -> CLLocationCoordinate2D? {
        // LocationManager에서 현재 위치 반환
        CLLocationCoordinate2D(latitude: 37.4979, longitude: 127.0276)  // 테스트용
    }
}
