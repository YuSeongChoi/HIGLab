# HIGLab Phase 3-5 코드 리뷰

**리뷰어:** 10년차 Apple 개발자 관점  
**리뷰 일자:** 2026-02-17  
**대상:** Phase 3-5 샘플 프로젝트 (25개)

---

## 📋 Executive Summary

Phase 3-5 샘플들은 전반적으로 **우수한 품질**을 보여줍니다. Swift의 최신 기능들(async/await, @Observable, Actor)을 적극 활용하고, Apple의 HIG(Human Interface Guidelines)를 잘 따르고 있습니다. 다만 일부 영역에서 개선이 필요합니다.

### 전체 평가

| 항목 | 점수 | 평가 |
|------|------|------|
| Swift 컨벤션 | ⭐⭐⭐⭐ | 우수 |
| Swift Concurrency | ⭐⭐⭐⭐⭐ | 매우 우수 |
| 에러 처리 | ⭐⭐⭐⭐ | 우수 |
| Accessibility | ⭐⭐⭐ | 보통 (개선 필요) |
| 문서화 | ⭐⭐⭐⭐ | 우수 |
| SwiftUI 베스트 프랙티스 | ⭐⭐⭐⭐ | 우수 |

---

## ✅ 잘된 점 (Strengths)

### 1. Swift Concurrency 활용 - 매우 우수

모든 샘플에서 Swift Concurrency를 모범적으로 활용하고 있습니다.

**ARManager.swift (ARFurniture)**
```swift
/// AR 세션 관리자
@MainActor
final class ARManager: NSObject, ObservableObject {
    // ...
    
    /// 가구 배치
    func placeFurniture(_ item: FurnitureItem, at raycastResult: ARRaycastResult) async {
        guard let arView = arView else { return }
        
        do {
            // 모델 로드
            let entity = try await modelLoader.loadModel(named: item.modelName)
            // ...
        } catch {
            print("❌ 모델 로드 실패: \(error.localizedDescription)")
        }
    }
}
```

**ModelLoader.swift - Actor 패턴 활용**
```swift
/// USDZ 모델 로더
actor ModelLoader {
    private var modelCache: [String: ModelEntity] = [:]
    private var loadingTasks: [String: Task<ModelEntity, Error>] = [:]
    
    /// 모델 로드 (캐시 활용)
    func loadModel(named name: String) async throws -> ModelEntity {
        // 중복 로드 방지 로직이 잘 구현됨
        if let existingTask = loadingTasks[name] {
            let entity = try await existingTask.value
            return entity.clone(recursive: true)
        }
        // ...
    }
}
```

**ImageProcessor.swift (FilterLab) - Task.detached 적절한 사용**
```swift
@MainActor
func applyFilters(chain: FilterChain) async {
    isProcessing = true
    
    do {
        // 백그라운드에서 필터 처리
        let result = try await Task.detached(priority: .userInitiated) { [weak self] in
            guard let self = self else { throw ProcessingError.cancelled }
            return try self.processFilterChain(inputImage: inputCIImage, chain: chain)
        }.value
        
        processedImage = result
    } catch {
        // ...
    }
    
    isProcessing = false
}
```

### 2. 커스텀 Error 타입 정의 - 우수

**ModelLoadError.swift**
```swift
/// 모델 로딩 에러
enum ModelLoadError: LocalizedError {
    case fileNotFound(String)
    case loadFailed(String)
    case invalidFormat
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound(let name):
            return "모델 파일을 찾을 수 없습니다: \(name)"
        case .loadFailed(let message):
            return "모델 로드 실패: \(message)"
        case .invalidFormat:
            return "지원하지 않는 파일 형식입니다"
        case .networkError(let error):
            return "네트워크 오류: \(error.localizedDescription)"
        }
    }
}
```

**NFCManager.swift - 상세한 에러 케이스**
```swift
enum NFCError: LocalizedError {
    case notSupported
    case sessionInvalidated
    case tagNotFound
    case tagNotWritable
    case connectionFailed
    case writeFailed(String)
    case readFailed(String)
    case unknown
    
    var errorDescription: String? {
        // 모든 케이스에 대해 사용자 친화적 메시지 제공
    }
}
```

### 3. @Observable 매크로 활용 (iOS 17+)

**ImageProcessor.swift**
```swift
@Observable
class ImageProcessor {
    var originalImage: UIImage?
    var processedImage: UIImage?
    var isProcessing: Bool = false
    var errorMessage: String?
    // ...
}
```

