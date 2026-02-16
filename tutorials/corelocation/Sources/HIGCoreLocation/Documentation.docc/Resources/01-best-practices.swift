import SwiftUI
import CoreLocation

/// 권한 요청 베스트 프랙티스
struct PermissionBestPractices {
    
    // ❌ 나쁜 예: 앱 시작 시 바로 요청
    // func application(_ application: UIApplication, didFinishLaunchingWithOptions...) {
    //     locationManager.requestWhenInUseAuthorization()  // 사용자가 왜 필요한지 모름
    // }
    
    // ✅ 좋은 예: 기능 사용 시점에 요청
    func startRunningButtonTapped() {
        // 1. 먼저 권한 상태 확인
        let status = CLLocationManager().authorizationStatus
        
        switch status {
        case .notDetermined:
            // 2. 사전 설명 화면 표시 후 권한 요청
            showPermissionExplanation()
        case .denied, .restricted:
            // 3. 설정으로 이동 안내
            showSettingsAlert()
        case .authorizedWhenInUse, .authorizedAlways:
            // 4. 러닝 시작
            startRunning()
        @unknown default:
            break
        }
    }
    
    /// 권한 요청 전 설명 화면
    func showPermissionExplanation() {
        // "러닝 경로를 기록하려면 위치 권한이 필요해요"
        // "허용" 버튼 → requestWhenInUseAuthorization() 호출
    }
    
    /// Always 권한 업그레이드 (단계적 요청)
    func requestBackgroundPermission() {
        let status = CLLocationManager().authorizationStatus
        
        // When In Use 권한이 있을 때만 Always 요청 가능
        guard status == .authorizedWhenInUse else { return }
        
        // 1. 왜 백그라운드 권한이 필요한지 설명
        // 2. 사용자 동의 후 requestAlwaysAuthorization() 호출
    }
    
    func showSettingsAlert() {
        // 설정 앱으로 이동하는 딥링크
        // UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }
    
    func startRunning() {
        // 러닝 추적 시작
    }
}
