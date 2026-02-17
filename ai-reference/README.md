# 🤖 AI Reference

> **AI 코드 생성을 위한 참조 문서**
> 
> 이 폴더의 문서들은 Claude, GPT 등 AI가 iOS/SwiftUI 코드를 정확하게 생성할 수 있도록 설계되었습니다.

## 📖 [사용 가이드 (HOW-TO-USE.md)](HOW-TO-USE.md)

👉 **처음이라면 이 가이드를 먼저 읽어주세요!**

- 프롬프트 작성법
- 실전 예제
- 문제 해결 팁

---

## 📚 문서 목록 (50개)

### 🚀 App Frameworks
| 문서 | 설명 | 주요 키워드 |
|------|------|------------|
| [swiftui.md](swiftui.md) | SwiftUI 기본 | View, Modifier, State |
| [swiftui-observation.md](swiftui-observation.md) | @Observable 상태 관리 | @Observable, @Bindable, @Environment |
| [swiftdata.md](swiftdata.md) | SwiftData CRUD | @Model, @Query, ModelContainer |
| [widgets.md](widgets.md) | WidgetKit 위젯 구현 | Timeline, Provider, Widget Family |
| [activitykit.md](activitykit.md) | Live Activity, Dynamic Island | ActivityAttributes, ContentState |
| [appintents.md](appintents.md) | App Intents, Siri 연동 | AppIntent, AppShortcut |
| [foundation-models.md](foundation-models.md) | 온디바이스 AI | LanguageModelSession, Tool |
| [tipkit.md](tipkit.md) | 팁 표시 | Tip, TipView, 규칙 |

### 💳 App Services
| 문서 | 설명 | 주요 키워드 |
|------|------|------------|
| [storekit.md](storekit.md) | 인앱결제, 구독 | Product, Transaction, purchase() |
| [passkit.md](passkit.md) | Apple Pay, Wallet | PKPaymentRequest, PassKit |
| [cloudkit.md](cloudkit.md) | iCloud 동기화 | CKContainer, CKRecord |
| [authservices.md](authservices.md) | Sign in with Apple | ASAuthorizationController |
| [localauth.md](localauth.md) | 생체인증 | LAContext, FaceID, TouchID |
| [cryptokit.md](cryptokit.md) | 암호화 | AES, SHA, Signature |
| [healthkit.md](healthkit.md) | 건강 데이터 | HKHealthStore, HKQuery |
| [mapkit.md](mapkit.md) | 지도 | Map, MKMapItem, Look Around |
| [corelocation.md](corelocation.md) | 위치 서비스 | CLLocationManager, Geofencing |
| [coreml.md](coreml.md) | 머신러닝 | MLModel, Vision 통합 |
| [vision.md](vision.md) | 이미지 분석 | VNRequest, OCR, 객체 감지 |
| [notifications.md](notifications.md) | 알림 | UNUserNotificationCenter |
| [shareplay.md](shareplay.md) | SharePlay | GroupActivity, 동기화 |
| [eventkit.md](eventkit.md) | 캘린더, 리마인더 | EKEventStore, EKEvent |
| [contacts.md](contacts.md) | 연락처 | CNContactStore, CNContact |
| [musickit.md](musickit.md) | Apple Music | MusicKit, MusicPlayer |

### 🎮 Graphics & Media
| 문서 | 설명 | 주요 키워드 |
|------|------|------------|
| [arkit.md](arkit.md) | 증강현실 | ARSession, ARView |
| [realitykit.md](realitykit.md) | 3D 렌더링 | Entity, RealityView |
| [spritekit.md](spritekit.md) | 2D 게임 | SKScene, SKNode |
| [coreimage.md](coreimage.md) | 이미지 필터 | CIFilter, CIContext |
| [pencilkit.md](pencilkit.md) | 드로잉 | PKCanvasView, PKDrawing |
| [pdfkit.md](pdfkit.md) | PDF 처리 | PDFView, PDFDocument |
| [avfoundation.md](avfoundation.md) | 카메라, 오디오 | AVCaptureSession |
| [avkit.md](avkit.md) | 비디오 재생 | VideoPlayer, AVPlayer |
| [photosui.md](photosui.md) | 사진 앱 연동 | PhotosPicker, PHAsset |
| [corehaptics.md](corehaptics.md) | 햅틱 피드백 | CHHapticEngine |
| [shazamkit.md](shazamkit.md) | 음악 인식 | SHSession, SHMediaItem |
| [image-playground.md](image-playground.md) | AI 이미지 생성 | ImagePlaygroundSheet |
| [weatherkit.md](weatherkit.md) | 날씨 데이터 | WeatherService, Weather |

