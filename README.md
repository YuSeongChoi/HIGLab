# 🍎 HIG Lab

> **Apple Frameworks를 코드로 실습하는 곳**

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2017+-blue.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Apple의 **367개 프레임워크**를 실전 중심으로 학습합니다. 각 기술별로 3가지를 제공:

1. **📝 블로그 포스트** — HIG 가이드라인 한글 해설 + 실전 예제
2. **📚 DocC 튜토리얼** — Xcode에서 바로 실습 가능한 step-by-step 가이드  
3. **💻 샘플 프로젝트** — 완성된 SwiftUI 코드

---

## 🗺️ 기술 로드맵

### 🚀 Phase 1: App Frameworks (핵심)
> 앱의 뼈대를 구성하는 핵심 프레임워크

| # | Technology | 설명 | 블로그 | DocC | 샘플 | 상태 |
|---|-----------|------|--------|------|------|------|
| 1 | **WidgetKit** | 홈화면/잠금화면 위젯 | [날씨 위젯](site/widgets/) | [튜토리얼](tutorials/widgets/) | WeatherWidget | ✅ |
| 2 | **ActivityKit** | Live Activities, Dynamic Island | 배달 추적 | - | DeliveryTracker | 🔜 |
| 3 | **App Intents** | Siri, 단축어, 위젯 통합 | Siri 제어 | - | VoiceTaskManager | 🔜 |
| 4 | **SwiftUI** | 선언적 UI 프레임워크 | 기초→고급 | - | - | 📋 |
| 5 | **SwiftData** | 현대적 데이터 저장 | CRUD 완전정복 | - | - | 📋 |
| 6 | **Observation** | @Observable 상태관리 | 상태관리 패턴 | - | - | 📋 |
| 7 | 🆕 **Foundation Models** | 온디바이스 LLM (iOS 26) | AI 앱 만들기 | - | - | 📋 |

### 💳 Phase 2: App Services (서비스 통합)
> 앱의 기능을 시스템과 클라우드로 확장

| # | Technology | 설명 | 블로그 | 상태 |
|---|-----------|------|--------|------|
| 8 | **StoreKit 2** | 인앱결제, 구독 | 구독 앱 만들기 | 📋 |
| 9 | **PassKit** | Apple Pay, Wallet | 결제 통합 | 📋 |
| 10 | **CloudKit** | iCloud 데이터 동기화 | 무료 백엔드 | 📋 |
| 11 | **Authentication Services** | Sign in with Apple, 패스키 | 안전한 로그인 | 📋 |
| 12 | **HealthKit** | 건강 데이터 | 헬스 앱 만들기 | 📋 |
| 13 | **WeatherKit** | 날씨 데이터 | 날씨 앱 만들기 | 📋 |
| 14 | **MapKit** | 지도, POI, 경로 | 지도 앱 만들기 | 📋 |
| 15 | **Core Location** | GPS, 지오펜싱 | 위치 기반 앱 | 📋 |
| 16 | **Core ML** | 온디바이스 ML | AI 통합 | 📋 |
| 17 | **Vision** | 이미지 분석, OCR | 사진 분석 앱 | 📋 |
| 18 | **User Notifications** | 푸시/로컬 알림 | 알림 완전정복 | 📋 |
| 19 | **TipKit** | 기능 팁 표시 | 온보딩 가이드 | 📋 |
| 20 | **SharePlay** | 함께 보기 경험 | 공유 앱 만들기 | 📋 |

### 🎮 Phase 3: Graphics & Media (그래픽/미디어)
> 그래픽 렌더링, 게임, AR, 미디어 처리

| # | Technology | 설명 | 블로그 | 상태 |
|---|-----------|------|--------|------|
| 21 | **ARKit** | 증강현실 | AR 앱 만들기 | 📋 |
| 22 | **RealityKit** | 3D 렌더링 | 3D 경험 구현 | 📋 |
| 23 | **SpriteKit** | 2D 게임 엔진 | 게임 만들기 | 📋 |
| 24 | **Core Image** | 이미지 필터 | 필터 앱 만들기 | 📋 |
| 25 | **PencilKit** | 드로잉 캔버스 | 그림 앱 만들기 | 📋 |
| 26 | **PDFKit** | PDF 뷰어/편집 | PDF 앱 만들기 | 📋 |
| 27 | **AVFoundation** | 카메라, 비디오 | 카메라 앱 만들기 | 📋 |
| 28 | **AVKit** | 미디어 플레이어 | 플레이어 만들기 | 📋 |
| 29 | **MusicKit** | Apple Music 통합 | 음악 앱 만들기 | 📋 |
| 30 | **Photos/PhotosUI** | 사진 라이브러리 | 갤러리 앱 만들기 | 📋 |
| 31 | **Core Haptics** | 햅틱 피드백 | 진동 디자인 | 📋 |
| 32 | **ShazamKit** | 음악 인식 | 음악 찾기 | 📋 |
| 33 | 🆕 **Image Playground** | AI 이미지 생성 (iOS 26) | 이미지 생성 | 📋 |

