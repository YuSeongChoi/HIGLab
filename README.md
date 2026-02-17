# 🍎 HIG Lab

> **Apple Frameworks를 코드로 실습하는 곳**

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2017+-blue.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Apple의 **367개 프레임워크** 중 핵심 50개를 실전 중심으로 학습합니다. 각 기술별로 3가지를 제공:

1. **📝 블로그 포스트** — HIG 가이드라인 한글 해설 + 실전 예제
2. **📚 DocC 튜토리얼** — Xcode에서 바로 실습 가능한 step-by-step 가이드 (10챕터)
3. **💻 샘플 프로젝트** — 시니어급 완성도의 SwiftUI 앱 (평균 5,000줄+)

🌐 **라이브 사이트**: [m1zz.github.io/HIGLab](https://m1zz.github.io/HIGLab/)

---

## 📊 진행 상황

| 구분 | 완료 | 진행률 |
|------|------|--------|
| 📝 블로그 | **50/50** | 100% ✅ |
| 📚 DocC | **50/50** (10챕터+) | 100% ✅ |
| 💻 샘플 | **43개** (50기술 커버) | 100% ✅ |

> **🎉 프로젝트 완성!** 50개 기술 전체 커버리지 달성

### 📈 프로젝트 규모
- **총 샘플 프로젝트**: 43개
- **총 Swift 파일**: 468개
- **총 코드 라인**: 148,411줄
- **평균 샘플 규모**: 3,450줄 (시니어급 품질)

---

## 💻 샘플 프로젝트 (43개)

### 🚀 Phase 1: App Frameworks

| 샘플 | 기술 | 규모 | 설명 |
|------|------|------|------|
| [WeatherWidget](samples/WeatherWidget/) | WidgetKit, WeatherKit | 5,577줄 | 모든 위젯 크기 + 인터랙티브 |
| [TaskMaster](samples/TaskMaster/) | SwiftUI, SwiftData, Observation | 1,647줄 | CRUD + 동기화 |
| [DeliveryTracker](samples/DeliveryTracker/) | ActivityKit | 1,766줄 | Live Activity + Dynamic Island |
| [SiriTodo](samples/SiriTodo/) | App Intents | 5,689줄 | 12종 인텐트 + 위젯 |
| [AIChatbot](samples/AIChatbot/) | Foundation Models | 6,285줄 | Tool 사용 + 스트리밍 |

### 💳 Phase 2: App Services

| 샘플 | 기술 | 규모 | 설명 |
|------|------|------|------|
| [SubscriptionApp](samples/SubscriptionApp/) | StoreKit 2 | 2,043줄 | 구독 + 인앱결제 |
| [CartFlow](samples/CartFlow/) | PassKit | 5,391줄 | Apple Pay 완전 구현 |
| [CloudNotes](samples/CloudNotes/) | CloudKit | 1,952줄 | iCloud 동기화 |
| [SecureVault](samples/SecureVault/) | AuthServices, LocalAuth, CryptoKit | 5,935줄 | Sign in with Apple + 생체인증 + 암호화 |
| [HealthTracker](samples/HealthTracker/) | HealthKit | 3,929줄 | 걸음수/심박수/수면/운동 |
| [PlaceExplorer](samples/PlaceExplorer/) | MapKit | 1,793줄 | 지도 + POI |
| [LocationTracker](samples/LocationTracker/) | Core Location | 3,429줄 | GPS + 지오펜싱 |
| [MLClassifier](samples/MLClassifier/) | Core ML | 5,502줄 | Vision + 실시간 분류 |
| [VisionScanner](samples/VisionScanner/) | Vision, Visual Intelligence | 2,131줄 | OCR + 객체 인식 |
| [NotifyMe](samples/NotifyMe/) | User Notifications | 2,684줄 | 로컬/푸시 알림 |
| [TipShowcase](samples/TipShowcase/) | TipKit | 6,694줄 | 전체 시나리오 |
| [WatchParty](samples/WatchParty/) | SharePlay | 3,296줄 | GroupActivity + 동기화 재생 |

### 🎮 Phase 3: Graphics & Media

| 샘플 | 기술 | 규모 | 설명 |
|------|------|------|------|
| [ARFurniture](samples/ARFurniture/) | ARKit, RealityKit | 2,064줄 | AR 가구 배치 |
| [SpaceShooter](samples/SpaceShooter/) | SpriteKit | 2,804줄 | 2D 슈팅 게임 |
| [FilterLab](samples/FilterLab/) | Core Image | 2,516줄 | 30+ 필터 + Metal 커널 |
| [SketchPad](samples/SketchPad/) | PencilKit | 1,750줄 | 드로잉 앱 |
| [PDFReader](samples/PDFReader/) | PDFKit | 3,057줄 | PDF 뷰어/편집 |
| [CameraApp](samples/CameraApp/) | AVFoundation | 6,046줄 | 전체 카메라 기능 |
| [MusicPlayer](samples/MusicPlayer/) | MusicKit, AVKit | 1,591줄 | Apple Music 연동 |
| [PhotoGallery](samples/PhotoGallery/) | PhotosUI | 6,326줄 | 갤러리 + 편집 |
| [HapticDemo](samples/HapticDemo/) | Core Haptics | 2,757줄 | 햅틱 패턴 에디터 |
| [SoundMatch](samples/SoundMatch/) | ShazamKit | 5,484줄 | 음악 인식 + MusicKit |
| [ImageMaker](samples/ImageMaker/) | Image Playground | 2,775줄 | AI 이미지 생성 |

### 🔧 Phase 4: System & Network

| 샘플 | 기술 | 규모 | 설명 |
|------|------|------|------|
| [BLEScanner](samples/BLEScanner/) | Core Bluetooth | 2,237줄 | BLE 기기 연결 |
| [NFCReader](samples/NFCReader/) | Core NFC | 3,599줄 | 태그 읽기/쓰기 |
| [PeerChat](samples/PeerChat/) | MultipeerConnectivity | 2,677줄 | P2P 채팅 |
| [NetMonitor](samples/NetMonitor/) | Network | 2,447줄 | 네트워크 모니터링 |
| [VoIPPhone](samples/VoIPPhone/) | CallKit | 2,840줄 | VoIP 전화 |
| [CalendarPlus](samples/CalendarPlus/) | EventKit | 3,306줄 | 캘린더 + 리마인더 |
| [ContactBook](samples/ContactBook/) | Contacts | 3,330줄 | 연락처 관리 |
| [DirectShare](samples/DirectShare/) | Wi-Fi Aware | 2,718줄 | AP 없는 P2P 전송 |

### 🆕 Phase 5: iOS 26

| 샘플 | 기술 | 규모 | 설명 |
|------|------|------|------|
| [WakeUp](samples/WakeUp/) | AlarmKit | 2,761줄 | 시스템 알람 |
| [GreenCharge](samples/GreenCharge/) | EnergyKit | 4,399줄 | 전력망 예보 |
| [PermissionHub](samples/PermissionHub/) | PermissionKit | 3,497줄 | 통합 권한 관리 |
| [SmartFeed](samples/SmartFeed/) | RelevanceKit | 3,921줄 | 콘텐츠 추천 |
| [DevicePair](samples/DevicePair/) | AccessorySetupKit | 2,729줄 | 액세서리 페어링 |
| [SmartCrop](samples/SmartCrop/) | ExtensibleImage | 3,137줄 | AI 이미지 편집 |

---

## 📚 DocC 튜토리얼 (50개)

모든 튜토리얼은 **10챕터 이상**으로 구성되어 있습니다.

```bash
# 튜토리얼 실행 예시
cd tutorials/widgets
swift package generate-documentation --target HIGWidgets
```

---

## 🏆 시니어급 코드 품질

모든 샘플 프로젝트는 **10년차 Apple 개발자 기준 9/10** 품질을 목표로 합니다:

- ✅ **핵심 API 완전 활용** — 각 프레임워크의 주요 클래스/프로토콜 사용
- ✅ **에러 처리** — 커스텀 에러 타입 + LocalizedError
- ✅ **Swift Concurrency** — async/await + Actor 패턴
- ✅ **Accessibility** — VoiceOver 지원
- ✅ **문서화** — /// 주석 완비
- ✅ **SwiftUI Previews** — #Preview 매크로 활용

---

## 📁 프로젝트 구조

```
HIGLab/
├── site/                    # 📝 블로그 (50개)
│   ├── index.html
│   └── {framework}/01-*.html
├── tutorials/              # 📚 DocC 튜토리얼 (50개)
│   └── {framework}/        # Swift Package + DocC
├── samples/               # 💻 샘플 프로젝트 (43개)
│   └── {SampleName}/      # 완성된 SwiftUI 앱
└── SSOT.json              # Single Source of Truth
```

---

## 🚀 시작하기

### 블로그 보기
```bash
open https://m1zz.github.io/HIGLab/
```

### DocC 튜토리얼 실행
```bash
cd tutorials/widgets
swift package --disable-sandbox preview-documentation --target HIGWidgets
```

### 샘플 프로젝트 실행
Xcode에서 samples/ 폴더의 Swift 파일들을 새 프로젝트에 추가하세요.

---

## 🤝 기여하기

PR 환영합니다! 

## 📄 라이선스

MIT License. 자유롭게 사용하세요.

---

Made with ❤️ by [개발자리](https://youtube.com/@devjari)
