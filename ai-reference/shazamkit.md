# ShazamKit AI Reference

> 음악 인식 앱 구현 가이드. 이 문서를 읽고 ShazamKit 코드를 생성할 수 있습니다.

## 개요

ShazamKit은 음악 인식 기능을 제공하는 프레임워크로, Shazam의 방대한 음악 데이터베이스를 활용합니다.
오디오 매칭, 커스텀 카탈로그, 음악 라이브러리 추가 등을 지원합니다.

## 필수 Import

```swift
import ShazamKit
import AVFoundation  // 오디오 캡처용
```

## 프로젝트 설정

### 1. Capability 추가
Xcode > Signing & Capabilities > + ShazamKit

### 2. 권한 설정

```xml
<!-- Info.plist -->
<key>NSMicrophoneUsageDescription</key>
<string>음악을 인식하기 위해 마이크 접근이 필요합니다.</string>
```

## 핵심 구성요소

### 1. SHSession (인식 세션)

```swift
import ShazamKit

let session = SHSession()

// 델리게이트 설정
session.delegate = self

// SHSessionDelegate
func session(_ session: SHSession, didFind match: SHMatch) {
    // 매칭 성공
    if let mediaItem = match.mediaItems.first {
        print("제목: \(mediaItem.title ?? "알 수 없음")")
        print("아티스트: \(mediaItem.artist ?? "알 수 없음")")
    }
}

func session(_ session: SHSession, didNotFindMatchFor signature: SHSignature, error: Error?) {
    // 매칭 실패
}
```

### 2. SHManagedSession (자동 관리 세션)

```swift
// iOS 17+ 간편 API
let managedSession = SHManagedSession()

// 자동으로 마이크 권한 요청 및 오디오 캡처
let result = await managedSession.result()

switch result {
case .match(let match):
    print("찾음: \(match.mediaItems.first?.title ?? "")")
case .noMatch(_):
    print("매칭 실패")
case .error(let error, _):
    print("에러: \(error)")
}
```

### 3. SHMediaItem (인식 결과)

```swift
let item: SHMediaItem

item.title          // 곡 제목
item.artist         // 아티스트
item.artworkURL     // 앨범 아트 URL
item.appleMusicURL  // Apple Music 링크
item.appleMusicID   // Apple Music ID
item.isrc           // 국제 표준 녹음 코드
item.genres         // 장르 배열
item.videoURL       // 뮤직비디오 URL (있을 경우)
```

## 전체 작동 예제

