import SwiftUI
import MapKit

struct MapView: View {
    @State private var position: MapCameraPosition = .automatic
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Map(position: $position) {
                UserAnnotation()
            }
            
            // 현재 위치로 이동 버튼
            VStack {
                Button {
                    moveToUserLocation()
                } label: {
                    Image(systemName: "location.fill")
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                
                // 방향까지 추적하는 버튼
                Button {
                    followUserWithHeading()
                } label: {
                    Image(systemName: "location.north.line.fill")
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
            }
            .padding()
        }
    }
    
    private func moveToUserLocation() {
        withAnimation(.easeInOut) {
            // 사용자 위치 중심으로 이동
            position = .userLocation(fallback: .automatic)
        }
    }
    
    private func followUserWithHeading() {
        withAnimation(.easeInOut) {
            // 사용자 위치 + 방향 추적
            position = .userLocation(
                followsHeading: true,  // 사용자가 향하는 방향으로 지도 회전
                fallback: .automatic
            )
        }
    }
}
