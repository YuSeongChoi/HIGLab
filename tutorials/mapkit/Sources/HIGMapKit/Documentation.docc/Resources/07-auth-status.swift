import SwiftUI
import CoreLocation

struct LocationStatusView: View {
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        VStack(spacing: 20) {
            switch locationManager.authorizationStatus {
            case .notDetermined:
                // 아직 결정 안 됨 → 권한 요청
                Text("위치 권한이 필요합니다")
                Button("위치 권한 허용") {
                    locationManager.requestAuthorization()
                }
                .buttonStyle(.borderedProminent)
                
            case .restricted:
                // 제한됨 (자녀 보호 등)
                Text("위치 서비스가 제한되어 있습니다")
                    .foregroundStyle(.secondary)
                
            case .denied:
                // 거부됨 → 설정으로 안내
                Text("위치 권한이 거부되었습니다")
                Button("설정에서 권한 변경") {
                    openSettings()
                }
                .buttonStyle(.bordered)
                
            case .authorizedWhenInUse, .authorizedAlways:
                // 허용됨 → 정상 사용
                Text("위치 권한 허용됨 ✓")
                    .foregroundStyle(.green)
                
                if let location = locationManager.location {
                    Text("현재 위치: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                        .font(.caption)
                }
                
            @unknown default:
                Text("알 수 없는 상태")
            }
        }
        .padding()
    }
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
