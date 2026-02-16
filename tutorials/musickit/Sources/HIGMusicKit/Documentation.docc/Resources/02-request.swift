import MusicKit

// MusicAuthorization.request() - 권한 요청

func requestMusicAuthorization() async -> MusicAuthorization.Status {
    // 권한 요청 (시스템 다이얼로그 표시)
    let status = await MusicAuthorization.request()
    
    // 결과 처리
    switch status {
    case .authorized:
        print("✅ 권한이 허용되었습니다")
    case .denied:
        print("❌ 권한이 거부되었습니다")
    case .restricted:
        print("⚠️ 시스템에서 제한되었습니다")
    case .notDetermined:
        print("❓ 아직 결정되지 않았습니다")
    @unknown default:
        break
    }
    
    return status
}

// 사용 예시
func handleMusicAccess() async {
    let status = await requestMusicAuthorization()
    
    if status == .authorized {
        // 음악 기능 사용 가능
        await loadMusic()
    }
}

func loadMusic() async {
    // 음악 로딩 로직
}
