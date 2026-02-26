# /hig - Apple Framework AI Reference

Fetch and use HIGLab AI Reference for Apple framework development.

## Usage
- `/hig storekit` — Load StoreKit 2 reference
- `/hig list` — Show all 50 frameworks
- `/hig 인앱결제` — Korean keyword matching

## Instructions

When this command is invoked with argument `$ARGUMENTS`:

1. If the argument is "list", display all 50 frameworks in the table below and stop.
2. Otherwise, convert the argument to lowercase and match it against the **Argument** column below.
3. Fetch the matched URL using `curl` or `web_fetch` and use the full content as context.
4. If no match is found, suggest the closest framework from the list.
5. Generate code following the patterns and best practices from the fetched reference.

## Framework Mapping Table

| Argument | Framework | URL |
|----------|-----------|-----|
| swiftui, swift ui | SwiftUI | https://m1zz.github.io/HIGLab/ai-reference/swiftui.md |
| observation, observable, 상태관리 | Observation | https://m1zz.github.io/HIGLab/ai-reference/swiftui-observation.md |
| swiftdata, swift data, 데이터 | SwiftData | https://m1zz.github.io/HIGLab/ai-reference/swiftdata.md |
| widget, widgetkit, 위젯 | WidgetKit | https://m1zz.github.io/HIGLab/ai-reference/widgets.md |
| activity, activitykit, liveactivity, 라이브액티비티, 배달 | ActivityKit | https://m1zz.github.io/HIGLab/ai-reference/activitykit.md |
| appintents, siri, 단축어, 시리 | App Intents | https://m1zz.github.io/HIGLab/ai-reference/appintents.md |
| foundationmodels, foundation, llm, 챗봇, ai | Foundation Models | https://m1zz.github.io/HIGLab/ai-reference/foundation-models.md |
| tipkit, tip, 팁, 온보딩 | TipKit | https://m1zz.github.io/HIGLab/ai-reference/tipkit.md |
| storekit, 인앱결제, 구독, iap | StoreKit 2 | https://m1zz.github.io/HIGLab/ai-reference/storekit.md |
| passkit, applepay, 결제, wallet | PassKit | https://m1zz.github.io/HIGLab/ai-reference/passkit.md |
| cloudkit, icloud, 동기화 | CloudKit | https://m1zz.github.io/HIGLab/ai-reference/cloudkit.md |
| authservices, auth, signin, 로그인, 패스키 | Auth Services | https://m1zz.github.io/HIGLab/ai-reference/authservices.md |
| localauth, faceid, touchid, 생체인증 | LocalAuthentication | https://m1zz.github.io/HIGLab/ai-reference/localauth.md |
| cryptokit, crypto, 암호화 | CryptoKit | https://m1zz.github.io/HIGLab/ai-reference/cryptokit.md |
| healthkit, health, 건강, 헬스 | HealthKit | https://m1zz.github.io/HIGLab/ai-reference/healthkit.md |
| mapkit, map, 지도 | MapKit | https://m1zz.github.io/HIGLab/ai-reference/mapkit.md |
| corelocation, location, gps, 위치 | Core Location | https://m1zz.github.io/HIGLab/ai-reference/corelocation.md |
| coreml, ml, 머신러닝 | Core ML | https://m1zz.github.io/HIGLab/ai-reference/coreml.md |
| vision, ocr, 이미지분석 | Vision | https://m1zz.github.io/HIGLab/ai-reference/vision.md |
| notifications, push, 알림, 푸시 | User Notifications | https://m1zz.github.io/HIGLab/ai-reference/notifications.md |
| shareplay, groupactivity, 함께보기 | SharePlay | https://m1zz.github.io/HIGLab/ai-reference/shareplay.md |
| eventkit, calendar, 캘린더, 리마인더 | EventKit | https://m1zz.github.io/HIGLab/ai-reference/eventkit.md |
| contacts, 연락처 | Contacts | https://m1zz.github.io/HIGLab/ai-reference/contacts.md |
| musickit, music, 음악, applemusic | MusicKit | https://m1zz.github.io/HIGLab/ai-reference/musickit.md |
| weatherkit, weather, 날씨 | WeatherKit | https://m1zz.github.io/HIGLab/ai-reference/weatherkit.md |
| arkit, ar, 증강현실 | ARKit | https://m1zz.github.io/HIGLab/ai-reference/arkit.md |
| realitykit, 3d, reality | RealityKit | https://m1zz.github.io/HIGLab/ai-reference/realitykit.md |
| spritekit, sprite, 게임, 2d | SpriteKit | https://m1zz.github.io/HIGLab/ai-reference/spritekit.md |
| coreimage, filter, 필터 | Core Image | https://m1zz.github.io/HIGLab/ai-reference/coreimage.md |
| pencilkit, pencil, 드로잉, 그리기 | PencilKit | https://m1zz.github.io/HIGLab/ai-reference/pencilkit.md |
| pdfkit, pdf | PDFKit | https://m1zz.github.io/HIGLab/ai-reference/pdfkit.md |
| avfoundation, camera, 카메라, 녹음 | AVFoundation | https://m1zz.github.io/HIGLab/ai-reference/avfoundation.md |
| avkit, video, 영상, 재생 | AVKit | https://m1zz.github.io/HIGLab/ai-reference/avkit.md |
| photosui, photos, 사진, 갤러리 | PhotosUI | https://m1zz.github.io/HIGLab/ai-reference/photosui.md |
| corehaptics, haptics, haptic, 햅틱, 진동 | Core Haptics | https://m1zz.github.io/HIGLab/ai-reference/corehaptics.md |
| shazamkit, shazam, 음악인식 | ShazamKit | https://m1zz.github.io/HIGLab/ai-reference/shazamkit.md |
| imageplayground, 이미지생성 | Image Playground | https://m1zz.github.io/HIGLab/ai-reference/image-playground.md |
| bluetooth, ble, 블루투스 | Core Bluetooth | https://m1zz.github.io/HIGLab/ai-reference/core-bluetooth.md |
| nfc, corenfc, 태그 | Core NFC | https://m1zz.github.io/HIGLab/ai-reference/core-nfc.md |
| multipeer, p2p, 피어 | MultipeerConnectivity | https://m1zz.github.io/HIGLab/ai-reference/multipeerconnectivity.md |
| network, tcp, udp, quic | Network | https://m1zz.github.io/HIGLab/ai-reference/network.md |
| callkit, voip, 전화 | CallKit | https://m1zz.github.io/HIGLab/ai-reference/callkit.md |
| wifiaware, wifi, 와이파이 | Wi-Fi Aware | https://m1zz.github.io/HIGLab/ai-reference/wifi-aware.md |
| visualintelligence, 시각지능 | Visual Intelligence | https://m1zz.github.io/HIGLab/ai-reference/visual-intelligence.md |
| alarmkit, alarm, 알람 | AlarmKit | https://m1zz.github.io/HIGLab/ai-reference/alarmkit.md |
| energykit, energy, 에너지, 전력 | EnergyKit | https://m1zz.github.io/HIGLab/ai-reference/energykit.md |
| permissionkit, permission, 권한 | PermissionKit | https://m1zz.github.io/HIGLab/ai-reference/permissionkit.md |
| relevancekit, relevance, 추천 | RelevanceKit | https://m1zz.github.io/HIGLab/ai-reference/relevancekit.md |
| accessorysetupkit, accessory, 액세서리, 페어링 | AccessorySetupKit | https://m1zz.github.io/HIGLab/ai-reference/accessorysetupkit.md |
| extensibleimage, 이미지편집 | ExtensibleImage | https://m1zz.github.io/HIGLab/ai-reference/extensibleimage.md |

## Code Standards

After fetching the reference, generate code following these standards:
- Swift 5.9+ and iOS 17+
- SwiftUI over UIKit
- `@Observable` over `ObservableObject`
- `SwiftData` over Core Data
- `async/await` over completion handlers
- Custom error types conforming to `LocalizedError`
- VoiceOver labels on all interactive elements
- `#Preview` macros for SwiftUI previews
- `///` documentation comments on public APIs
