import PermissionKit
import CoreLocation
import SwiftUI

// 'When In Use' 위치 권한 요청
@Observable
final class WhenInUseLocationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var currentLocation: CLLocation?
    var errorMessage: String?
    
    override init() {
        super.init()
        locationManager.delegate = self
        authorizationStatus = locationManager.authorizationStatus
    }
    
    /// 'When In Use' 권한 요청
    func requestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// 현재 위치 가져오기
    func requestCurrentLocation() {
        guard authorizationStatus == .authorizedWhenInUse ||
              authorizationStatus == .authorizedAlways else {
            errorMessage = "위치 권한이 필요합니다"
            return
        }
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
        errorMessage = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = error.localizedDescription
    }
}

// When In Use 권한 요청 뷰
struct WhenInUseLocationView: View {
    @State private var locationManager = WhenInUseLocationManager()
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "location.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
            
            Text("현재 위치 찾기")
                .font(.title2.bold())
            
            statusView
            
            actionButton
            
            if let location = locationManager.currentLocation {
                VStack {
                    Text("현재 위치")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("위도: \(location.coordinate.latitude, specifier: "%.4f")")
                    Text("경도: \(location.coordinate.longitude, specifier: "%.4f")")
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
    }
    
    @ViewBuilder
    private var statusView: some View {
        let state = LocationPermissionState.from(locationManager.authorizationStatus)
        
        Label(state.description, systemImage: state.icon)
            .foregroundStyle(state.color)
    }
    
    @ViewBuilder
    private var actionButton: some View {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            Button("위치 권한 허용") {
                locationManager.requestWhenInUseAuthorization()
            }
            .buttonStyle(.borderedProminent)
            
        case .authorizedWhenInUse, .authorizedAlways:
            Button("현재 위치 가져오기") {
                locationManager.requestCurrentLocation()
            }
            .buttonStyle(.bordered)
            
        default:
            Button("설정에서 권한 변경") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.bordered)
        }
    }
}

// iOS 26 PermissionKit - HIG Lab
