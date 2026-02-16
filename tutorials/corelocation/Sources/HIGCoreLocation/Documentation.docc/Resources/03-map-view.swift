import SwiftUI
import MapKit

/// 현재 위치를 표시하는 지도 뷰
struct RunMapView: View {
    @EnvironmentObject var locationManager: LocationManager
    
    /// 지도 카메라 위치
    @State private var position: MapCameraPosition = .automatic
    
    var body: some View {
        Map(position: $position) {
            // 현재 위치 마커
            if let location = locationManager.currentLocation {
                Annotation("현재 위치", coordinate: location.coordinate) {
                    ZStack {
                        Circle()
                            .fill(.blue.opacity(0.3))
                            .frame(width: 50, height: 50)
                        
                        Circle()
                            .fill(.blue)
                            .frame(width: 20, height: 20)
                        
                        Circle()
                            .fill(.white)
                            .frame(width: 10, height: 10)
                    }
                }
            }
        }
        .mapStyle(.standard)
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
        .onAppear {
            // 현재 위치로 카메라 이동
            if let location = locationManager.currentLocation {
                position = .camera(MapCamera(
                    centerCoordinate: location.coordinate,
                    distance: 1000  // 1km 거리에서 보기
                ))
            }
        }
        .onChange(of: locationManager.currentLocation) { oldValue, newValue in
            // 위치가 변경되면 카메라 업데이트
            if let location = newValue {
                withAnimation {
                    position = .camera(MapCamera(
                        centerCoordinate: location.coordinate,
                        distance: 1000
                    ))
                }
            }
        }
    }
}

#Preview {
    RunMapView()
        .environmentObject(LocationManager())
}
