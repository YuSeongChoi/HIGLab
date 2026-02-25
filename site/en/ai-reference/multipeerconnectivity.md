# MultipeerConnectivity AI Reference

> P2P 통신 앱 구현 가이드. 이 문서를 읽고 MultipeerConnectivity 코드를 생성할 수 있습니다.

## 개요

MultipeerConnectivity는 Wi-Fi, Bluetooth, P2P Wi-Fi를 통해 근처 기기 간 직접 통신을 제공합니다.
인터넷 연결 없이 메시지, 파일, 스트림 데이터를 주고받을 수 있습니다.

## 필수 Import

```swift
import MultipeerConnectivity
```

## 프로젝트 설정

```xml
<!-- Info.plist -->
<!-- Bluetooth 사용 시 -->
<key>NSBluetoothAlwaysUsageDescription</key>
<string>근처 기기와 연결하기 위해 Bluetooth가 필요합니다.</string>

<!-- 로컬 네트워크 사용 -->
<key>NSLocalNetworkUsageDescription</key>
<string>근처 기기를 찾기 위해 로컬 네트워크 접근이 필요합니다.</string>

<!-- Bonjour 서비스 -->
<key>NSBonjourServices</key>
<array>
    <string>_myapp._tcp</string>
    <string>_myapp._udp</string>
</array>
```

## 핵심 구성요소

### 1. MCPeerID (기기 식별)

```swift
// 현재 기기 ID
let peerID = MCPeerID(displayName: UIDevice.current.name)

// 커스텀 이름
let peerID = MCPeerID(displayName: "Player1")
```

### 2. MCSession (세션 관리)

```swift
let session = MCSession(
    peer: myPeerID,
    securityIdentity: nil,
    encryptionPreference: .required
)
session.delegate = self
```

### 3. MCNearbyServiceAdvertiser (광고)

```swift
// 내 기기를 광고
let advertiser = MCNearbyServiceAdvertiser(
    peer: myPeerID,
    discoveryInfo: ["role": "host"],  // 추가 정보
    serviceType: "my-app"  // 1-15자, 소문자/숫자/하이픈
)
advertiser.delegate = self
advertiser.startAdvertisingPeer()
```

### 4. MCNearbyServiceBrowser (탐색)

```swift
// 근처 기기 탐색
let browser = MCNearbyServiceBrowser(
    peer: myPeerID,
    serviceType: "my-app"
)
browser.delegate = self
browser.startBrowsingForPeers()
```

## 전체 작동 예제