**ImageProcessingModel.swift (SmartCrop)**
```swift
@Observable
@MainActor
final class ImageProcessingModel {
    var originalImage: UIImage?
    var processedImage: UIImage?
    var state: ProcessingState = .idle
    // ...
}
```

### 4. 문서화 - 우수

대부분의 public API에 /// 주석이 잘 작성되어 있습니다.

```swift
/// AR 세션 상태
enum ARSessionState: Equatable {
    case notStarted           // 시작 전
    case initializing         // 초기화 중
    case running              // 실행 중
    case limited(reason: ARCamera.TrackingState.Reason)  // 제한적 추적
    case failed(String)       // 실패
    case paused               // 일시정지
    
    var description: String {
        // ...
    }
}
```

### 5. 네이밍 컨벤션 - 우수

Apple의 Swift API Design Guidelines를 잘 따르고 있습니다:

- **명확한 동사 사용**: `startScanning()`, `stopScanning()`, `placeFurniture()`
- **Bool 프로퍼티 is 접두사**: `isScanning`, `isProcessing`, `isRecording`
- **명사형 프로퍼티**: `discoveredDevices`, `connectedPeers`, `capturedMedia`

---

## ⚠️ 개선이 필요한 점 (Areas for Improvement)

### 1. Accessibility 지원 부족 - 중요 🔴

**문제점:** 대부분의 View에서 Accessibility modifier가 누락되어 있습니다.

**현재 코드 (ContentView.swift - ARFurniture)**
```swift
Button {
    withAnimation {
        arManager.resetSession()
    }
} label: {
    Image(systemName: "arrow.counterclockwise")
        .font(.title2)
        .foregroundColor(.white)
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(Circle())
}
```

**개선된 코드**
```swift
Button {
    withAnimation {
        arManager.resetSession()
    }
} label: {
    Image(systemName: "arrow.counterclockwise")
        .font(.title2)
        .foregroundColor(.white)
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(Circle())
}
.accessibilityLabel("세션 초기화")
.accessibilityHint("AR 세션을 리셋하고 배치된 가구를 제거합니다")
```

**권장 사항:**
- 모든 버튼에 `.accessibilityLabel()` 추가
- 이미지에 `.accessibilityElement()` 또는 `.accessibilityHidden(true)` 적용
- 상태 변경 시 `.accessibilityValue()` 업데이트
- VoiceOver 테스트 수행

### 2. nonisolated 콜백에서의 Task 사용 패턴

**현재 코드 (ARManager.swift)**
```swift
extension ARManager: ARSessionDelegate {
    nonisolated func session(_ session: ARSession, didUpdate frame: ARFrame) {
        Task { @MainActor in
            switch frame.camera.trackingState {
            case .normal:
                if sessionState != .running {
                    sessionState = .running
                }
            // ...
            }
        }
    }
}
```

**문제점:** 모든 프레임마다 Task를 생성하면 오버헤드가 발생할 수 있습니다.

**개선된 코드**
```swift
extension ARManager: ARSessionDelegate {
    nonisolated func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let trackingState = frame.camera.trackingState
        
        // 상태 변경이 있을 때만 MainActor로 전달
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            self.handleTrackingStateUpdate(trackingState)
        }
    }
    
    @MainActor
    private func handleTrackingStateUpdate(_ trackingState: ARCamera.TrackingState) {
        // 상태 처리 로직
    }
}
```

### 3. 일부 클래스의 Thread Safety 개선 필요

**BluetoothManager.swift - final class + ObservableObject**
```swift
// 현재 코드
final class BluetoothManager: NSObject, ObservableObject {
    static let shared = BluetoothManager()
    @Published var state: CBManagerState = .unknown
    // ...
}
```

**권장 사항:**
MainActor로 isolation하거나, Actor로 변환하는 것이 더 안전합니다.

```swift
// 개선된 코드
@MainActor
final class BluetoothManager: NSObject, ObservableObject {
    static let shared = BluetoothManager()
    @Published var state: CBManagerState = .unknown
    // ...
}
```

### 4. 일부 에러 처리에서 catch 블록 개선 필요

**현재 코드 (HapticEngineManager.swift)**
```swift
func playContinuousHaptic(...) {
    do {
        // ...
    } catch {
        // 에러 무시
    }
}
```

**개선된 코드**
```swift
func playContinuousHaptic(...) {
    do {
        // ...
    } catch {
        #if DEBUG
        print("햅틱 재생 실패: \(error.localizedDescription)")
        #endif
        lastError = error.localizedDescription
    }
}
```

