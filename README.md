# 🍎 HIG Lab

> **Apple Frameworks를 코드로 실습하는 곳**

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2017+-blue.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Progress](https://img.shields.io/badge/Progress-7%2F50-brightgreen.svg)](https://m1zz.github.io/HIGLab/)

Apple의 **367개 프레임워크**를 실전 중심으로 학습합니다. 각 기술별로 3가지를 제공:

1. **📝 블로그 포스트** — HIG 가이드라인 한글 해설 + 실전 예제
2. **📚 DocC 튜토리얼** — Xcode에서 바로 실습 가능한 step-by-step 가이드  
3. **💻 샘플 프로젝트** — 완성된 SwiftUI 코드

🌐 **라이브 사이트**: [m1zz.github.io/HIGLab](https://m1zz.github.io/HIGLab/)

---

## 📊 진행 상황

**7/50 완료 (14%)**

| Phase | 완료 | 기술 |
|-------|------|------|
| 1 App Frameworks | 4/7 | WidgetKit ✅, ActivityKit ✅, App Intents ✅, Foundation Models ✅ |
| 2 App Services | 1/13 | StoreKit 2 ✅ |
| 3 Graphics & Media | 1/13 | ARKit ✅ |
| 4 System & Network | 1/10 | Core Bluetooth ✅ |
| 5 iOS 26 | 0/7 | - |

---

## 🗺️ 기술 로드맵

### 🚀 Phase 1: App Frameworks (핵심)
> 앱의 뼈대를 구성하는 핵심 프레임워크

| # | Technology | 설명 | 블로그 | DocC | 상태 |
|---|-----------|------|--------|------|------|
| 1 | **WidgetKit** | 홈화면/잠금화면 위젯 | [날씨 위젯](https://m1zz.github.io/HIGLab/widgets/01-weather-widget-challenge.html) | [튜토리얼](https://m1zz.github.io/HIGLab/widgets/documentation/higwidgets/) | ✅ |
| 2 | **ActivityKit** | Live Activities, Dynamic Island | [배달 추적](https://m1zz.github.io/HIGLab/activitykit/01-delivery-tracker.html) | [튜토리얼](https://m1zz.github.io/HIGLab/activitykit/documentation/higactivitykit/) | ✅ |
| 3 | **App Intents** | Siri, 단축어, 위젯 통합 | [Siri 앱](https://m1zz.github.io/HIGLab/appintents/01-siri-todo-app.html) | [튜토리얼](https://m1zz.github.io/HIGLab/appintents/documentation/higappintents/) | ✅ |
| 4 | **SwiftUI** | 선언적 UI 프레임워크 | - | - | 📋 |
| 5 | **SwiftData** | 현대적 데이터 저장 | - | - | 📋 |
| 6 | **Observation** | @Observable 상태관리 | - | - | 📋 |
| 7 | 🆕 **Foundation Models** | 온디바이스 LLM (iOS 26) | [AI 챗봇](https://m1zz.github.io/HIGLab/foundationmodels/01-ai-chatbot.html) | [튜토리얼](https://m1zz.github.io/HIGLab/foundationmodels/documentation/higfoundationmodels/) | ✅ |

### 💳 Phase 2: App Services (서비스 통합)
> 앱의 기능을 시스템과 클라우드로 확장

| # | Technology | 설명 | 블로그 | DocC | 상태 |
|---|-----------|------|--------|------|------|
| 8 | **StoreKit 2** | 인앱결제, 구독 | [구독 앱](https://m1zz.github.io/HIGLab/storekit/01-subscription-app.html) | [튜토리얼](https://m1zz.github.io/HIGLab/storekit/documentation/higstorekit/) | ✅ |
| 9 | **PassKit** | Apple Pay, Wallet | - | - | 📋 |
| 10 | **CloudKit** | iCloud 데이터 동기화 | - | - | 📋 |
| 11 | **Authentication Services** | Sign in with Apple | - | - | 📋 |
| 12 | **HealthKit** | 건강 데이터 | - | - | 📋 |
| 13 | **WeatherKit** | 날씨 데이터 | - | - | 📋 |
| 14 | **MapKit** | 지도, POI, 경로 | - | - | 📋 |
| 15 | **Core Location** | GPS, 지오펜싱 | - | - | 📋 |
| 16 | **Core ML** | 온디바이스 ML | - | - | 📋 |
| 17 | **Vision** | 이미지 분석, OCR | - | - | 📋 |
| 18 | **User Notifications** | 푸시/로컬 알림 | - | - | 📋 |
| 19 | **TipKit** | 기능 팁 표시 | - | - | 📋 |
| 20 | **SharePlay** | 함께 보기 경험 | - | - | 📋 |

### 🎮 Phase 3: Graphics & Media (그래픽/미디어)
> 그래픽 렌더링, 게임, AR, 미디어 처리

| # | Technology | 설명 | 블로그 | DocC | 상태 |
|---|-----------|------|--------|------|------|
| 21 | **ARKit** | 증강현실 | [AR 가구 배치](https://m1zz.github.io/HIGLab/arkit/01-ar-furniture-app.html) | [튜토리얼](https://m1zz.github.io/HIGLab/arkit/documentation/higarkit/) | ✅ |
| 22 | **RealityKit** | 3D 렌더링 | - | - | 📋 |
| 23 | **SpriteKit** | 2D 게임 엔진 | - | - | 📋 |
| 24 | **Core Image** | 이미지 필터 | - | - | 📋 |
| 25 | **PencilKit** | 드로잉 캔버스 | - | - | 📋 |
| 26 | **PDFKit** | PDF 뷰어/편집 | - | - | 📋 |
| 27 | **AVFoundation** | 카메라, 비디오 | - | - | 📋 |
| 28 | **AVKit** | 미디어 플레이어 | - | - | 📋 |
| 29 | **MusicKit** | Apple Music 통합 | - | - | 📋 |
| 30 | **PhotosUI** | 사진 라이브러리 | - | - | 📋 |
| 31 | **Core Haptics** | 햅틱 피드백 | - | - | 📋 |
| 32 | **ShazamKit** | 음악 인식 | - | - | 📋 |
| 33 | 🆕 **Image Playground** | AI 이미지 생성 (iOS 26) | - | - | 📋 |

### 🔧 Phase 4: System (시스템/네트워크)
> 보안, 네트워크, 하드웨어 접근

| # | Technology | 설명 | 블로그 | DocC | 상태 |
|---|-----------|------|--------|------|------|
| 34 | **Core Bluetooth** | BLE 기기 연결 | [BLE 스캐너](https://m1zz.github.io/HIGLab/bluetooth/01-ble-device-scanner.html) | [튜토리얼](https://m1zz.github.io/HIGLab/bluetooth/documentation/higbluetooth/) | ✅ |
| 35 | **Core NFC** | NFC 태그 읽기/쓰기 | - | - | 📋 |
| 36 | **MultipeerConnectivity** | P2P 통신 | - | - | 📋 |
| 37 | **Network** | TCP/UDP/QUIC | - | - | 📋 |
| 38 | **LocalAuthentication** | Face ID / Touch ID | - | - | 📋 |
| 39 | **CryptoKit** | 암호화/해싱 | - | - | 📋 |
| 40 | **CallKit** | VoIP 전화 UI | - | - | 📋 |
| 41 | **EventKit** | 캘린더/리마인더 | - | - | 📋 |
| 42 | **Contacts** | 연락처 접근 | - | - | 📋 |
| 43 | 🆕 **Wi-Fi Aware** | AP 없이 직접 통신 (iOS 26) | - | - | 📋 |

### 🆕 Phase 5: iOS 26 신규 기술
> WWDC25에서 발표된 최신 기술

| # | Technology | 설명 | 상태 |
|---|-----------|------|------|
| 44 | **Visual Intelligence** | 카메라로 사물 인식 | 📋 |
| 45 | **AlarmKit** | 시스템 알람 설정 | 📋 |
| 46 | **EnergyKit** | 전력망 예보 | 📋 |
| 47 | **PermissionKit** | 통합 권한 관리 | 📋 |
| 48 | **RelevanceKit** | 상황별 콘텐츠 | 📋 |
| 49 | **ExtensibleImage** | 이미지 분석 확장 | 📋 |
| 50 | **AccessorySetupKit 2** | 액세서리 페어링 개선 | 📋 |

---

## 📁 프로젝트 구조

```
HIGLab/
├── site/                    # 📝 블로그 (GitHub Pages)
│   ├── index.html          # 메인 페이지
│   ├── widgets/            # WidgetKit 블로그
│   ├── activitykit/        # ActivityKit 블로그
│   ├── appintents/         # App Intents 블로그
│   ├── storekit/           # StoreKit 블로그
│   ├── arkit/              # ARKit 블로그
│   ├── bluetooth/          # Bluetooth 블로그
│   └── foundationmodels/   # Foundation Models 블로그
├── tutorials/              # 📚 DocC 튜토리얼
│   ├── widgets/           # WidgetKit (10챕터)
│   ├── activitykit/       # ActivityKit (8챕터)
│   ├── appintents/        # App Intents (5챕터)
│   ├── storekit/          # StoreKit (5챕터)
│   ├── arkit/             # ARKit (4챕터)
│   ├── bluetooth/         # Bluetooth (4챕터)
│   └── foundationmodels/  # Foundation Models (4챕터)
└── samples/               # 💻 샘플 프로젝트
    └── WeatherWidget/     # 날씨 위젯 예제
```

---

## 🚀 시작하기

### 블로그 보기
[m1zz.github.io/HIGLab](https://m1zz.github.io/HIGLab/)

### DocC 튜토리얼 실행
```bash
cd tutorials/widgets
swift package generate-documentation --target HIGWidgets
```

### 샘플 프로젝트 실행
```bash
cd samples/WeatherWidget
open WeatherWidget.xcodeproj
```

---

## 🤝 기여하기

PR 환영합니다! 새로운 튜토리얼이나 오타 수정 모두 감사합니다.

## 📄 라이선스

MIT License. 자유롭게 사용하세요.

---

Made with ❤️ by [개발자리](https://youtube.com/@devjari)