```swift
import SwiftUI
import MultipeerConnectivity

// MARK: - Multipeer Manager
@Observable
class MultipeerManager: NSObject {
    var connectedPeers: [MCPeerID] = []
    var availablePeers: [MCPeerID] = []
    var receivedMessages: [ChatMessage] = []
    var isAdvertising = false
    var isBrowsing = false
    
    private let serviceType = "chat-app"
    private let myPeerID: MCPeerID
    private var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser!
    private var browser: MCNearbyServiceBrowser!
    
    override init() {
        myPeerID = MCPeerID(displayName: UIDevice.current.name)
        super.init()
        
        session = MCSession(
            peer: myPeerID,
            securityIdentity: nil,
            encryptionPreference: .required
        )
        session.delegate = self
        
        advertiser = MCNearbyServiceAdvertiser(
            peer: myPeerID,
            discoveryInfo: nil,
            serviceType: serviceType
        )
        advertiser.delegate = self
        
        browser = MCNearbyServiceBrowser(
            peer: myPeerID,
            serviceType: serviceType
        )
        browser.delegate = self
    }
    
    // MARK: - 광고 시작/중지
    func startAdvertising() {
        advertiser.startAdvertisingPeer()
        isAdvertising = true
    }
    
    func stopAdvertising() {
        advertiser.stopAdvertisingPeer()
        isAdvertising = false
    }
    
    // MARK: - 탐색 시작/중지
    func startBrowsing() {
        browser.startBrowsingForPeers()
        isBrowsing = true
    }
    
    func stopBrowsing() {
        browser.stopBrowsingForPeers()
        isBrowsing = false
    }
    
    // MARK: - 연결 요청
    func invitePeer(_ peer: MCPeerID) {
        browser.invitePeer(
            peer,
            to: session,
            withContext: nil,
            timeout: 30
        )
    }
    
    // MARK: - 메시지 전송
    func send(_ message: String) {
        guard !session.connectedPeers.isEmpty else { return }
        
        let chatMessage = ChatMessage(
            sender: myPeerID.displayName,
            content: message,
            timestamp: Date()
        )
        
        if let data = try? JSONEncoder().encode(chatMessage) {
            try? session.send(data, toPeers: session.connectedPeers, with: .reliable)
            receivedMessages.append(chatMessage)
        }
    }
    
    // MARK: - 파일 전송
    func sendFile(url: URL, to peer: MCPeerID) {
        session.sendResource(
            at: url,
            withName: url.lastPathComponent,
            toPeer: peer
        ) { error in
            if let error = error {
                print("파일 전송 실패: \(error)")
            }
        }
    }
    
    // MARK: - 연결 해제
    func disconnect() {
        session.disconnect()
    }
}

// MARK: - MCSessionDelegate
extension MultipeerManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                if !self.connectedPeers.contains(peerID) {
                    self.connectedPeers.append(peerID)
                }
                self.availablePeers.removeAll { $0 == peerID }
            case .notConnected:
                self.connectedPeers.removeAll { $0 == peerID }
            case .connecting:
                print("\(peerID.displayName) 연결 중...")
            @unknown default:
                break
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let message = try? JSONDecoder().decode(ChatMessage.self, from: data) {
            DispatchQueue.main.async {
                self.receivedMessages.append(message)
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // 스트림 수신 처리
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("파일 수신 시작: \(resourceName)")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        if let url = localURL {
            print("파일 수신 완료: \(url)")
        }
    }
}

// MARK: - MCNearbyServiceAdvertiserDelegate
extension MultipeerManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // 자동 수락 (또는 UI로 확인)
        invitationHandler(true, session)
    }
}

// MARK: - MCNearbyServiceBrowserDelegate
extension MultipeerManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        DispatchQueue.main.async {
            if !self.availablePeers.contains(peerID) && !self.connectedPeers.contains(peerID) {
                self.availablePeers.append(peerID)
            }
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.availablePeers.removeAll { $0 == peerID }
        }
    }
}

// MARK: - Chat Message Model
struct ChatMessage: Codable, Identifiable {
    let id = UUID()
    let sender: String
    let content: String
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case sender, content, timestamp
    }
}

// MARK: - Main View
struct MultipeerChatView: View {
    @State private var manager = MultipeerManager()
    @State private var messageText = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 연결된 피어
                if !manager.connectedPeers.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(manager.connectedPeers, id: \.displayName) { peer in
                                Label(peer.displayName, systemImage: "person.fill")
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(.green.opacity(0.2))
                                    .clipShape(Capsule())
                            }
                        }
                        .padding()
                    }
                    .background(.bar)
                }
                
                // 메시지 목록
                List(manager.receivedMessages) { message in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(message.sender)
                                .font(.caption.bold())
                            Spacer()
                            Text(message.timestamp, style: .time)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        Text(message.content)
                    }
                }
                .listStyle(.plain)
                
                // 메시지 입력
                HStack {
                    TextField("메시지", text: $messageText)
                        .textFieldStyle(.roundedBorder)
                    
                    Button {
                        manager.send(messageText)
                        messageText = ""
                    } label: {
                        Image(systemName: "paperplane.fill")
                    }
                    .disabled(messageText.isEmpty || manager.connectedPeers.isEmpty)
                }
                .padding()
                .background(.bar)
            }
            .navigationTitle("P2P 채팅")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Toggle("광고", isOn: Binding(
                            get: { manager.isAdvertising },
                            set: { $0 ? manager.startAdvertising() : manager.stopAdvertising() }
                        ))
                        Toggle("탐색", isOn: Binding(
                            get: { manager.isBrowsing },
                            set: { $0 ? manager.startBrowsing() : manager.stopBrowsing() }
                        ))
                    } label: {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Section("발견된 기기") {
                            ForEach(manager.availablePeers, id: \.displayName) { peer in
                                Button(peer.displayName) {
                                    manager.invitePeer(peer)
                                }
                            }
                            if manager.availablePeers.isEmpty {
                                Text("없음")
                            }
                        }
                    } label: {
                        Image(systemName: "person.2")
                    }
                }
            }
            .onAppear {
                manager.startAdvertising()
                manager.startBrowsing()
            }
            .onDisappear {
                manager.stopAdvertising()
                manager.stopBrowsing()
                manager.disconnect()
            }
        }
    }
}

#Preview {
    MultipeerChatView()
}
```

