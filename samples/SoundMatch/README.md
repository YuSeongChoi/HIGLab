# SoundMatch

ShazamKit을 활용한 음악 인식 앱 샘플 프로젝트입니다.

## 주요 기능

- **음악 인식**: 주변에서 재생되는 음악을 실시간으로 인식
- **인식 기록**: 인식된 곡들의 히스토리 관리
- **Apple Music 연동**: 인식된 곡을 Apple Music에서 바로 재생

## 기술 스택

- **ShazamKit**: `SHManagedSession`을 사용한 간편한 음악 인식
- **SwiftUI**: 선언적 UI 및 애니메이션
- **@Observable**: Swift 5.9 Observation 매크로
- **async/await**: 비동기 스트림 처리

## 파일 구조

```
SoundMatch/
├── Shared/
│   ├── MatchedSong.swift      # 인식된 곡 모델
│   ├── ShazamManager.swift    # SHManagedSession 관리자
│   └── MatchHistory.swift     # 인식 기록 관리
│
├── SoundMatchApp/
│   ├── SoundMatchApp.swift    # 앱 진입점
│   ├── ContentView.swift      # 메인 화면 (탭 뷰)
│   ├── ListeningView.swift    # 듣기 애니메이션
│   ├── MatchResultView.swift  # 인식 결과 표시
│   ├── HistoryView.swift      # 기록 목록
│   └── SongDetailView.swift   # 곡 상세 정보
│
└── README.md
```

## 핵심 구현

### SHManagedSession 사용

```swift
// 세션 생성 및 결과 스트림 처리
session = SHManagedSession()

for await result in session.results {
    switch result {
    case .match(let match):
        // 매칭 성공
    case .noMatch:
        // 매칭 실패
    case .error(let error):
        // 오류 처리
    }
}
```

### @Observable 매크로

```swift
@Observable
final class ShazamManager {
    private(set) var state: State = .idle
    private(set) var matchedSong: MatchedSong?
}
```

## 필요 권한

### Info.plist

```xml
<key>NSMicrophoneUsageDescription</key>
<string>음악을 인식하기 위해 마이크 접근이 필요합니다.</string>
```

### Capabilities

- **ShazamKit**: Xcode에서 ShazamKit capability 추가 필요

## 실행 요구사항

- iOS 18.0+ / macOS 15.0+
- Xcode 16.0+
- Apple Developer 계정 (ShazamKit 사용)

## 사용 방법

1. 앱을 실행합니다
2. 중앙의 Shazam 버튼을 탭합니다
3. 마이크 권한을 허용합니다
4. 인식하고 싶은 음악을 재생합니다
5. 인식이 완료되면 결과가 표시됩니다
6. "기록" 탭에서 이전에 인식한 곡들을 확인할 수 있습니다

## 라이선스

MIT License
