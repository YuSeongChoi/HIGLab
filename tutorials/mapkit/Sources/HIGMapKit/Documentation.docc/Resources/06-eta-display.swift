import SwiftUI
import MapKit

struct RestaurantDetailView: View {
    let restaurant: Restaurant
    @State private var walkingETA: String?
    @State private var drivingETA: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(restaurant.name)
                .font(.title)
            
            // 예상 시간 표시
            HStack(spacing: 20) {
                if let walkingETA {
                    ETABadge(
                        icon: "figure.walk",
                        time: walkingETA,
                        color: .blue
                    )
                }
                
                if let drivingETA {
                    ETABadge(
                        icon: "car.fill",
                        time: drivingETA,
                        color: .green
                    )
                }
            }
            
            Spacer()
        }
        .padding()
        .task {
            await loadETAs()
        }
    }
    
    private func loadETAs() async {
        let service = DirectionsService()
        let source = CLLocationCoordinate2D(latitude: 37.4979, longitude: 127.0276)
        
        // 도보 경로
        if let walkingRoutes = try? await service.calculateRoute(
            from: source,
            to: restaurant.coordinate,
            transportType: .walking
        ), let route = walkingRoutes.first {
            let info = service.routeInfo(from: route)
            walkingETA = info.formattedTime
        }
        
        // 차량 경로
        if let drivingRoutes = try? await service.calculateRoute(
            from: source,
            to: restaurant.coordinate,
            transportType: .automobile
        ), let route = drivingRoutes.first {
            let info = service.routeInfo(from: route)
            drivingETA = info.formattedTime
        }
    }
}

struct ETABadge: View {
    let icon: String
    let time: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(time)
        }
        .font(.subheadline)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .foregroundStyle(color)
        .cornerRadius(8)
    }
}
