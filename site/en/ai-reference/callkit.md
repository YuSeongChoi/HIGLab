# CallKit AI Reference

> VoIP 통화 앱 구현 가이드. 이 문서를 읽고 CallKit 코드를 생성할 수 있습니다.

## 개요

CallKit은 VoIP 앱이 시스템 통화 UI와 통합되도록 해주는 프레임워크입니다.
수신/발신 통화 화면, 연락처 차단, 발신자 식별 등 네이티브 전화 앱과 동일한 경험을 제공합니다.

## 필수 Import

```swift
import CallKit
import AVFoundation  // 오디오 세션
import PushKit       // VoIP 푸시
```

## 프로젝트 설정

### 1. Capability 추가
- Background Modes > Voice over IP
- Background Modes > Remote notifications
- Push Notifications

### 2. Info.plist

```xml
<!-- 마이크 권한 -->
<key>NSMicrophoneUsageDescription</key>
<string>통화를 위해 마이크 접근이 필요합니다.</string>
```

## 핵심 구성요소

### 1. CXProvider (통화 이벤트)

```swift
import CallKit

class CallManager: NSObject {
    let provider: CXProvider
    let callController = CXCallController()
    
    override init() {
        let config = CXProviderConfiguration()
        config.localizedName = "My VoIP App"
        config.supportsVideo = true
        config.maximumCallsPerCallGroup = 1
        config.supportedHandleTypes = [.phoneNumber, .generic]
        config.iconTemplateImageData = UIImage(named: "CallIcon")?.pngData()
        config.ringtoneSound = "ringtone.wav"
        
        provider = CXProvider(configuration: config)
        super.init()
        provider.setDelegate(self, queue: nil)
    }
}
```

### 2. CXCallController (통화 제어)

```swift
// 발신 통화 시작
func startCall(handle: String, video: Bool = false) {
    let uuid = UUID()
    let handle = CXHandle(type: .phoneNumber, value: handle)
    let startCallAction = CXStartCallAction(call: uuid, handle: handle)
    startCallAction.isVideo = video
    
    let transaction = CXTransaction(action: startCallAction)
    callController.request(transaction) { error in
        if let error = error {
            print("발신 실패: \(error)")
        }
    }
}

// 통화 종료
func endCall(uuid: UUID) {
    let endCallAction = CXEndCallAction(call: uuid)
    let transaction = CXTransaction(action: endCallAction)
    callController.request(transaction) { error in
        if let error = error {
            print("종료 실패: \(error)")
        }
    }
}
```

### 3. 수신 통화 보고

```swift
// 수신 통화를 시스템에 보고
func reportIncomingCall(uuid: UUID, handle: String, hasVideo: Bool, completion: @escaping (Error?) -> Void) {
    let update = CXCallUpdate()
    update.remoteHandle = CXHandle(type: .phoneNumber, value: handle)
    update.hasVideo = hasVideo
    update.localizedCallerName = "발신자 이름"
    
    provider.reportNewIncomingCall(with: uuid, update: update) { error in
        completion(error)
    }
}
```

## 전체 작동 예제

