# 🤖 AIAssistant

온디바이스 AI 어시스턴트 통합 샘플 프로젝트입니다.

## 사용 프레임워크

| 프레임워크 | 용도 |
|-----------|------|
| **SwiftUI** | 선언적 UI |
| **Foundation Models** | 온디바이스 LLM (iOS 26+) |
| **App Intents** | Siri 통합, 단축어 |
| **Core ML** | 커스텀 ML 모델 추론 |
| **Vision** | 이미지 분석, OCR |

## 주요 기능

- 💬 채팅 인터페이스 (Foundation Models)
- 🗣️ Siri 음성 명령 (App Intents)
- 📷 이미지 분석 (Vision + Core ML)
- 📝 텍스트 인식 OCR (Vision)
- ⚡ 단축어 통합 (App Intents)

## 프로젝트 구조

```
AIAssistant/
├── AIAssistantApp.swift        # 앱 진입점
├── Models/
│   ├── Message.swift           # 채팅 메시지 모델
│   └── Conversation.swift      # 대화 모델
├── Views/
│   ├── ChatView.swift          # 채팅 화면
│   ├── ImageAnalysisView.swift # 이미지 분석
│   └── SettingsView.swift      # 설정
├── Managers/
│   ├── AIManager.swift         # Foundation Models 관리
│   ├── VisionManager.swift     # Vision 분석
│   └── MLManager.swift         # Core ML 추론
└── Intents/
    └── ChatIntent.swift        # Siri 통합
```

## 필요 조건

- iOS 26.0+ (Foundation Models)
- Apple Silicon (온디바이스 LLM)

## Info.plist 키

```xml
<key>NSCameraUsageDescription</key>
<string>이미지 분석을 위해 카메라를 사용합니다.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>이미지 분석을 위해 사진에 접근합니다.</string>
```

## 학습 포인트

1. **Foundation Models**: 온디바이스 LLM 스트리밍 응답
2. **App Intents**: Siri와 단축어 통합
3. **Vision**: 이미지 분석 및 OCR
4. **멀티모달 AI**: 텍스트 + 이미지 처리 통합
