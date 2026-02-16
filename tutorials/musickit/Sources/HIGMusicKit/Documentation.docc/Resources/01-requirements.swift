import MusicKit

// MusicKit 사용을 위한 필수 조건

/*
 1. Apple Developer Program 멤버십
    - App ID에서 MusicKit 서비스 활성화 필요
 
 2. Xcode 프로젝트 설정
    - Signing & Capabilities에서 "MusicKit" 추가
    - Info.plist에 NSAppleMusicUsageDescription 추가
 
 3. 재생 기능 사용 시
    - 실제 iOS 디바이스 필요 (시뮬레이터 불가)
    - Apple Music 구독 필요
 
 시뮬레이터에서 가능한 것:
 - 카탈로그 검색 ✅
 - API 응답 확인 ✅
 - UI 레이아웃 테스트 ✅
 
 시뮬레이터에서 불가능한 것:
 - 실제 음악 재생 ❌
 - Apple Music 구독 확인 ❌
 */

func checkSimulatorLimitations() {
    #if targetEnvironment(simulator)
    print("⚠️ 시뮬레이터에서는 음악 재생이 불가능합니다.")
    print("실제 디바이스에서 테스트하세요.")
    #endif
}
