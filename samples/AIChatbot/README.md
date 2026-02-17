# AIChatbot

Apple의 **FoundationModels** 프레임워크를 활용한 온디바이스 AI 채팅봇 샘플 앱입니다.

## 요구 사항

- **iOS 26.0+** / macOS 26.0+
- Xcode 26.0+
- Apple Silicon Mac 또는 A17 Pro 이상 칩셋 탑재 기기
- Apple Intelligence 활성화 필요

> ⚠️ FoundationModels는 iOS 26에서 새로 도입된 프레임워크입니다. iOS 26 베타 이상이 필요합니다.

## 주요 기능

- 🤖 **온디바이스 AI 채팅**: Apple Intelligence를 활용한 로컬 AI 응답
- 💬 **실시간 스트리밍**: 응답을 실시간으로 스트리밍하여 표시
- 💾 **대화 저장**: 대화 내역 자동 저장 및 복원
- ⚙️ **커스텀 시스템 프롬프트**: AI 성격 커스터마이징 지원

## 프로젝트 구조

```
AIChatbot/
├── Shared/
│   ├── Message.swift           # 채팅 메시지 모델
│   ├── ChatManager.swift       # LanguageModel 래퍼
│   └── ConversationStore.swift # 대화 저장소
│
├── AIChatbotApp/
│   ├── AIChatbotApp.swift      # 앱 진입점
│   ├── ContentView.swift       # 메인 채팅 UI
│   ├── MessageBubbleView.swift # 메시지 버블
│   ├── InputBarView.swift      # 입력창
│   └── SettingsView.swift      # 설정 화면
│
└── README.md
```

## 사용된 API

### FoundationModels

```swift
import FoundationModels

// 세션 생성
let session = LanguageModelSession(instructions: "시스템 프롬프트")

// 스트리밍 응답
let stream = session.streamResponse(to: "사용자 메시지")
for try await partial in stream {
    print(partial.outputSoFar)
}
```

### 주요 타입

- `SystemLanguageModel` - 시스템 언어 모델 접근
- `LanguageModelSession` - 대화 세션 관리
- `LanguageModelSession.Availability` - 모델 가용성 상태

## 설치 방법

1. Xcode 26 이상에서 프로젝트 열기
2. 타겟 기기를 iOS 26+ 시뮬레이터 또는 실제 기기로 설정
3. 빌드 및 실행

## 라이선스

MIT License

## 참고 자료

- [FoundationModels Documentation](https://developer.apple.com/documentation/foundationmodels)
- [Apple Intelligence Overview](https://developer.apple.com/apple-intelligence/)