```swift
import SwiftUI
import ShazamKit
import AVFoundation

// MARK: - Shazam Manager
@Observable
class ShazamManager: NSObject {
    var isListening = false
    var matchedSong: SHMediaItem?
    var errorMessage: String?
    var isLoading = false
    
    private var session: SHSession?
    private var audioEngine: AVAudioEngine?
    
    override init() {
        super.init()
        session = SHSession()
        session?.delegate = self
    }
    
    func startListening() {
        guard !isListening else { return }
        
        matchedSong = nil
        errorMessage = nil
        isLoading = true
        
        // 오디오 엔진 설정
        audioEngine = AVAudioEngine()
        let inputNode = audioEngine!.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        // 오디오 탭 설치
        inputNode.installTap(onBus: 0, bufferSize: 2048, format: recordingFormat) { [weak self] buffer, time in
            self?.session?.matchStreamingBuffer(buffer, at: time)
        }
        
        // 오디오 세션 설정
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setActive(true)
            
            try audioEngine?.start()
            isListening = true
        } catch {
            errorMessage = "마이크 접근 실패: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func stopListening() {
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine?.stop()
        audioEngine = nil
        isListening = false
        isLoading = false
    }
}

// MARK: - SHSessionDelegate
extension ShazamManager: SHSessionDelegate {
    func session(_ session: SHSession, didFind match: SHMatch) {
        DispatchQueue.main.async {
            self.matchedSong = match.mediaItems.first
            self.isLoading = false
            self.stopListening()
        }
    }
    
    func session(_ session: SHSession, didNotFindMatchFor signature: SHSignature, error: Error?) {
        DispatchQueue.main.async {
            self.errorMessage = error?.localizedDescription ?? "음악을 찾을 수 없습니다"
            self.isLoading = false
        }
    }
}

// MARK: - Main View
struct ShazamView: View {
    @State private var manager = ShazamManager()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                // 결과 또는 상태 표시
                if let song = manager.matchedSong {
                    SongResultView(song: song)
                } else if manager.isLoading {
                    ListeningView()
                } else if let error = manager.errorMessage {
                    ErrorView(message: error) {
                        manager.errorMessage = nil
                    }
                } else {
                    ReadyView()
                }
                
                Spacer()
                
                // 인식 버튼
                Button {
                    if manager.isListening {
                        manager.stopListening()
                    } else {
                        manager.startListening()
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(manager.isListening ? .red : .blue)
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: manager.isListening ? "stop.fill" : "shazam.logo.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.white)
                    }
                }
                .padding(.bottom, 48)
            }
            .padding()
            .navigationTitle("음악 인식")
        }
    }
}

// MARK: - Song Result View
struct SongResultView: View {
    let song: SHMediaItem
    
    var body: some View {
        VStack(spacing: 16) {
            // 앨범 아트
            AsyncImage(url: song.artworkURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.quaternary)
                    .overlay {
                        Image(systemName: "music.note")
                            .font(.largeTitle)
                    }
            }
            .frame(width: 200, height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 10)
            
            // 곡 정보
            VStack(spacing: 8) {
                Text(song.title ?? "알 수 없는 제목")
                    .font(.title2.bold())
                
                Text(song.artist ?? "알 수 없는 아티스트")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                
                if let genres = song.genres, !genres.isEmpty {
                    Text(genres.joined(separator: ", "))
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                }
            }
            
            // 액션 버튼
            HStack(spacing: 16) {
                if let appleMusicURL = song.appleMusicURL {
                    Link(destination: appleMusicURL) {
                        Label("Apple Music", systemImage: "apple.logo")
                            .padding()
                            .background(.pink)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                }
                
                Button {
                    addToShazamLibrary(song)
                } label: {
                    Label("라이브러리 추가", systemImage: "plus")
                        .padding()
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
        }
    }
    
    func addToShazamLibrary(_ item: SHMediaItem) {
        Task {
            do {
                try await SHMediaLibrary.default.add([item])
            } catch {
                print("라이브러리 추가 실패: \(error)")
            }
        }
    }
}

// MARK: - Listening View
struct ListeningView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                ForEach(0..<3) { i in
                    Circle()
                        .stroke(lineWidth: 2)
                        .foregroundStyle(.blue.opacity(0.5))
                        .scaleEffect(isAnimating ? 2 : 1)
                        .opacity(isAnimating ? 0 : 1)
                        .animation(
                            .easeOut(duration: 1.5)
                            .repeatForever(autoreverses: false)
                            .delay(Double(i) * 0.5),
                            value: isAnimating
                        )
                }
                
                Image(systemName: "waveform")
                    .font(.system(size: 40))
                    .foregroundStyle(.blue)
            }
            .frame(width: 120, height: 120)
            
            Text("듣는 중...")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .onAppear { isAnimating = true }
    }
}

// MARK: - Ready View
struct ReadyView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "shazam.logo")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
            
            Text("버튼을 눌러 음악을 인식하세요")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Error View
struct ErrorView: View {
    let message: String
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundStyle(.orange)
            
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            
            Button("다시 시도", action: onDismiss)
                .buttonStyle(.bordered)
        }
    }
}

#Preview {
    ShazamView()
}
```

## 고급 패턴

### 1. SHManagedSession (iOS 17+)

