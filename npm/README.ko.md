# higlab-skill

> Apple 프레임워크 개발을 위한 공식 Claude Code 스킬 — [HIG Lab](https://m1zz.github.io/HIGLab/) 제공

Claude Code에서 `/hig` 명령어로 50개 Apple 프레임워크 AI Reference에 바로 접근하세요.

## 설치

```bash
npm install -g higlab-skill
```

설치 시 `/hig` 명령어가 `~/.claude/commands/hig.md`에 자동 복사됩니다.

## 사용법

Claude Code에서:

```
/hig storekit      # StoreKit 2 레퍼런스 로드
/hig 인앱결제       # 한국어 키워드 매칭
/hig list          # 전체 50개 프레임워크 목록
```

## 지원 프레임워크 (50개)

| 카테고리 | 프레임워크 |
|---------|-----------|
| **UI & 데이터** | SwiftUI, Observation, SwiftData |
| **위젯 & 활동** | WidgetKit, ActivityKit |
| **AI & 인텐트** | Foundation Models, App Intents, Visual Intelligence |
| **팁 & 결제** | TipKit, StoreKit 2, PassKit |
| **클라우드 & 인증** | CloudKit, Auth Services, LocalAuthentication, CryptoKit |
| **건강 & 위치** | HealthKit, MapKit, Core Location |
| **ML & 비전** | Core ML, Vision |
| **알림 & 소셜** | User Notifications, SharePlay |
| **PIM** | EventKit, Contacts, MusicKit, WeatherKit |
| **AR & 그래픽** | ARKit, RealityKit, SpriteKit, Core Image, PencilKit, PDFKit |
| **미디어** | AVFoundation, AVKit, PhotosUI, Core Haptics, ShazamKit, Image Playground |
| **연결** | Core Bluetooth, Core NFC, MultipeerConnectivity, Network, CallKit, Wi-Fi Aware |
| **시스템** | AlarmKit, EnergyKit, PermissionKit, RelevanceKit, AccessorySetupKit, ExtensibleImage |

## 제거

```bash
higlab-skill-uninstall
npm uninstall -g higlab-skill
```

## CLAUDE.md 연동

`/hig` 명령어 없이 자동으로 프레임워크를 감지하려면 `claude-md-snippet.md`의 내용을 프로젝트의 `CLAUDE.md`에 붙여넣으세요.

## 링크

- [HIG Lab](https://m1zz.github.io/HIGLab/) — 전체 레퍼런스 둘러보기
- [GitHub](https://github.com/M1zz/HIGLab)
- [English README](./README.md)

## 라이선스

MIT © [M1zz](https://github.com/M1zz)
