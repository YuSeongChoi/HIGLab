import MusicKit

// MusicAuthorization.Status - 4가지 상태

func describeAuthorizationStatus(_ status: MusicAuthorization.Status) {
    switch status {
    case .notDetermined:
        // 아직 권한을 요청하지 않은 상태
        // request()를 호출하면 시스템 다이얼로그 표시
        print("권한을 요청해야 합니다")
        
    case .authorized:
        // 사용자가 권한을 허용함
        // 라이브러리 접근 및 재생 가능
        print("권한이 허용되었습니다")
        
    case .denied:
        // 사용자가 권한을 거부함
        // 설정 앱에서만 변경 가능
        print("권한이 거부되었습니다")
        
    case .restricted:
        // 시스템 수준에서 제한됨 (자녀 보호 등)
        // 사용자가 변경할 수 없음
        print("시스템에서 제한되었습니다")
        
    @unknown default:
        print("알 수 없는 상태")
    }
}
