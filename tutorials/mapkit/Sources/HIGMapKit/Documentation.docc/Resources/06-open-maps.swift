import SwiftUI
import MapKit

struct RestaurantDetailView: View {
    let restaurant: Restaurant
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(restaurant.name)
                .font(.title)
            
            // Apple Maps로 길찾기 시작
            Button {
                openInMaps()
            } label: {
                Label("Apple Maps에서 길찾기", systemImage: "map.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            
            // 이동 수단별 버튼
            HStack {
                Button("도보") {
                    openInMaps(transportType: .walking)
                }
                .buttonStyle(.bordered)
                
                Button("차량") {
                    openInMaps(transportType: .automobile)
                }
                .buttonStyle(.bordered)
                
                Button("대중교통") {
                    openInMaps(transportType: .transit)
                }
                .buttonStyle(.bordered)
            }
            
            Spacer()
        }
        .padding()
    }
    
    /// Apple Maps 앱으로 열기
    private func openInMaps(transportType: MKDirectionsTransportType = .automobile) {
        let destination = MKMapItem(
            placemark: MKPlacemark(coordinate: restaurant.coordinate)
        )
        destination.name = restaurant.name
        
        // 현재 위치에서 목적지까지 경로 안내 시작
        destination.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: directionsMode(for: transportType)
        ])
    }
    
    private func directionsMode(for type: MKDirectionsTransportType) -> String {
        switch type {
        case .walking:
            return MKLaunchOptionsDirectionsModeWalking
        case .transit:
            return MKLaunchOptionsDirectionsModeTransit
        default:
            return MKLaunchOptionsDirectionsModeDriving
        }
    }
}
