#if canImport(PermissionKit)
import PermissionKit
import MapKit
import SwiftUI

// 위치 권한과 함께 지도 표시
struct LocationMapView: View {
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var locationManager = WhenInUseLocationManager()
    
    var body: some View {
        ZStack {
            if locationManager.authorizationStatus == .authorizedWhenInUse ||
               locationManager.authorizationStatus == .authorizedAlways {
                // 권한 허용됨 - 지도 표시
                Map(position: $position) {
                    UserAnnotation()
                }
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                    MapScaleView()
                }
            } else {
                // 권한 필요 - 안내 화면
                LocationPermissionPrompt(
                    onRequest: {
                        locationManager.requestWhenInUseAuthorization()
                    }
                )
            }
        }
    }
}

// 위치 권한 요청 프롬프트
struct LocationPermissionPrompt: View {
    let onRequest: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "map.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue.gradient)
            
            Text("주변 매장 찾기")
                .font(.title2.bold())
            
            Text("현재 위치 기반으로 가까운 매장을 찾으려면\n위치 권한이 필요합니다.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            
            Button("위치 권한 허용하기", action: onRequest)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
        }
        .padding()
    }
}

// iOS 26 PermissionKit - HIG Lab
#endif
