# Core NFC AI Reference

> NFC 태그 읽기/쓰기 가이드. 이 문서를 읽고 Core NFC 코드를 생성할 수 있습니다.

## 개요

Core NFC는 iPhone의 NFC 리더를 사용해 NDEF 태그를 읽고 쓸 수 있는 프레임워크입니다.
URL, 텍스트, 연락처 등 다양한 데이터 형식을 지원하며, ISO 7816, ISO 15693, FeliCa 태그도 지원합니다.

## 필수 Import

```swift
import CoreNFC
```

## 프로젝트 설정

### 1. Capability 추가
Xcode > Signing & Capabilities > + Near Field Communication Tag Reading

### 2. Info.plist 설정

```xml
<!-- NFC 사용 설명 -->
<key>NFCReaderUsageDescription</key>
<string>NFC 태그를 읽기 위해 필요합니다.</string>

<!-- 읽을 태그 타입 (ISO 7816 등) -->
<key>com.apple.developer.nfc.readersession.iso7816.select-identifiers</key>
<array>
    <string>A0000002471001</string>
</array>

<!-- 펠리카 시스템 코드 -->
<key>com.apple.developer.nfc.readersession.felica.systemcodes</key>
<array>
    <string>12FC</string>
</array>
```

## 핵심 구성요소

### 1. NFCNDEFReaderSession (NDEF 읽기)

```swift
import CoreNFC

class NFCReader: NSObject, NFCNDEFReaderSessionDelegate {
    var session: NFCNDEFReaderSession?
    
    func startScanning() {
        guard NFCNDEFReaderSession.readingAvailable else {
            print("NFC를 사용할 수 없습니다")
            return
        }
        
        session = NFCNDEFReaderSession(
            delegate: self,
            queue: nil,
            invalidateAfterFirstRead: true
        )
        session?.alertMessage = "NFC 태그에 iPhone을 가까이 대세요"
        session?.begin()
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        for message in messages {
            for record in message.records {
                // 레코드 처리
            }
        }
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print("세션 종료: \(error.localizedDescription)")
    }
}
```

### 2. NFCNDEFMessage (NDEF 메시지)

```swift
// NDEF 레코드 타입
let record = message.records.first!

record.typeNameFormat  // TNF (well-known, media 등)
record.type           // 레코드 타입 (T, U, Sp 등)
record.identifier     // 식별자
record.payload        // 실제 데이터

// URL 파싱
if let url = record.wellKnownTypeURIPayload() {
    print("URL: \(url)")
}

// 텍스트 파싱
if let (text, locale) = record.wellKnownTypeTextPayload() {
    print("텍스트: \(text), 언어: \(locale)")
}
```

### 3. NFCTagReaderSession (고급 태그)

```swift
class AdvancedNFCReader: NSObject, NFCTagReaderSessionDelegate {
    var session: NFCTagReaderSession?
    
    func startScanning() {
        session = NFCTagReaderSession(
            pollingOption: [.iso14443, .iso15693, .iso18092],
            delegate: self
        )
        session?.alertMessage = "태그를 스캔하세요"
        session?.begin()
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        guard let tag = tags.first else { return }
        
        session.connect(to: tag) { error in
            if let error = error {
                session.invalidate(errorMessage: "연결 실패")
                return
            }
            
            switch tag {
            case .miFare(let miFareTag):
                self.handleMiFare(miFareTag)
            case .iso7816(let iso7816Tag):
                self.handleISO7816(iso7816Tag)
            case .iso15693(let iso15693Tag):
                self.handleISO15693(iso15693Tag)
            case .feliCa(let feliCaTag):
                self.handleFeliCa(feliCaTag)
            @unknown default:
                break
            }
        }
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        print("에러: \(error)")
    }
    
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        print("NFC 세션 활성화")
    }
}
```

## 전체 작동 예제