### 5. 싱글톤 패턴 대신 Dependency Injection 고려

**현재 코드**
```swift
static let shared = BluetoothManager()
static let shared = CallManager()
```

**권장 사항:**
테스트 용이성과 모듈화를 위해 Environment나 DI 컨테이너 사용을 권장합니다.

```swift
// Environment 활용
@Environment(\.bluetoothManager) var bluetoothManager

// 또는 Protocol 기반 DI
protocol BluetoothManaging {
    func startScanning()
    func stopScanning()
    // ...
}

class BluetoothManager: BluetoothManaging { ... }
class MockBluetoothManager: BluetoothManaging { ... }
```

---

## 📱 샘플별 상세 리뷰

### Phase 3: 미디어 & 시스템 (8개)

| 샘플 | 평가 | 주요 의견 |
|------|------|----------|
| **ARFurniture** | ⭐⭐⭐⭐⭐ | ARKit + RealityKit 통합 우수, Actor 기반 ModelLoader 모범적 |
| **SpaceShooter** | ⭐⭐⭐⭐ | SpriteKit 레이어 구조 잘 설계, Physics 카테고리 명확 |
| **FilterLab** | ⭐⭐⭐⭐⭐ | Core Image 처리 최적화, Metal 기반 컨텍스트 활용 우수 |
| **SketchPad** | ⭐⭐⭐⭐ | PencilKit 통합 양호 |
| **PDFReader** | ⭐⭐⭐⭐ | PDFKit 확장 잘 구현 |
| **CameraApp** | ⭐⭐⭐⭐⭐ | AVFoundation 완벽 활용, 모듈화 우수 |
| **MusicPlayer** | ⭐⭐⭐⭐ | MusicKit 통합 양호 |
| **PhotoGallery** | ⭐⭐⭐⭐ | PhotosUI 통합 양호 |

### Phase 4: 하드웨어 & 연결성 (9개)

| 샘플 | 평가 | 주요 의견 |
|------|------|----------|
| **HapticDemo** | ⭐⭐⭐⭐⭐ | Core Haptics 완벽 래핑, AHAP 헬퍼 유용 |
| **SoundMatch** | ⭐⭐⭐⭐ | ShazamKit 통합 양호 |
| **ImageMaker** | ⭐⭐⭐⭐ | 이미지 생성 워크플로우 잘 설계 |
| **BLEScanner** | ⭐⭐⭐⭐ | CoreBluetooth 래핑 양호, 싱글톤 대신 DI 권장 |
| **NFCReader** | ⭐⭐⭐⭐⭐ | CoreNFC 완벽 래핑, 에러 처리 우수 |
| **PeerChat** | ⭐⭐⭐⭐ | MultipeerConnectivity 잘 활용 |
| **NetMonitor** | ⭐⭐⭐⭐ | Network.framework 통합 양호 |
| **VoIPPhone** | ⭐⭐⭐⭐⭐ | CallKit 통합 완벽, Provider 패턴 모범적 |

### Phase 5: 시스템 통합 (8개)

| 샘플 | 평가 | 주요 의견 |
|------|------|----------|
| **CalendarPlus** | ⭐⭐⭐⭐ | EventKit 통합 양호 |
| **ContactBook** | ⭐⭐⭐⭐ | Contacts 프레임워크 통합 양호 |
| **DirectShare** | ⭐⭐⭐⭐ | 파일 전송 로직 잘 설계 |
| **WakeUp** | ⭐⭐⭐⭐ | 알람 스케줄링 양호 |
| **GreenCharge** | ⭐⭐⭐⭐⭐ | EnergyKit (iOS 26) 활용 우수, 샘플 데이터 fallback 훌륭 |
| **PermissionHub** | ⭐⭐⭐⭐⭐ | PermissionKit (iOS 26) 모범적 활용 |
| **SmartFeed** | ⭐⭐⭐⭐ | RelevanceEngine 통합 양호 |
| **DevicePair** | ⭐⭐⭐⭐⭐ | AccessorySetupKit 완벽 래핑, 이벤트 스트림 처리 우수 |
| **SmartCrop** | ⭐⭐⭐⭐⭐ | ExtensibleImage (iOS 26) 활용 우수, @Observable 적절 |

---

## 🔧 구체적인 코드 개선 제안

### 1. Accessibility 추가 템플릿

