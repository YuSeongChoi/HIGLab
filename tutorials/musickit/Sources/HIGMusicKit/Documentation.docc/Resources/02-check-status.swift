import MusicKit

// MusicAuthorization.currentStatus - 현재 상태 확인

// 다이얼로그를 표시하지 않고 현재 상태만 확인
let currentStatus = MusicAuthorization.currentStatus

// 앱 시작 시 상태 확인
func checkAuthorizationOnLaunch() {
    let status = MusicAuthorization.currentStatus
    
    switch status {
    case .notDetermined:
        // 권한 요청 화면 표시
        showAuthorizationScreen()
        
    case .authorized:
        // 바로 메인 화면으로
        showMainScreen()
        
    case .denied, .restricted:
        // 안내 화면 표시
        showPermissionRequiredScreen()
        
    @unknown default:
        break
    }
}

// 플레이스홀더 함수들
func showAuthorizationScreen() {}
func showMainScreen() {}
func showPermissionRequiredScreen() {}