## 고급 패턴

### 1. 스트림 데이터 전송

```swift
// 스트림 시작
func startStream(to peer: MCPeerID) throws -> OutputStream {
    try session.startStream(withName: "video", toPeer: peer)
}

// 스트림 수신
func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    stream.delegate = self
    stream.schedule(in: .main, forMode: .default)
    stream.open()
}

// StreamDelegate
extension MultipeerManager: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case .hasBytesAvailable:
            if let inputStream = aStream as? InputStream {
                var buffer = [UInt8](repeating: 0, count: 1024)
                let bytesRead = inputStream.read(&buffer, maxLength: buffer.count)
                if bytesRead > 0 {
                    let data = Data(bytes: buffer, count: bytesRead)
                    // 데이터 처리
                }
            }
        case .endEncountered:
            aStream.close()
        default:
            break
        }
    }
}
```

### 2. 초대 UI (MCBrowserViewController)

```swift
import UIKit
import MultipeerConnectivity

class PeerBrowserVC: UIViewController {
    var session: MCSession!
    var peerID: MCPeerID!
    
    func showBrowser() {
        let browserVC = MCBrowserViewController(
            serviceType: "my-app",
            session: session
        )
        browserVC.delegate = self
        browserVC.minimumNumberOfPeers = 1
        browserVC.maximumNumberOfPeers = 4
        
        present(browserVC, animated: true)
    }
}

extension PeerBrowserVC: MCBrowserViewControllerDelegate {
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
}
```

### 3. 보안 연결

```swift
// 인증서 기반 보안
func setupSecureSession() -> MCSession {
    // 인증서 로드
    guard let certificateURL = Bundle.main.url(forResource: "cert", withExtension: "p12"),
          let certificateData = try? Data(contentsOf: certificateURL) else {
        fatalError("인증서 없음")
    }
    
    var items: CFArray?
    let options = [kSecImportExportPassphrase: "password"]
    SecPKCS12Import(certificateData as CFData, options as CFDictionary, &items)
    
    let identityDict = (items as! [[String: Any]])[0]
    let identity = identityDict[kSecImportItemIdentity as String] as! SecIdentity
    
    return MCSession(
        peer: myPeerID,
        securityIdentity: [identity],
        encryptionPreference: .required
    )
}

// 인증서 검증
func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
    // 인증서 검증 로직
    certificateHandler(true)  // 또는 false로 거부
}
```

## 주의사항

1. **서비스 타입 규칙**
   ```swift
   // 1-15자, 소문자/숫자/하이픈만
   // 첫 글자는 문자
   let serviceType = "my-game"  // ✅
   let serviceType = "MyGame"   // ❌ 대문자
   let serviceType = "1game"    // ❌ 숫자 시작
   ```

2. **백그라운드 제한**
   - 앱이 백그라운드로 가면 연결 끊김
   - Background Modes로 일부 연장 가능

3. **배터리 소모**
   - 광고/탐색은 배터리 소모 큼
   - 필요 시에만 활성화

4. **피어 수 제한**
   - 최대 8개 피어 연결 권장
   - 그 이상은 성능 저하

5. **Info.plist 필수**
   - NSBonjourServices에 서비스 타입 등록 필수
   - `_서비스타입._tcp` 형식