```swift
import SwiftUI
import CallKit
import AVFoundation
import PushKit

// MARK: - Call Model
struct Call: Identifiable {
    let id: UUID
    let handle: String
    let isOutgoing: Bool
    var isOnHold: Bool = false
    var isMuted: Bool = false
    var startTime: Date?
}

// MARK: - Call Manager
@Observable
class CallManager: NSObject {
    var activeCalls: [Call] = []
    var callState: String = "대기 중"
    
    private let provider: CXProvider
    private let callController = CXCallController()
    private var audioSession: AVAudioSession { AVAudioSession.sharedInstance() }
    
    override init() {
        let config = CXProviderConfiguration()
        config.localizedName = "VoIP Demo"
        config.supportsVideo = true
        config.maximumCallsPerCallGroup = 1
        config.maximumCallGroups = 1
        config.supportedHandleTypes = [.phoneNumber, .generic]
        config.includesCallsInRecents = true
        
        provider = CXProvider(configuration: config)
        super.init()
        provider.setDelegate(self, queue: nil)
    }
    
    // MARK: - 발신 통화
    func startOutgoingCall(to handle: String, hasVideo: Bool = false) {
        let uuid = UUID()
        let cxHandle = CXHandle(type: .phoneNumber, value: handle)
        
        let startAction = CXStartCallAction(call: uuid, handle: cxHandle)
        startAction.isVideo = hasVideo
        
        let transaction = CXTransaction(action: startAction)
        callController.request(transaction) { [weak self] error in
            if let error = error {
                print("발신 실패: \(error)")
                return
            }
            
            DispatchQueue.main.async {
                let call = Call(id: uuid, handle: handle, isOutgoing: true)
                self?.activeCalls.append(call)
                self?.callState = "발신 중..."
            }
        }
    }
    
    // MARK: - 수신 통화 (VoIP 푸시에서 호출)
    func reportIncomingCall(uuid: UUID, handle: String, hasVideo: Bool) {
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .phoneNumber, value: handle)
        update.hasVideo = hasVideo
        update.localizedCallerName = getContactName(for: handle)
        
        provider.reportNewIncomingCall(with: uuid, update: update) { [weak self] error in
            if let error = error {
                print("수신 보고 실패: \(error)")
                return
            }
            
            DispatchQueue.main.async {
                let call = Call(id: uuid, handle: handle, isOutgoing: false)
                self?.activeCalls.append(call)
                self?.callState = "수신 중..."
            }
        }
    }
    
    // MARK: - 통화 종료
    func endCall(uuid: UUID) {
        let endAction = CXEndCallAction(call: uuid)
        let transaction = CXTransaction(action: endAction)
        
        callController.request(transaction) { error in
            if let error = error {
                print("종료 실패: \(error)")
            }
        }
    }
    
    // MARK: - 보류
    func setHold(uuid: UUID, onHold: Bool) {
        let holdAction = CXSetHeldCallAction(call: uuid, onHold: onHold)
        let transaction = CXTransaction(action: holdAction)
        
        callController.request(transaction) { error in
            if let error = error {
                print("보류 실패: \(error)")
            }
        }
    }
    
    // MARK: - 음소거
    func setMute(uuid: UUID, muted: Bool) {
        let muteAction = CXSetMutedCallAction(call: uuid, muted: muted)
        let transaction = CXTransaction(action: muteAction)
        
        callController.request(transaction) { error in
            if let error = error {
                print("음소거 실패: \(error)")
            }
        }
    }
    
    // MARK: - DTMF
    func sendDTMF(uuid: UUID, digits: String) {
        let dtmfAction = CXPlayDTMFCallAction(call: uuid, digits: digits, type: .singleTone)
        let transaction = CXTransaction(action: dtmfAction)
        
        callController.request(transaction) { error in
            if let error = error {
                print("DTMF 실패: \(error)")
            }
        }
    }
    
    // MARK: - 헬퍼
    private func getContactName(for handle: String) -> String {
        // 연락처에서 이름 조회
        return handle
    }
    
    private func configureAudioSession() {
        do {
            try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [.allowBluetooth, .defaultToSpeaker])
            try audioSession.setActive(true)
        } catch {
            print("오디오 세션 설정 실패: \(error)")
        }
    }
}

// MARK: - CXProviderDelegate
extension CallManager: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        // 모든 통화 종료
        activeCalls.removeAll()
        callState = "대기 중"
    }
    
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        // 발신 통화 시작
        configureAudioSession()
        
        // 실제 VoIP 연결 시작
        connectToVoIPServer(for: action.callUUID)
        
        action.fulfill()
        
        // 연결 완료 보고
        provider.reportOutgoingCall(with: action.callUUID, startedConnectingAt: Date())
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        // 수신 통화 응답
        configureAudioSession()
        
        // 실제 VoIP 연결
        connectToVoIPServer(for: action.callUUID)
        
        DispatchQueue.main.async {
            if let index = self.activeCalls.firstIndex(where: { $0.id == action.callUUID }) {
                self.activeCalls[index].startTime = Date()
            }
            self.callState = "통화 중"
        }
        
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        // 통화 종료
        disconnectFromVoIPServer(for: action.callUUID)
        
        DispatchQueue.main.async {
            self.activeCalls.removeAll { $0.id == action.callUUID }
            self.callState = self.activeCalls.isEmpty ? "대기 중" : "통화 중"
        }
        
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        // 보류 토글
        DispatchQueue.main.async {
            if let index = self.activeCalls.firstIndex(where: { $0.id == action.callUUID }) {
                self.activeCalls[index].isOnHold = action.isOnHold
            }
        }
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        // 음소거 토글
        DispatchQueue.main.async {
            if let index = self.activeCalls.firstIndex(where: { $0.id == action.callUUID }) {
                self.activeCalls[index].isMuted = action.isMuted
            }
        }
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        // 오디오 세션 활성화됨 - 오디오 스트림 시작
        startAudioStream()
    }
    
    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        // 오디오 세션 비활성화됨 - 오디오 스트림 중지
        stopAudioStream()
    }
    
    // MARK: - VoIP 연결 (구현 필요)
    private func connectToVoIPServer(for uuid: UUID) {
        // WebRTC, SIP 등 실제 연결 구현
    }
    
    private func disconnectFromVoIPServer(for uuid: UUID) {
        // 연결 해제
    }
    
    private func startAudioStream() {
        // 오디오 스트림 시작
    }
    
    private func stopAudioStream() {
        // 오디오 스트림 중지
    }
}

// MARK: - VoIP Push (PushKit)
class PushKitManager: NSObject, PKPushRegistryDelegate {
    let callManager: CallManager
    let registry = PKPushRegistry(queue: .main)
    
    init(callManager: CallManager) {
        self.callManager = callManager
        super.init()
        
        registry.delegate = self
        registry.desiredPushTypes = [.voIP]
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        let token = pushCredentials.token.map { String(format: "%02x", $0) }.joined()
        print("VoIP 푸시 토큰: \(token)")
        // 서버에 토큰 등록
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        // VoIP 푸시 수신
        let uuid = UUID()
        let handle = payload.dictionaryPayload["handle"] as? String ?? "알 수 없음"
        let hasVideo = payload.dictionaryPayload["hasVideo"] as? Bool ?? false
        
        // 반드시 reportNewIncomingCall 호출 (iOS 13+)
        callManager.reportIncomingCall(uuid: uuid, handle: handle, hasVideo: hasVideo)
        
        completion()
    }
}

// MARK: - Main View
struct CallView: View {
    @State private var callManager = CallManager()
    @State private var phoneNumber = ""
    
    var body: some View {
        NavigationStack {
            List {
                // 상태
                Section {
                    LabeledContent("상태", value: callManager.callState)
                }
                
                // 발신
                Section("발신") {
                    TextField("전화번호", text: $phoneNumber)
                        .keyboardType(.phonePad)
                    
                    Button {
                        callManager.startOutgoingCall(to: phoneNumber)
                    } label: {
                        Label("음성 통화", systemImage: "phone.fill")
                    }
                    .disabled(phoneNumber.isEmpty)
                    
                    Button {
                        callManager.startOutgoingCall(to: phoneNumber, hasVideo: true)
                    } label: {
                        Label("영상 통화", systemImage: "video.fill")
                    }
                    .disabled(phoneNumber.isEmpty)
                }
                
                // 활성 통화
                if !callManager.activeCalls.isEmpty {
                    Section("활성 통화") {
                        ForEach(callManager.activeCalls) { call in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(call.handle)
                                        .font(.headline)
                                    Spacer()
                                    if call.isOnHold {
                                        Text("보류 중")
                                            .font(.caption)
                                            .foregroundStyle(.orange)
                                    }
                                }
                                
                                HStack(spacing: 16) {
                                    Button {
                                        callManager.setMute(uuid: call.id, muted: !call.isMuted)
                                    } label: {
                                        Image(systemName: call.isMuted ? "mic.slash.fill" : "mic.fill")
                                    }
                                    
                                    Button {
                                        callManager.setHold(uuid: call.id, onHold: !call.isOnHold)
                                    } label: {
                                        Image(systemName: call.isOnHold ? "play.fill" : "pause.fill")
                                    }
                                    
                                    Spacer()
                                    
                                    Button(role: .destructive) {
                                        callManager.endCall(uuid: call.id)
                                    } label: {
                                        Image(systemName: "phone.down.fill")
                                    }
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }
                }
                
                // 테스트 수신 (개발용)
                #if DEBUG
                Section("테스트") {
                    Button("수신 통화 시뮬레이션") {
                        callManager.reportIncomingCall(
                            uuid: UUID(),
                            handle: "010-1234-5678",
                            hasVideo: false
                        )
                    }
                }
                #endif
            }
            .navigationTitle("VoIP")
        }
    }
}

#Preview {
    CallView()
}
```