### 🔧 System & Network
| 문서 | 설명 | 주요 키워드 |
|------|------|------------|
| [core-bluetooth.md](core-bluetooth.md) | BLE 기기 연결 | CBCentralManager, CBPeripheral |
| [core-nfc.md](core-nfc.md) | NFC 태그 | NFCNDEFReaderSession |
| [multipeerconnectivity.md](multipeerconnectivity.md) | P2P 통신 | MCSession, MCBrowser |
| [network.md](network.md) | 저수준 네트워크 | NWConnection, NWListener |
| [callkit.md](callkit.md) | VoIP 통화 | CXProvider, CXCallController |
| [wifi-aware.md](wifi-aware.md) | Wi-Fi 직접 연결 | DevicePicker, NWBrowser |

### 🆕 iOS 18+ Apple Intelligence
| 문서 | 설명 | 주요 키워드 |
|------|------|------------|
| [visual-intelligence.md](visual-intelligence.md) | 시각 분석 | ImageAnalyzer, VisionKit |
| [alarmkit.md](alarmkit.md) | 알람 시계 | AlarmManager, Alarm |
| [energykit.md](energykit.md) | 에너지 데이터 | EnergyManager, GridStatus |
| [permissionkit.md](permissionkit.md) | 통합 권한 관리 | PermissionManager |
| [relevancekit.md](relevancekit.md) | 맥락 기반 추천 | RelevanceEngine, Context |
| [accessorysetupkit.md](accessorysetupkit.md) | 액세서리 페어링 | ASAccessorySession |
| [extensibleimage.md](extensibleimage.md) | 이미지 편집 확장 | EIImageEditingProvider |

---

## 🎯 사용 방법

### 1. AI에게 문서 제공

```
이 문서를 참고해서 날씨 위젯을 만들어줘:

[widgets.md 내용 붙여넣기]
```

### 2. 프로젝트 컨텍스트로 사용

AI 도구(Claude, Cursor, GitHub Copilot 등)의 컨텍스트에 이 폴더를 포함시키면,
정확한 iOS 코드 생성이 가능합니다.

### 3. 조합 사용

```
widgets.md + swiftdata.md 참고해서
SwiftData로 저장되는 할일을 표시하는 위젯 만들어줘
```

---

## 📝 문서 구조

각 문서는 다음 구조를 따릅니다:

1. **개요**: 프레임워크 설명 (1-2문장)
2. **필수 Import**: 필요한 import 문
3. **프로젝트 설정**: Info.plist, Capability 등
4. **핵심 구성요소**: 주요 타입/프로토콜 설명
5. **전체 작동 예제**: 복사해서 바로 실행 가능한 코드
6. **고급 패턴**: 추가 사용 사례
7. **주의사항**: 흔한 실수와 해결법

---

## ✅ 코드 품질

모든 예제 코드는:
- ✅ Swift 5.9+ / iOS 17+ 기준 (일부 iOS 18+)
- ✅ 컴파일 가능한 전체 코드
- ✅ SwiftUI 최신 패턴 (@Observable 등)
- ✅ #Preview 매크로 포함
- ✅ 한글 주석

---

## 🔗 관련 자료

- [📝 블로그](https://m1zz.github.io/HIGLab/) - 상세 설명
- [📚 DocC 튜토리얼](../tutorials/) - 단계별 학습
- [💻 샘플 프로젝트](../samples/) - 실전 코드

---

Made for AI, by [개발자리](https://youtube.com/@Leeo25)
