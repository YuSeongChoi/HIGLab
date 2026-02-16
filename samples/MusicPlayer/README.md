# MusicPlayer

MusicKit 기반 Apple Music 연동 플레이어 샘플 프로젝트입니다.

## 📱 기능

- **검색**: Apple Music 카탈로그에서 노래, 앨범, 아티스트 검색
- **보관함**: 사용자 라이브러리 및 최근 재생 목록
- **Now Playing**: 전체 화면 재생 UI (아트워크, 진행바, 컨트롤)
- **미니 플레이어**: 탭 전환 시에도 유지되는 하단 미니 플레이어

## 🔧 프로젝트 설정

### 1. Apple Developer 설정

1. [Apple Developer Console](https://developer.apple.com/account) 접속
2. **Certificates, Identifiers & Profiles** → **Identifiers**
3. App ID 생성 또는 선택
4. **Capabilities** 섹션에서 **MusicKit** 활성화
5. **App Services** 섹션에서 **MusicKit** 체크

### 2. Xcode 프로젝트 설정

#### Signing & Capabilities

1. Xcode에서 프로젝트 열기
2. 타겟 선택 → **Signing & Capabilities** 탭
3. **+ Capability** 버튼 클릭
4. **MusicKit** 추가

#### Info.plist

다음 키를 `Info.plist`에 추가:

```xml
<key>NSAppleMusicUsageDescription</key>
<string>음악을 재생하고 보관함에 접근하기 위해 Apple Music 권한이 필요합니다.</string>
```

### 3. Entitlements (자동 생성)

MusicKit capability 추가 시 자동으로 생성됨:

```xml
<key>com.apple.developer.musickit</key>
<true/>
```

## 📁 파일 구조

```
MusicPlayer/
├── Shared/
│   ├── MusicItem.swift       # Song, Album, Artist 모델 래퍼
│   ├── MusicService.swift    # MusicKit API 서비스
│   └── PlayerManager.swift   # ApplicationMusicPlayer 제어
│
├── MusicPlayerApp/
│   ├── MusicPlayerApp.swift  # @main, 권한 요청
│   ├── ContentView.swift     # 탭뷰 (검색, 라이브러리, Now Playing)
│   ├── SearchView.swift      # MusicCatalogSearchRequest
│   ├── NowPlayingView.swift  # 현재 재생 UI
│   ├── LibraryView.swift     # 사용자 라이브러리
│   └── MiniPlayerView.swift  # 하단 미니 플레이어
│
└── README.md
```

## 🎵 MusicKit API 사용

### 권한 요청

```swift
let status = await MusicAuthorization.request()
```

### 카탈로그 검색

```swift
var request = MusicCatalogSearchRequest(term: "IVE", types: [Song.self])
request.limit = 25
let response = try await request.response()
```

### 라이브러리 조회

```swift
var request = MusicLibraryRequest<Song>()
request.sort(by: \.dateAdded, ascending: false)
let response = try await request.response()
```

### 재생 제어

```swift
let player = ApplicationMusicPlayer.shared
player.queue = [song]
try await player.play()

// 컨트롤
player.pause()
try await player.skipToNextEntry()
```

## 📋 요구 사항

- iOS 16.0+
- Xcode 15.0+
- Apple Music 구독 (일부 기능)
- Apple Developer Program 멤버십

## ⚠️ 주의사항

1. **시뮬레이터 제한**: MusicKit은 시뮬레이터에서 제한적으로 동작합니다. 실제 기기에서 테스트하세요.
2. **구독 필요**: 전체 곡 재생은 Apple Music 구독이 필요합니다.
3. **프로비저닝**: MusicKit capability는 유료 개발자 계정이 필요합니다.

## 📚 HIG 가이드라인 참고

- [Apple Music 통합 가이드](https://developer.apple.com/documentation/musickit)
- [Now Playing UI 디자인](https://developer.apple.com/design/human-interface-guidelines/playing-audio)
- [미디어 재생 컨트롤](https://developer.apple.com/design/human-interface-guidelines/playing-audio#Media-playback-controls)

## 📄 라이선스

이 샘플 코드는 HIG Lab 학습 목적으로 제공됩니다.