### 🔧 Phase 4: System (시스템/네트워크)
> 보안, 네트워크, 하드웨어 접근

| # | Technology | 설명 | 블로그 | 상태 |
|---|-----------|------|--------|------|
| 34 | **Core Bluetooth** | BLE 기기 연결 | IoT 앱 만들기 | 📋 |
| 35 | **Core NFC** | NFC 태그 읽기/쓰기 | NFC 앱 만들기 | 📋 |
| 36 | **MultipeerConnectivity** | P2P 통신 | 근거리 공유 | 📋 |
| 37 | **Network** | TCP/UDP/QUIC | 네트워킹 기초 | 📋 |
| 38 | **LocalAuthentication** | Face ID / Touch ID | 생체인증 | 📋 |
| 39 | **CryptoKit** | 암호화/해싱 | 보안 기초 | 📋 |
| 40 | **CallKit** | VoIP 전화 UI | 전화 앱 만들기 | 📋 |
| 41 | **EventKit** | 캘린더/리마인더 | 일정 앱 만들기 | 📋 |
| 42 | **Contacts** | 연락처 접근 | 연락처 앱 만들기 | 📋 |
| 43 | 🆕 **Wi-Fi Aware** | AP 없이 직접 통신 (iOS 26) | P2P 통신 | 📋 |

### 🆕 Phase 5: iOS 26 신규 기술
> WWDC25에서 발표된 최신 기술

| # | Technology | 설명 | 블로그 | 상태 |
|---|-----------|------|--------|------|
| 44 | **Foundation Models** | 온디바이스 LLM | AI 챗봇 만들기 | 📋 |
| 45 | **Visual Intelligence** | 카메라로 사물 인식 | 시각 AI | 📋 |
| 46 | **Image Playground** | AI 이미지 생성 | 이미지 생성 | 📋 |
| 47 | **AlarmKit** | 시스템 알람 설정 | 알람 앱 만들기 | 📋 |
| 48 | **EnergyKit** | 전력망 예보 | 에너지 최적화 | 📋 |
| 49 | **PermissionKit** | 통합 권한 관리 | 권한 UX | 📋 |
| 50 | **RelevanceKit** | 상황별 콘텐츠 | 스마트 추천 | 📋 |

---

## 📊 진행 현황

```
Phase 1: ████░░░░░░░░░░░░░░░░ 1/7 (14%)
Phase 2: ░░░░░░░░░░░░░░░░░░░░ 0/13 (0%)
Phase 3: ░░░░░░░░░░░░░░░░░░░░ 0/13 (0%)
Phase 4: ░░░░░░░░░░░░░░░░░░░░ 0/10 (0%)
Phase 5: ░░░░░░░░░░░░░░░░░░░░ 0/7 (0%)
─────────────────────────────────
Total:   ██░░░░░░░░░░░░░░░░░░ 1/50 (2%)
```

### 상태 범례
- ✅ 완료
- 🔜 진행 중
- 📋 예정

---

## 📁 프로젝트 구조

```
HIGLab/
├── site/                    ← 블로그 포스트 (HTML)
│   └── widgets/
├── tutorials/               ← DocC 패키지 (기술별)
│   └── widgets/
├── samples/                 ← Xcode 샘플 프로젝트
│   └── WeatherWidget/
└── .github/workflows/       ← 자동 배포
    └── deploy.yml
```

---

## 🚀 온라인 보기

- **메인**: https://m1zz.github.io/HIGLab/
- **Widgets DocC**: https://m1zz.github.io/HIGLab/widgets/tutorials/table-of-contents

---

## 🛠️ 로컬에서 DocC 빌드

```bash
cd tutorials/widgets
swift package resolve
swift package --disable-sandbox preview-documentation --target HIGWidgets
# → http://localhost:8080/documentation/higwidgets
```

---

## 📚 참고 자료

### Apple 공식
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [WWDC Videos](https://developer.apple.com/videos/)

### 프레임워크 통계 (367개)
| 구분 | 수량 |
|------|------|
| ⭐ iOS 핵심 | ~50개 |
| 🆕 iOS 26 신규 | ~15개 |
| ⚠️ Deprecated | ~12개 |
| 📡 서버 API | ~15개 |

---

## 📄 라이선스

MIT License

---

**HIG Lab** by [개발자리](https://youtube.com/@devjari) 🚀

> *"367개 프레임워크, 하나씩 정복하자"*