```swift
// 간편한 자동 관리 세션
@Observable
class SimpleShazamManager {
    var result: SHManagedSession.Result?
    private let session = SHManagedSession()
    
    func recognize() async {
        // 자동으로 마이크 권한 요청 및 오디오 캡처
        result = await session.result()
    }
    
    func cancel() {
        session.cancel()
    }
}

// 사용
struct SimpleShazamView: View {
    @State private var manager = SimpleShazamManager()
    
    var body: some View {
        Button("인식") {
            Task {
                await manager.recognize()
            }
        }
    }
}
```

### 2. 커스텀 카탈로그

```swift
// 자체 오디오 파일로 커스텀 카탈로그 생성
func createCustomCatalog() async throws -> SHCustomCatalog {
    let catalog = SHCustomCatalog()
    
    // 오디오 파일에서 시그니처 생성
    let audioURL = Bundle.main.url(forResource: "mysong", withExtension: "mp3")!
    let signatureGenerator = SHSignatureGenerator()
    
    try await signatureGenerator.generateSignature(from: audioURL)
    
    if let signature = signatureGenerator.signature {
        // 메타데이터 연결
        let mediaItem = SHMediaItem(properties: [
            .title: "My Song",
            .artist: "My Artist",
            .artworkURL: URL(string: "https://...")!
        ])
        
        try catalog.addReferenceSignature(signature, representing: [mediaItem])
    }
    
    return catalog
}

// 커스텀 카탈로그로 세션 생성
let session = SHSession(catalog: customCatalog)
```

### 3. 백그라운드 인식

```swift
// Scene Delegate에서 지속적인 인식
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    let session = SHManagedSession()
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        Task {
            // 계속 인식
            for await result in session.results {
                switch result {
                case .match(let match):
                    handleMatch(match)
                case .noMatch:
                    continue
                case .error(let error, _):
                    print("Error: \(error)")
                }
            }
        }
    }
}
```

### 4. 파일에서 인식

```swift
// 녹음된 오디오 파일에서 인식
func recognizeFromFile(url: URL) async throws -> SHMatch? {
    let session = SHSession()
    
    // 파일에서 시그니처 생성
    let generator = SHSignatureGenerator()
    try await generator.generateSignature(from: url)
    
    guard let signature = generator.signature else { return nil }
    
    // 매칭 요청
    return try await withCheckedThrowingContinuation { continuation in
        session.delegate = SignatureDelegate { match in
            continuation.resume(returning: match)
        } onError: { error in
            continuation.resume(throwing: error ?? ShazamError.unknown)
        }
        
        session.match(signature)
    }
}
```

### 5. Shazam 라이브러리 관리

```swift
// 라이브러리에 곡 추가
func addToLibrary(_ items: [SHMediaItem]) async throws {
    try await SHMediaLibrary.default.add(items)
}

// 라이브러리 항목 읽기 (앱에서 추가한 것만)
func getLibraryItems() async -> [SHMediaItem] {
    var items: [SHMediaItem] = []
    
    for await itemCollection in SHMediaLibrary.default.items {
        items.append(contentsOf: itemCollection)
    }
    
    return items
}
```

## 주의사항

1. **마이크 권한**
   ```swift
   // 권한 상태 확인
   switch AVAudioSession.sharedInstance().recordPermission {
   case .granted:
       startListening()
   case .denied:
       showPermissionAlert()
   case .undetermined:
       AVAudioSession.sharedInstance().requestRecordPermission { granted in
           // 처리
       }
   }
   ```

2. **API 호출 제한**
   - Shazam 카탈로그 쿼리에 제한 있음
   - 무료 티어 제한 확인 필요

3. **커스텀 카탈로그**
   - 최대 100개 레퍼런스 시그니처
   - 로컬 저장 또는 공유 가능

4. **백그라운드**
   - 백그라운드 오디오 권한 필요
   - 배터리 소모 주의

5. **시뮬레이터**
   - 마이크 입력 제한
   - 파일 기반 테스트 권장
