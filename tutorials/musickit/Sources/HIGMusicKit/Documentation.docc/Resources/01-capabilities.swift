// Xcode Capability 설정

/*
 1. Xcode에서 프로젝트 선택
 
 2. TARGETS에서 앱 타겟 선택
 
 3. "Signing & Capabilities" 탭 클릭
 
 4. "+ Capability" 버튼 클릭
 
 5. "MusicKit" 검색 후 추가
 
 ⚠️ MusicKit capability가 없으면:
 - MusicKit API 호출 시 에러 발생
 - MusicKitError.notConfigured
 
 💡 Background Modes (선택사항):
 - 백그라운드에서 재생을 계속하려면
 - "Audio, AirPlay, and Picture in Picture" 체크
 */

// MusicKit이 설정되지 않았을 때의 에러 처리
import MusicKit

func handleMusicKitError(_ error: Error) {
    if let musicError = error as? MusicKitError {
        switch musicError {
        case .notConfigured:
            print("⚠️ MusicKit capability를 추가하세요")
        default:
            print("MusicKit 에러: \(musicError)")
        }
    }
}