```swift
import SwiftUI
import CoreNFC

// MARK: - NFC Manager
@Observable
class NFCManager: NSObject {
    var scannedMessage: String = ""
    var scannedURL: URL?
    var isScanning = false
    var errorMessage: String?
    var isNFCAvailable: Bool {
        NFCNDEFReaderSession.readingAvailable
    }
    
    private var session: NFCNDEFReaderSession?
    private var writeSession: NFCNDEFReaderSession?
    private var messageToWrite: NFCNDEFMessage?
    
    // MARK: - 읽기
    func startScanning() {
        guard isNFCAvailable else {
            errorMessage = "이 기기는 NFC를 지원하지 않습니다"
            return
        }
        
        scannedMessage = ""
        scannedURL = nil
        errorMessage = nil
        
        session = NFCNDEFReaderSession(
            delegate: self,
            queue: nil,
            invalidateAfterFirstRead: true
        )
        session?.alertMessage = "NFC 태그에 iPhone을 가까이 대세요"
        session?.begin()
        isScanning = true
    }
    
    // MARK: - 쓰기
    func writeURL(_ url: URL) {
        guard isNFCAvailable else { return }
        
        // URL 레코드 생성
        guard let payload = NFCNDEFPayload.wellKnownTypeURIPayload(url: url) else { return }
        messageToWrite = NFCNDEFMessage(records: [payload])
        
        writeSession = NFCNDEFReaderSession(
            delegate: self,
            queue: nil,
            invalidateAfterFirstRead: false
        )
        writeSession?.alertMessage = "쓸 태그에 iPhone을 가까이 대세요"
        writeSession?.begin()
        isScanning = true
    }
    
    func writeText(_ text: String) {
        guard isNFCAvailable else { return }
        
        // 텍스트 레코드 생성
        guard let payload = NFCNDEFPayload.wellKnownTypeTextPayload(
            string: text,
            locale: Locale.current
        ) else { return }
        
        messageToWrite = NFCNDEFMessage(records: [payload])
        
        writeSession = NFCNDEFReaderSession(
            delegate: self,
            queue: nil,
            invalidateAfterFirstRead: false
        )
        writeSession?.alertMessage = "쓸 태그에 iPhone을 가까이 대세요"
        writeSession?.begin()
        isScanning = true
    }
}

// MARK: - NFCNDEFReaderSessionDelegate
extension NFCManager: NFCNDEFReaderSessionDelegate {
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        print("NFC 세션 활성화")
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        // 읽기 전용 모드
        for message in messages {
            processMessage(message)
        }
        
        DispatchQueue.main.async {
            self.isScanning = false
        }
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCTag]) {
        guard let tag = tags.first else {
            session.invalidate(errorMessage: "태그를 찾을 수 없습니다")
            return
        }
        
        session.connect(to: tag) { error in
            if let error = error {
                session.invalidate(errorMessage: "연결 실패: \(error.localizedDescription)")
                return
            }
            
            // 태그 타입에 따라 NDEF 핸들 가져오기
            var ndefTag: NFCNDEFTag?
            switch tag {
            case .miFare(let miFareTag):
                ndefTag = miFareTag
            case .iso7816(let iso7816Tag):
                ndefTag = iso7816Tag
            case .iso15693(let iso15693Tag):
                ndefTag = iso15693Tag
            case .feliCa(let feliCaTag):
                ndefTag = feliCaTag
            @unknown default:
                session.invalidate(errorMessage: "지원하지 않는 태그")
                return
            }
            
            guard let ndef = ndefTag else { return }
            
            // 쓰기 모드
            if let message = self.messageToWrite {
                self.writeToTag(ndef, message: message, session: session)
            } else {
                // 읽기 모드
                self.readFromTag(ndef, session: session)
            }
        }
    }
    
    private func readFromTag(_ tag: NFCNDEFTag, session: NFCNDEFReaderSession) {
        tag.readNDEF { message, error in
            if let error = error {
                session.invalidate(errorMessage: "읽기 실패: \(error.localizedDescription)")
                return
            }
            
            if let message = message {
                self.processMessage(message)
                session.alertMessage = "태그를 읽었습니다!"
                session.invalidate()
            }
        }
    }
    
    private func writeToTag(_ tag: NFCNDEFTag, message: NFCNDEFMessage, session: NFCNDEFReaderSession) {
        tag.queryNDEFStatus { status, capacity, error in
            if let error = error {
                session.invalidate(errorMessage: "상태 확인 실패: \(error.localizedDescription)")
                return
            }
            
            switch status {
            case .notSupported:
                session.invalidate(errorMessage: "NDEF를 지원하지 않는 태그입니다")
            case .readOnly:
                session.invalidate(errorMessage: "읽기 전용 태그입니다")
            case .readWrite:
                tag.writeNDEF(message) { error in
                    if let error = error {
                        session.invalidate(errorMessage: "쓰기 실패: \(error.localizedDescription)")
                    } else {
                        session.alertMessage = "쓰기 완료!"
                        session.invalidate()
                        DispatchQueue.main.async {
                            self.messageToWrite = nil
                        }
                    }
                }
            @unknown default:
                session.invalidate(errorMessage: "알 수 없는 상태")
            }
            
            DispatchQueue.main.async {
                self.isScanning = false
            }
        }
    }
    
    private func processMessage(_ message: NFCNDEFMessage) {
        var texts: [String] = []
        
        for record in message.records {
            // URL
            if let url = record.wellKnownTypeURIPayload() {
                DispatchQueue.main.async {
                    self.scannedURL = url
                }
                texts.append("URL: \(url.absoluteString)")
            }
            
            // 텍스트
            if let (text, locale) = record.wellKnownTypeTextPayload() {
                texts.append("[\(locale.identifier)] \(text)")
            }
        }
        
        DispatchQueue.main.async {
            self.scannedMessage = texts.joined(separator: "\n")
        }
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        DispatchQueue.main.async {
            self.isScanning = false
            
            if let nfcError = error as? NFCReaderError,
               nfcError.code != .readerSessionInvalidationErrorFirstNDEFTagRead &&
               nfcError.code != .readerSessionInvalidationErrorUserCanceled {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - Main View
struct NFCView: View {
    @State private var manager = NFCManager()
    @State private var textToWrite = ""
    @State private var urlToWrite = ""
    @State private var showWriteSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                // 상태 섹션
                Section {
                    HStack {
                        Image(systemName: manager.isNFCAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(manager.isNFCAvailable ? .green : .red)
                        Text(manager.isNFCAvailable ? "NFC 사용 가능" : "NFC 사용 불가")
                    }
                }
                
                // 읽기 결과
                if !manager.scannedMessage.isEmpty {
                    Section("읽은 내용") {
                        Text(manager.scannedMessage)
                        
                        if let url = manager.scannedURL {
                            Link("링크 열기", destination: url)
                        }
                    }
                }
                
                // 에러
                if let error = manager.errorMessage {
                    Section {
                        Label(error, systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.red)
                    }
                }
                
                // 액션
                Section {
                    Button {
                        manager.startScanning()
                    } label: {
                        Label("태그 읽기", systemImage: "wave.3.right")
                    }
                    .disabled(manager.isScanning)
                    
                    Button {
                        showWriteSheet = true
                    } label: {
                        Label("태그에 쓰기", systemImage: "square.and.pencil")
                    }
                    .disabled(manager.isScanning)
                }
            }
            .navigationTitle("NFC")
            .overlay {
                if manager.isScanning {
                    VStack {
                        ProgressView()
                        Text("스캔 중...")
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .sheet(isPresented: $showWriteSheet) {
                NavigationStack {
                    Form {
                        Section("텍스트 쓰기") {
                            TextField("텍스트", text: $textToWrite)
                            Button("쓰기") {
                                manager.writeText(textToWrite)
                                showWriteSheet = false
                            }
                            .disabled(textToWrite.isEmpty)
                        }
                        
                        Section("URL 쓰기") {
                            TextField("URL", text: $urlToWrite)
                                .keyboardType(.URL)
                                .autocapitalization(.none)
                            Button("쓰기") {
                                if let url = URL(string: urlToWrite) {
                                    manager.writeURL(url)
                                    showWriteSheet = false
                                }
                            }
                            .disabled(URL(string: urlToWrite) == nil)
                        }
                    }
                    .navigationTitle("태그에 쓰기")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("취소") {
                                showWriteSheet = false
                            }
                        }
                    }
                }
                .presentationDetents([.medium])
            }
        }
    }
}

#Preview {
    NFCView()
}
```