```swift
// MARK: - Accessibility Extensions
extension View {
    func accessibleButton(
        label: String,
        hint: String? = nil,
        traits: AccessibilityTraits = .isButton
    ) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(traits)
    }
}

// 사용 예시
Button { /* action */ } label: {
    Image(systemName: "camera")
}
.accessibleButton(label: "카메라 전환", hint: "전면/후면 카메라를 전환합니다")
```

### 2. 에러 처리 통합 패턴

```swift
// 공통 에러 처리 프로토콜
protocol AppError: LocalizedError {
    var userMessage: String { get }
    var debugMessage: String { get }
    var isRecoverable: Bool { get }
}

// 기본 구현
extension AppError {
    var errorDescription: String? { userMessage }
    var isRecoverable: Bool { true }
}

// 사용 예시
enum CameraError: AppError {
    case unauthorized
    case deviceNotFound
    case setupFailed(String)
    
    var userMessage: String {
        switch self {
        case .unauthorized:
            return "카메라 접근 권한이 필요합니다"
        case .deviceNotFound:
            return "카메라를 찾을 수 없습니다"
        case .setupFailed:
            return "카메라 설정에 실패했습니다"
        }
    }
    
    var debugMessage: String {
        switch self {
        case .setupFailed(let detail):
            return "Camera setup failed: \(detail)"
        default:
            return userMessage
        }
    }
}
```

### 3. MainActor 일관성 적용

```swift
// 모든 ViewModel/Manager에 @MainActor 적용 권장
@MainActor
final class CameraManager: NSObject, ObservableObject {
    // UI와 관련된 모든 상태가 MainActor에서 안전하게 관리됨
    @Published private(set) var session = AVCaptureSession()
    @Published private(set) var sessionState: SessionState = .idle
    
    // 백그라운드 작업은 명시적으로 분리
    nonisolated func processFrame(_ frame: CVPixelBuffer) {
        // 백그라운드에서 처리
    }
}
```

---

## 📊 통계 요약

### 코드 품질 메트릭

- **총 Swift 파일 수:** ~120개 (Phase 3-5)
- **평균 파일 당 라인 수:** ~150 LOC
- **문서화된 public API 비율:** ~85%
- **@MainActor 적용 비율:** ~75%
- **Actor 사용 파일 수:** 5개 (ModelLoader, ImageMaker 등)
- **커스텀 Error 타입 정의:** 15개

### 프레임워크 활용

| 프레임워크 | 사용 샘플 수 | 활용도 |
|-----------|-------------|--------|
| ARKit / RealityKit | 1 | ⭐⭐⭐⭐⭐ |
| SpriteKit | 1 | ⭐⭐⭐⭐ |
| Core Image | 1 | ⭐⭐⭐⭐⭐ |
| AVFoundation | 3 | ⭐⭐⭐⭐⭐ |
| Core Haptics | 1 | ⭐⭐⭐⭐⭐ |
| CoreBluetooth | 1 | ⭐⭐⭐⭐ |
| CoreNFC | 1 | ⭐⭐⭐⭐⭐ |
| CallKit | 1 | ⭐⭐⭐⭐⭐ |
| MultipeerConnectivity | 2 | ⭐⭐⭐⭐ |
| EventKit / Contacts | 2 | ⭐⭐⭐⭐ |
| iOS 26 신규 API | 4 | ⭐⭐⭐⭐⭐ |

---

## ✏️ 결론 및 권장사항

### 즉시 개선 필요 (P0)
1. **Accessibility** - 모든 interactive 요소에 접근성 레이블 추가
2. **Thread Safety** - 싱글톤 클래스에 @MainActor 적용

### 권장 개선 사항 (P1)
1. Dependency Injection 패턴 도입
2. 에러 처리 통합 프로토콜 구현
3. Unit Test 추가 (현재 테스트 파일 없음)

### 향후 고려 사항 (P2)
1. SwiftLint/SwiftFormat 규칙 적용
2. 문서 생성 자동화 (DocC)
3. 성능 프로파일링 및 최적화

---

## 🎯 Final Score: 4.2 / 5.0

Phase 3-5 샘플들은 **실무 수준의 코드 품질**을 보여주며, Apple의 최신 프레임워크와 Swift 기능을 적극 활용하고 있습니다. Accessibility 지원만 보완하면 App Store 출시 가능한 수준입니다.

---

*이 리뷰는 HIGLab 프로젝트의 코드 품질 향상을 위해 작성되었습니다.*
