import MusicKit
import AVFoundation
import MediaPlayer

// 프레임워크별 용도

// ✅ MusicKit - Apple Music 스트리밍
// - Apple Music 구독 콘텐츠 재생
// - 카탈로그 검색 및 라이브러리 접근
// - async/await 네이티브 지원
let musicKitPlayer = ApplicationMusicPlayer.shared

// ✅ AVFoundation - 로컬 오디오 파일
// - 앱 번들 또는 문서 디렉토리의 오디오
// - 세밀한 오디오 제어 필요 시
let avPlayer = AVPlayer(url: URL(string: "file://...")!)

// ⚠️ MediaPlayer - 레거시 (사용 지양)
// - 이전 iOS 버전과의 호환성 필요 시에만
// - 시스템 음악 앱 제어
let systemPlayer = MPMusicPlayerController.systemMusicPlayer