## 고급 패턴

### 1. 백그라운드 태그 읽기

```swift
// AppDelegate에서 설정
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // 백그라운드 NDEF 감지는 자동
    return true
}

// SceneDelegate에서 처리
func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
    guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
          let url = userActivity.webpageURL else { return }
    
    // NFC 태그의 URL 처리
    handleNFCURL(url)
}
```

### 2. ISO 7816 스마트카드

```swift
func handleISO7816(_ tag: NFCISO7816Tag) {
    // AID 선택
    let selectAID = NFCISO7816APDU(
        instructionClass: 0x00,
        instructionCode: 0xA4,
        p1Parameter: 0x04,
        p2Parameter: 0x00,
        data: Data([0xA0, 0x00, 0x00, 0x02, 0x47, 0x10, 0x01]),
        expectedResponseLength: -1
    )
    
    tag.sendCommand(apdu: selectAID) { data, sw1, sw2, error in
        if sw1 == 0x90 && sw2 == 0x00 {
            print("선택 성공, 데이터: \(data)")
        }
    }
}
```

### 3. FeliCa (Suica 등)

```swift
func handleFeliCa(_ tag: NFCFeliCaTag) {
    let serviceCode = Data([0x00, 0x0B])  // 서비스 코드
    
    tag.readWithoutEncryption(
        serviceCodeList: [serviceCode],
        blockList: [Data([0x80, 0x00])]
    ) { status1, status2, blocks, error in
        if let error = error {
            print("읽기 실패: \(error)")
            return
        }
        
        for block in blocks {
            print("블록 데이터: \(block.hexString)")
        }
    }
}
```

## 주의사항

1. **기기 호환성**
   ```swift
   // iPhone 7 이상, iOS 11+
   guard NFCNDEFReaderSession.readingAvailable else {
       // NFC 미지원
       return
   }
   ```

2. **세션 제한**
   - 한 번에 하나의 NFC 세션만 가능
   - 60초 타임아웃
   - 포그라운드에서만 동작

3. **태그 타입**
   - NDEF: 대부분의 NFC 태그
   - ISO 7816: 스마트카드, 신용카드
   - FeliCa: 일본 교통카드 (Suica)
   - MIFARE: 접근카드

4. **앱 백그라운드 태그 읽기**
   - iOS 12+에서 지원
   - Universal Links 또는 URL Scheme 사용
   - entitlements 필요

5. **시뮬레이터**
   - NFC 미지원
   - 실기기 테스트 필수
