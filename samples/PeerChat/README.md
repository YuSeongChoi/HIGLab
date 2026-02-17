# PeerChat

MultipeerConnectivity 프레임워크를 활용한 P2P 채팅 앱 샘플 프로젝트입니다.

## 🎯 학습 목표

- MultipeerConnectivity 프레임워크 이해
- MCNearbyServiceBrowser로 주변 기기 탐색
- MCNearbyServiceAdvertiser로 자신을 광고
- MCSession을 통한 데이터 전송
- 피어 간 연결 상태 관리

## 📱 주요 기능

### 1. 피어 발견 (MCNearbyServiceBrowser)
- 주변에서 PeerChat을 실행 중인 기기 탐색
- 발견된 기기 목록 실시간 업데이트
- 연결 초대 전송

### 2. 기기 광고 (MCNearbyServiceAdvertiser)
- 자신의 기기를 주변에 알림
- 커스텀 발견 정보 제공 (이름, 기기 타입 등)
- 연결 초대 수신 및 처리

### 3. 채팅 메시지 전송
- 연결된 피어와 1:1 채팅
- 실시간 메시지 송수신
- 메시지 기록 보관

### 4. 파일 공유
- 이미지 전송 (Photos 앱 연동)
- 문서 파일 전송 (Files 앱 연동)
- 파일 크기 제한 (10MB)

### 5. 연결 상태 표시
- 연결됨 / 연결 중 / 연결 안 됨 상태 표시
- 실시간 상태 변경 반영
- 시스템 메시지로 입장/퇴장 알림

### 6. 그룹 세션 관리
- 여러 피어로 그룹 생성
- 그룹 단체 채팅
- 멤버 관리

## 🏗 프로젝트 구조

```
PeerChat/
├── Shared/                     # 공통 모델
│   ├── Message.swift           # 메시지 모델
│   ├── Peer.swift              # 피어 모델
│   └── ServiceType.swift       # 서비스 상수
│
├── PeerChatApp/                # 메인 앱
│   ├── PeerChatApp.swift       # 앱 진입점
│   ├── MultipeerService.swift  # MC 서비스 관리자
│   ├── ChatView.swift          # 1:1 채팅 화면
│   ├── PeerDiscoveryView.swift # 피어 발견 화면
│   ├── GroupSessionView.swift  # 그룹 관리 화면
│   └── SettingsView.swift      # 설정 화면
│
└── README.md
```

## 🔧 핵심 클래스

### MultipeerService
앱의 핵심 서비스 클래스로, MultipeerConnectivity의 모든 기능을 관리합니다.

```swift
// 서비스 시작
multipeerService.startServices()

// 피어 초대
multipeerService.invitePeer(peer)

// 메시지 전송
try multipeerService.sendMessage("안녕하세요!", to: peer)

// 파일 전송
try multipeerService.sendFile(data, fileName: "photo.jpg", mimeType: "image/jpeg", to: peer)
```

### MCSessionDelegate 구현
피어 연결 상태 변화와 데이터 수신을 처리합니다.

```swift
func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState)
func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID)
```

### MCNearbyServiceBrowserDelegate 구현
주변 피어 발견/손실 이벤트를 처리합니다.

```swift
func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?)
func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID)
```

### MCNearbyServiceAdvertiserDelegate 구현
연결 초대 수신을 처리합니다.

```swift
func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void)
```

## 📝 사용 방법

1. 두 대 이상의 iOS 기기에서 앱 실행
2. "주변 기기" 탭에서 상대 기기 발견
3. "연결" 버튼을 눌러 초대 전송
4. 상대 기기에서 초대 수락
5. "채팅" 탭에서 연결된 기기와 대화

## ⚠️ 주의사항

- **같은 Wi-Fi 네트워크** 또는 **Bluetooth 범위** 내에 있어야 합니다
- iOS 시뮬레이터에서는 MultipeerConnectivity가 제한적으로 동작합니다
- 실제 기기에서 테스트하는 것을 권장합니다
- Info.plist에 `NSLocalNetworkUsageDescription`, `NSBonjourServices` 설정 필요

## 📚 참고 자료

- [MultipeerConnectivity - Apple Developer](https://developer.apple.com/documentation/multipeerconnectivity)
- [Nearby Interaction - Apple Developer](https://developer.apple.com/documentation/nearbyinteraction)
- [WWDC - Advances in Networking](https://developer.apple.com/videos/play/wwdc2019/713/)