## 고급 패턴

### 1. 발신자 식별 (Call Directory Extension)

```swift
// CallDirectoryHandler.swift (Call Directory Extension)
import CallKit

class CallDirectoryHandler: CXCallDirectoryProvider {
    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        // 차단 번호 추가
        addBlockedNumbers(to: context)
        
        // 발신자 식별 추가
        addIdentificationEntries(to: context)
        
        context.completeRequest()
    }
    
    private func addBlockedNumbers(to context: CXCallDirectoryExtensionContext) {
        let blockedNumbers: [CXCallDirectoryPhoneNumber] = [
            821012345678,  // 국가코드 포함, 숫자만
            821087654321
        ]
        
        for number in blockedNumbers.sorted() {
            context.addBlockingEntry(withNextSequentialPhoneNumber: number)
        }
    }
    
    private func addIdentificationEntries(to context: CXCallDirectoryExtensionContext) {
        let phoneNumbers: [CXCallDirectoryPhoneNumber] = [821011112222]
        let labels = ["스팸 의심"]
        
        for (number, label) in zip(phoneNumbers.sorted(), labels) {
            context.addIdentificationEntry(
                withNextSequentialPhoneNumber: number,
                label: label
            )
        }
    }
}
```

### 2. 통화 기록 통합

```swift
// CXProviderConfiguration에서 설정
config.includesCallsInRecents = true

// 통화 종료 시 기록 업데이트
func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
    // 통화 기록에 추가 정보 포함
    let update = CXCallUpdate()
    update.localizedCallerName = "통화 상대 이름"
    
    provider.reportCall(with: action.callUUID, updated: update)
    action.fulfill()
}
```

## 주의사항

1. **VoIP 푸시 필수** (iOS 13+)
   - VoIP 푸시 수신 시 반드시 `reportNewIncomingCall` 호출
   - 미호출 시 앱 종료됨

2. **백그라운드 모드**
   - Voice over IP 필수
   - Remote notifications 권장

3. **오디오 세션**
   - CallKit이 오디오 세션 관리
   - `didActivate`/`didDeactivate`에서 스트림 제어

4. **시뮬레이터 제한**
   - 시스템 통화 UI 미표시
   - 실기기 테스트 필수

5. **중국 제한**
   - 중국에서 CallKit 사용 제한
   - 대체 UI 준비 필요
