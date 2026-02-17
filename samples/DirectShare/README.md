# DirectShare

Wi-Fi Aware를 사용한 P2P 파일 공유 샘플 앱입니다. iOS 26의 새로운 Wi-Fi Aware API를 활용하여 AP(액세스 포인트) 없이 기기 간 직접 통신으로 파일을 전송합니다.

## 주요 기능

- **Wi-Fi Aware 피어 발견**: NWBrowser를 사용하여 주변의 DirectShare 앱 사용자 자동 검색
- **서비스 광고**: NWListener로 자신의 존재를 주변 기기에 알림
- **보안 연결**: TLS 기반의 암호화된 P2P 연결
- **대용량 파일 전송**: 청크 분할 전송으로 안정적인 대용량 파일 지원
- **실시간 진행률**: 전송 속도, 남은 시간, 진행률 표시
- **파일 수신 승인**: 수신 전 파일 정보 확인 및 승인/거부

## 기술 스택

- **Network Framework**: NWBrowser, NWListener, NWConnection
- **Wi-Fi Aware**: iOS 26+의 `requiredInterface = .wifiAware`
- **SwiftUI**: @Observable 기반 상태 관리
- **CryptoKit**: SHA256 체크섬 검증

## 프로젝트 구조

```
DirectShare/
├── Shared/                     # 공통 모델
│   ├── TransferFile.swift      # 전송 파일 모델
│   ├── Peer.swift              # 피어(기기) 모델
│   └── ConnectionState.swift   # 연결 상태 및 메시지 프로토콜
├── DirectShareApp/             # 메인 앱
│   ├── DirectShareApp.swift    # 앱 엔트리 포인트
│   ├── WiFiAwareManager.swift  # Wi-Fi Aware 핵심 매니저
│   ├── FileTransferService.swift # 파일 전송 서비스
│   └── Views/
│       ├── ContentView.swift       # 메인 뷰
│       ├── PeerListView.swift      # 피어 목록
│       └── TransferProgressView.swift # 전송 진행률
└── README.md
```

## Wi-Fi Aware 핵심 개념

### AP 없는 직접 통신
Wi-Fi Aware는 Wi-Fi 라우터나 인터넷 연결 없이 기기 간 직접 통신을 가능하게 합니다:
- 빠른 데이터 전송 (Wi-Fi 속도)
- 낮은 지연 시간
- 배터리 효율적

### NWBrowser (피어 검색)
```swift
let parameters = NWParameters()
parameters.includePeerToPeer = true
parameters.requiredInterface = .wifiAware  // iOS 26+

let browser = NWBrowser(
    for: .bonjour(type: "_directshare._wifiaware", domain: "local."),
    using: parameters
)
```

### NWListener (서비스 광고)
```swift
let listener = try NWListener(using: parameters)
listener.service = NWListener.Service(
    name: "My Device",
    type: "_directshare._wifiaware"
)
```

## 파일 전송 프로토콜

1. **핸드셰이크**: 연결 시 hello/helloAck 교환
2. **파일 제안**: fileOffer 메시지로 메타데이터 전송
3. **승인/거부**: 수신자가 fileAccept 또는 fileReject
4. **청크 전송**: 64KB 청크로 분할하여 fileData 전송
5. **완료 확인**: fileComplete로 전송 종료

## 요구 사항

- iOS 26.0+
- Xcode 26.0+
- Wi-Fi Aware 지원 기기

## 권한

Info.plist에 다음 권한 필요:
```xml
<key>NSLocalNetworkUsageDescription</key>
<string>주변 기기와 파일을 공유하기 위해 로컬 네트워크 접근이 필요합니다.</string>

<key>NSBonjourServices</key>
<array>
    <string>_directshare._wifiaware</string>
</array>
```

## 사용 방법

1. 두 기기에서 앱 실행
2. 자동으로 스캔 및 광고 시작
3. 주변 기기 목록에서 연결할 기기 선택
4. 연결 후 '파일 보내기' 선택
5. 파일 선택 및 전송 시작
6. 수신 측에서 파일 수락

## 파일 통계

- 총 파일: 9개
- 총 코드: 2,700+ 줄
