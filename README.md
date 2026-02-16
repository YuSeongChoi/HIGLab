# 🍎 HIG Lab

> **Apple Frameworks를 코드로 실습하는 곳**

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2017+-blue.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Progress](https://img.shields.io/badge/Progress-50%2F50-brightgreen.svg)](https://m1zz.github.io/HIGLab/)

Apple의 **367개 프레임워크** 중 핵심 50개를 실전 중심으로 학습합니다. 각 기술별로 3가지를 제공:

1. **📝 블로그 포스트** — HIG 가이드라인 한글 해설 + 실전 예제
2. **📚 DocC 튜토리얼** — Xcode에서 바로 실습 가능한 step-by-step 가이드  
3. **💻 샘플 프로젝트** — 완성된 SwiftUI 코드

🌐 **라이브 사이트**: [m1zz.github.io/HIGLab](https://m1zz.github.io/HIGLab/)

---

## 📊 진행 상황

**50/50 완료 (100%)** 🎉

| Phase | 완료 | 기술 |
|-------|------|------|
| 1 App Frameworks | 7/7 | WidgetKit, ActivityKit, App Intents, SwiftUI, SwiftData, Observation, Foundation Models |
| 2 App Services | 13/13 | StoreKit 2, PassKit, CloudKit, Auth Services, HealthKit, WeatherKit, MapKit, Core Location, Core ML, Vision, Notifications, TipKit, SharePlay |
| 3 Graphics & Media | 13/13 | ARKit, RealityKit, SpriteKit, Core Image, PencilKit, PDFKit, AVFoundation, AVKit, MusicKit, PhotosUI, Core Haptics, ShazamKit, Image Playground |
| 4 System & Network | 10/10 | Core Bluetooth, Core NFC, MultipeerConnectivity, Network, LocalAuth, CryptoKit, CallKit, EventKit, Contacts, Wi-Fi Aware |
| 5 iOS 26 | 7/7 | Foundation Models, Visual Intelligence, Image Playground, AlarmKit, EnergyKit, PermissionKit, RelevanceKit |

---

## 🗺️ 기술 로드맵

### 🚀 Phase 1: App Frameworks (핵심)
> 앱의 뼈대를 구성하는 핵심 프레임워크

| # | Technology | 설명 | 블로그 | DocC | 상태 |
|---|-----------|------|--------|------|------|
| 1 | **WidgetKit** | 홈화면/잠금화면 위젯 | [날씨 위젯](https://m1zz.github.io/HIGLab/widgets/01-weather-widget-challenge.html) | [튜토리얼](https://m1zz.github.io/HIGLab/tutorials/widgets/documentation/higwidgets/) | ✅ |
| 2 | **ActivityKit** | Live Activities, Dynamic Island | [배달 추적](https://m1zz.github.io/HIGLab/activitykit/01-delivery-tracker.html) | [튜토리얼](https://m1zz.github.io/HIGLab/tutorials/activitykit/documentation/higactivitykit/) | ✅ |
| 3 | **App Intents** | Siri, 단축어, 위젯 통합 | [Siri 앱](https://m1zz.github.io/HIGLab/appintents/01-siri-todo-app.html) | [튜토리얼](https://m1zz.github.io/HIGLab/tutorials/appintents/documentation/higappintents/) | ✅ |
| 4 | **SwiftUI** | 선언적 UI 프레임워크 | [블로그](https://m1zz.github.io/HIGLab/swiftui/01-tutorial.html) | [튜토리얼](https://m1zz.github.io/HIGLab/tutorials/swiftui/documentation/higswiftui/) | ✅ |
| 5 | **SwiftData** | 현대적 데이터 저장 | [블로그](https://m1zz.github.io/HIGLab/swiftdata/01-tutorial.html) | [튜토리얼](https://m1zz.github.io/HIGLab/tutorials/swiftdata/documentation/higswiftdata/) | ✅ |
| 6 | **Observation** | @Observable 상태관리 | [블로그](https://m1zz.github.io/HIGLab/observation/01-tutorial.html) | [튜토리얼](https://m1zz.github.io/HIGLab/tutorials/observation/documentation/higobservation/) | ✅ |
| 7 | 🆕 **Foundation Models** | 온디바이스 LLM (iOS 26) | [AI 챗봇](https://m1zz.github.io/HIGLab/foundationmodels/01-ai-chatbot.html) | [튜토리얼](https://m1zz.github.io/HIGLab/tutorials/foundationmodels/documentation/higfoundationmodels/) | ✅ |

### 💳 Phase 2: App Services (서비스 통합)
> 앱의 기능을 시스템과 클라우드로 확장

| # | Technology | 설명 | 블로그 | DocC | 상태 |
|---|-----------|------|--------|------|------|
| 8 | **StoreKit 2** | 인앱결제, 구독 | [구독 앱](https://m1zz.github.io/HIGLab/storekit/01-subscription-app.html) | [튜토리얼](https://m1zz.github.io/HIGLab/tutorials/storekit/documentation/higstorekit/) | ✅ |
| 9 | **PassKit** | Apple Pay, Wallet | [블로그](https://m1zz.github.io/HIGLab/passkit/01-tutorial.html) | [튜토리얼](https://m1zz.github.io/HIGLab/passkit/documentation/higpasskit/) | ✅ |
| 10 | **CloudKit** | iCloud 데이터 동기화 | [블로그](https://m1zz.github.io/HIGLab/cloudkit/01-tutorial.html) | [튜토리얼](https://m1zz.github.io/HIGLab/cloudkit/documentation/higcloudkit/) | ✅ |
| 11 | **Authentication Services** | Sign in with Apple | [블로그](https://m1zz.github.io/HIGLab/authservices/01-tutorial.html) | [튜토리얼](https://m1zz.github.io/HIGLab/authservices/documentation/higauthservices/) | ✅ |
| 12 | **HealthKit** | 건강 데이터 | [블로그](https://m1zz.github.io/HIGLab/healthkit/01-tutorial.html) | [튜토리얼](https://m1zz.github.io/HIGLab/healthkit/documentation/highealthkit/) | ✅ |
| 13 | **WeatherKit** | 날씨 데이터 | [블로그](https://m1zz.github.io/HIGLab/weatherkit/01-tutorial.html) | [튜토리얼](https://m1zz.github.io/HIGLab/weatherkit/documentation/higweatherkit/) | ✅ |
| 14 | **MapKit** | 지도, POI, 경로 | [블로그](https://m1zz.github.io/HIGLab/mapkit/01-tutorial.html) | [튜토리얼](https://m1zz.github.io/HIGLab/mapkit/documentation/higmapkit/) | ✅ |
| 15 | **Core Location** | GPS, 지오펜싱 | [블로그](https://m1zz.github.io/HIGLab/corelocation/01-tutorial.html) | [튜토리얼](https://m1zz.github.io/HIGLab/corelocation/documentation/higcorelocation/) | ✅ |
| 16 | **Core ML** | 온디바이스 ML | [블로그](https://m1zz.github.io/HIGLab/coreml/01-tutorial.html) | [튜토리얼](https://m1zz.github.io/HIGLab/coreml/documentation/higcoreml/) | ✅ |
| 17 | **Vision** | 이미지 분석, OCR | [블로그](https://m1zz.github.io/HIGLab/vision/01-tutorial.html) | [튜토리얼](https://m1zz.github.io/HIGLab/vision/documentation/higvision/) | ✅ |
| 18 | **User Notifications** | 푸시/로컬 알림 | [블로그](https://m1zz.github.io/HIGLab/notifications/01-tutorial.html) | [튜토리얼](https://m1zz.github.io/HIGLab/notifications/documentation/hignotifications/) | ✅ |
| 19 | **TipKit** | 기능 팁 표시 | [블로그](https://m1zz.github.io/HIGLab/tipkit/01-tutorial.html) | [튜토리얼](https://m1zz.github.io/HIGLab/tipkit/documentation/higtipkit/) | ✅ |
| 20 | **SharePlay** | 함께 보기 경험 | [블로그](https://m1zz.github.io/HIGLab/shareplay/01-tutorial.html) | [튜토리얼](https://m1zz.github.io/HIGLab/shareplay/documentation/higshareplay/) | ✅ |

### 🎮 Phase 3: Graphics & Media (그래픽/미디어)
> 그래픽 렌더링, 게임, AR, 미디어 처리

| # | Technology | 설명 | 블로그 | DocC | 상태 |
|---|-----------|------|--------|------|------|
| 21 | **ARKit** | 증강현실 | [AR 가구 배치](https://m1zz.github.io/HIGLab/arkit/01-ar-furniture-app.html) | [튜토리얼](https://m1zz.github.io/HIGLab/tutorials/arkit/documentation/higarkit/) | ✅ |
| 22 | **RealityKit** | 3D 렌더링 | [블로그](https://m1zz.github.io/HIGLab/realitykit/01-tutorial.html) | [튜토리얼](https://m1zz.github.io/HIGLab/realitykit/documentation/higrealitykit/) | ✅ |
| 23 | **SpriteKit** | 2D 게임 엔진 | [블로그](https://m1zz.github.io/HIGLab/spritekit/01-tutorial.html) | [튜토리얼](https://m1zz.github.io/HIGLab/spritekit/documentation/higspritekit/) | ✅ |
| 24 | **Core Image** | 이미지 필터 | [블로그](https://m1zz.github.io/HIGLab/coreimage/01-tutorial.html) | [튜토리얼](https://m1zz.github.io/HIGLab/coreimage/documentation/higcoreimage/) | ✅ |
| 25 | **PencilKit** | 드로잉 캔버스 | [블로그](https://m1zz.github.io/HIGLab/pencilkit/01-tutorial.html) | [튜토리얼](https://m1zz.github.io/HIGLab/pencilkit/documentation/higpencilkit/) | ✅ |
| 26 | **PDFKit** | PDF 뷰어/편집 | [블로그](https://m1zz.github.io/HIGLab/pdfkit/01-tutorial.html) | [튜토리얼](https://m1zz.github.io/HIGLab/pdfkit/documentation/higpdfkit/) | ✅ |
| 27 | **AVFoundation** | 카메라, 비디오 | [블로그](https://m1zz.github.io/HIGLab/avfoundation/01-tutorial.html) | [튜토리얼](https://m1zz.github.io/HIGLab/avfoundation/documentation/higavfoundation/) | ✅ |
| 28 | **AVKit** | 미디어 플레이어 | [블로그](https://m1zz.github.io/HIGLab/avkit/01-tutorial.html) | [튜토리얼](https://m1zz.github.io/HIGLab/avkit/documentation/higavkit/) | ✅ |
| 29 | **MusicKit** | Apple Music 통합 | [블로그](https://m1zz.github.io/HIGLab/musickit/01-tutorial.html) | [튜토리얼](https://m1zz.github.io/HIGLab/musickit/documentation/higmusickit/) | ✅ |
| 30 | **PhotosUI** | 사진 라이브러리 | [블로그](https://m1zz.github.io/HIGLab/photosui/01-tutorial.html) | [튜토리얼](https://m1zz.github.io/HIGLab/photosui/documentation/higphotosui/) | ✅ |
| 31 | **Core Haptics** | 햅틱 피드백 | [블로그](https://m1zz.github.io/HIGLab/corehaptics/01-tutorial.html) | [튜토리얼](https://m1zz.github.io/HIGLab/corehaptics/documentation/higcorehaptics/) | ✅ |
| 32 | **ShazamKit** | 음악 인식 | [블로그](https://m1zz.github.io/HIGLab/shazamkit/01-tutorial.html) | [튜토리얼](https://m1zz.github.io/HIGLab/shazamkit/documentation/higshazamkit/) | ✅ |
| 33 | 🆕 **Image Playground** | AI 이미지 생성 (iOS 26) | [블로그](https://m1zz.github.io/HIGLab/imageplayground/01-tutorial.html) | [튜토리얼](https://m1zz.github.io/HIGLab/imageplayground/documentation/higimageplayground/) | ✅ |

### 🔧 Phase 4: System (시스템/네트워크)
> 보안, 네트워크, 하드웨어 접근

| # | Technology | 설명 | 블로그 | DocC | 상태 |
|---|-----------|------|--------|------|------|
| 34 | **Core Bluetooth** | BLE 기기 연결 | [BLE 스캐너](https://m1zz.github.io/HIGLab/bluetooth/01-ble-device-scanner.html) | [튜토리얼](https://m1zz.github.io/HIGLab/tutorials/bluetooth/documentation/higbluetooth/) | ✅ |
| 35 | **Core NFC** | NFC 태그 읽기/쓰기 | [블로그](https://m1zz.github.io/HIGLab/corenfc/01-tutorial.html) | [튜토리얼](https://m1zz.github.io/HIGLab/corenfc/documentation/higcorenfc/) | ✅ |
| 36 | **MultipeerConnectivity** | P2P 통신 | [블로그](https://m1zz.github.io/HIGLab/multipeer/01-tutorial.html) | [튜토리얼](https://m1zz.github.io/HIGLab/multipeer/documentation/higmultipeer/) | ✅ |
| 37 | **Network** | TCP/UDP/QUIC | [블로그](https://m1zz.github.io/HIGLab/network/01-tutorial.html) | [튜토리얼](https://m1zz.github.io/HIGLab/network/documentation/hignetwork/) | ✅ |
| 38 | **LocalAuthentication** | Face ID / Touch ID | [블로그](https://m1zz.github.io/HIGLab/localauth/01-tutorial.html) | [튜토리얼](https://m1zz.github.io/HIGLab/localauth/documentation/higlocalauth/) | ✅ |
| 39 | **CryptoKit** | 암호화/해싱 | [블로그](https://m1zz.github.io/HIGLab/cryptokit/01-tutorial.html) | [튜토리얼](https://m1zz.github.io/HIGLab/cryptokit/documentation/higcryptokit/) | ✅ |
| 40 | **CallKit** | VoIP 전화 UI | [블로그](https://m1zz.github.io/HIGLab/callkit/01-tutorial.html) | [튜토리얼](https://m1zz.github.io/HIGLab/callkit/documentation/higcallkit/) | ✅ |
| 41 | **EventKit** | 캘린더/리마인더 | [블로그](https://m1zz.github.io/HIGLab/eventkit/01-tutorial.html) | [튜토리얼](https://m1zz.github.io/HIGLab/eventkit/documentation/higeventkit/) | ✅ |
| 42 | **Contacts** | 연락처 접근 | [블로그](https://m1zz.github.io/HIGLab/contacts/01-tutorial.html) | [튜토리얼](https://m1zz.github.io/HIGLab/contacts/documentation/higcontacts/) | ✅ |
| 43 | 🆕 **Wi-Fi Aware** | AP 없이 직접 통신 (iOS 26) | [블로그](https://m1zz.github.io/HIGLab/wifiaware/01-tutorial.html) | [튜토리얼](https://m1zz.github.io/HIGLab/wifiaware/documentation/higwifiaware/) | ✅ |

### 🆕 Phase 5: iOS 26 신규 기술
> WWDC25에서 발표된 최신 기술

| # | Technology | 설명 | 블로그 | DocC | 상태 |
|---|-----------|------|--------|------|------|
| 44 | **Visual Intelligence** | 카메라로 사물 인식 | [블로그](https://m1zz.github.io/HIGLab/visualintelligence/01-tutorial.html) | [튜토리얼](https://m1zz.github.io/HIGLab/visualintelligence/documentation/higvisualintelligence/) | ✅ |
| 45 | **AlarmKit** | 시스템 알람 설정 | [블로그](https://m1zz.github.io/HIGLab/alarmkit/01-tutorial.html) | [튜토리얼](https://m1zz.github.io/HIGLab/alarmkit/documentation/higalarmkit/) | ✅ |
| 46 | **EnergyKit** | 전력망 예보 | [블로그](https://m1zz.github.io/HIGLab/energykit/01-tutorial.html) | [튜토리얼](https://m1zz.github.io/HIGLab/energykit/documentation/higenergykit/) | ✅ |
| 47 | **PermissionKit** | 통합 권한 관리 | [블로그](https://m1zz.github.io/HIGLab/permissionkit/01-tutorial.html) | [튜토리얼](https://m1zz.github.io/HIGLab/permissionkit/documentation/higpermissionkit/) | ✅ |
| 48 | **RelevanceKit** | 상황별 콘텐츠 | [블로그](https://m1zz.github.io/HIGLab/relevancekit/01-tutorial.html) | [튜토리얼](https://m1zz.github.io/HIGLab/relevancekit/documentation/higrelevancekit/) | ✅ |
| 49 | **ExtensibleImage** | 이미지 분석 확장 | [블로그](https://m1zz.github.io/HIGLab/extensibleimage/01-tutorial.html) | [튜토리얼](https://m1zz.github.io/HIGLab/extensibleimage/documentation/higextensibleimage/) | ✅ |
| 50 | **AccessorySetupKit 2** | 액세서리 페어링 개선 | [블로그](https://m1zz.github.io/HIGLab/accessorysetupkit/01-tutorial.html) | [튜토리얼](https://m1zz.github.io/HIGLab/accessorysetupkit/documentation/higaccessorysetupkit/) | ✅ |

---

## 📁 프로젝트 구조

```
HIGLab/
├── site/                    # 📝 블로그 (GitHub Pages)
│   ├── index.html          # 메인 페이지
│   └── {framework}/        # 각 프레임워크별 블로그 포스트
├── tutorials/              # 📚 DocC 튜토리얼 (50개)
│   └── {framework}/        # Swift Package + DocC 문서
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
