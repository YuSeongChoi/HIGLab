# LocalAuthentication AI Reference

> Face ID / Touch ID 생체 인증 가이드. 이 문서를 읽고 생체 인증 코드를 생성할 수 있습니다.

## 개요

LocalAuthentication은 Face ID, Touch ID, 기기 암호를 통한 
사용자 인증을 제공하는 프레임워크입니다.

## 필수 Import

```swift
import LocalAuthentication
```

## 프로젝트 설정 (Info.plist)

```xml
<key>NSFaceIDUsageDescription</key>
<string>앱 잠금 해제를 위해 Face ID를 사용합니다.</string>
```

## 핵심 구성요소

### 1. LAContext

```swift
let context = LAContext()

// 생체 인증 가능 여부 확인
var error: NSError?
if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
    // 생체 인증 가능
} else {
    // 불가능 (error로 이유 확인)
}

// 생체 인증 타입 확인
switch context.biometryType {
case .faceID:
    print("Face ID")
case .touchID:
    print("Touch ID")
case .opticID:
    print("Optic ID (Vision Pro)")
case .none:
    print("생체 인증 없음")
@unknown default:
    break
}
```

### 2. 인증 정책

```swift
// 생체 인증만
.deviceOwnerAuthenticationWithBiometrics

// 생체 인증 + 기기 암호 (fallback)
.deviceOwnerAuthentication
```

### 3. 인증 실행

```swift
func authenticate() async -> Bool {
    let context = LAContext()
    context.localizedCancelTitle = "취소"
    context.localizedFallbackTitle = "암호 입력"  // 빈 문자열이면 숨김
    
    do {
        return try await context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "앱 잠금을 해제합니다"
        )
    } catch {
        return false
    }
}
```

## 전체 작동 예제

```swift
import SwiftUI
import LocalAuthentication

// MARK: - Biometric Manager
@Observable
class BiometricManager {
    var isAuthenticated = false
    var biometryType: LABiometryType = .none
    var canUseBiometrics = false
    var error: BiometricError?
    
    init() {
        checkBiometricAvailability()
    }
    
    func checkBiometricAvailability() {
        let context = LAContext()
        var error: NSError?
        
        canUseBiometrics = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        biometryType = context.biometryType
        
        if let error {
            self.error = mapError(error)
        }
    }
    
    func authenticate() async {
        let context = LAContext()
        context.localizedCancelTitle = "취소"
        context.localizedFallbackTitle = "암호 사용"
        
        // 이전 인증 무효화 (선택)
        context.invalidate()
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: biometryReason
            )
            
            await MainActor.run {
                isAuthenticated = success
                error = nil
            }
        } catch let authError as LAError {
            await MainActor.run {
                isAuthenticated = false
                error = mapLAError(authError)
            }
        } catch {
            await MainActor.run {
                isAuthenticated = false
                self.error = .unknown
            }
        }
    }
    
    func authenticateWithPasscode() async {
        let context = LAContext()
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthentication,  // 암호 fallback 포함
                localizedReason: "앱 잠금을 해제합니다"
            )
            
            await MainActor.run {
                isAuthenticated = success
            }
        } catch {
            await MainActor.run {
                isAuthenticated = false
            }
        }
    }
    
    func lock() {
        isAuthenticated = false
    }
    
    // MARK: - Helpers
    private var biometryReason: String {
        switch biometryType {
        case .faceID:
            return "Face ID로 앱 잠금을 해제합니다"
        case .touchID:
            return "Touch ID로 앱 잠금을 해제합니다"
        case .opticID:
            return "Optic ID로 앱 잠금을 해제합니다"
        default:
            return "앱 잠금을 해제합니다"
        }
    }
    
    private func mapError(_ error: NSError) -> BiometricError {
        switch error.code {
        case LAError.biometryNotAvailable.rawValue:
            return .notAvailable
        case LAError.biometryNotEnrolled.rawValue:
            return .notEnrolled
        case LAError.biometryLockout.rawValue:
            return .lockout
        default:
            return .unknown
        }
    }
    
    private func mapLAError(_ error: LAError) -> BiometricError {
        switch error.code {
        case .userCancel:
            return .userCancelled
        case .userFallback:
            return .userFallback
        case .authenticationFailed:
            return .authenticationFailed
        case .biometryLockout:
            return .lockout
        default:
            return .unknown
        }
    }
}

enum BiometricError: Error, LocalizedError {
    case notAvailable
    case notEnrolled
    case lockout
    case userCancelled
    case userFallback
    case authenticationFailed
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "생체 인증을 사용할 수 없습니다"
        case .notEnrolled:
            return "생체 인증이 설정되지 않았습니다"
        case .lockout:
            return "너무 많은 시도로 잠겼습니다. 기기 암호를 사용하세요"
        case .userCancelled:
            return "사용자가 취소했습니다"
        case .userFallback:
            return "암호 입력을 선택했습니다"
        case .authenticationFailed:
            return "인증에 실패했습니다"
        case .unknown:
            return "알 수 없는 오류가 발생했습니다"
        }
    }
}

// MARK: - Views
struct LockScreenView: View {
    @State private var biometricManager = BiometricManager()
    
    var body: some View {
        Group {
            if biometricManager.isAuthenticated {
                MainContentView(biometricManager: biometricManager)
            } else {
                AuthenticationView(biometricManager: biometricManager)
            }
        }
    }
}

struct AuthenticationView: View {
    let biometricManager: BiometricManager
    
    var body: some View {
        VStack(spacing: 32) {
            Image(systemName: biometricIcon)
                .font(.system(size: 80))
                .foregroundStyle(.blue)
            
            Text("앱 잠금")
                .font(.title.bold())
            
            Text("보안을 위해 인증이 필요합니다")
                .foregroundStyle(.secondary)
            
            if let error = biometricManager.error {
                Text(error.localizedDescription)
                    .foregroundStyle(.red)
                    .font(.caption)
            }
            
            Spacer()
            
            VStack(spacing: 16) {
                if biometricManager.canUseBiometrics {
                    Button {
                        Task {
                            await biometricManager.authenticate()
                        }
                    } label: {
                        Label(biometricButtonTitle, systemImage: biometricIcon)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                
                Button("암호로 잠금 해제") {
                    Task {
                        await biometricManager.authenticateWithPasscode()
                    }
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal, 40)
        }
        .padding()
        .task {
            // 앱 시작 시 자동으로 인증 요청
            if biometricManager.canUseBiometrics {
                await biometricManager.authenticate()
            }
        }
    }
    
    var biometricIcon: String {
        switch biometricManager.biometryType {
        case .faceID: return "faceid"
        case .touchID: return "touchid"
        case .opticID: return "opticid"
        default: return "lock.fill"
        }
    }
    
    var biometricButtonTitle: String {
        switch biometricManager.biometryType {
        case .faceID: return "Face ID로 잠금 해제"
        case .touchID: return "Touch ID로 잠금 해제"
        case .opticID: return "Optic ID로 잠금 해제"
        default: return "잠금 해제"
        }
    }
}

struct MainContentView: View {
    let biometricManager: BiometricManager
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        NavigationStack {
            List {
                Section("민감한 데이터") {
                    Text("비밀번호: ••••••••")
                    Text("카드번호: •••• •••• •••• 1234")
                }
            }
            .navigationTitle("보안 금고")
            .toolbar {
                Button("잠금") {
                    biometricManager.lock()
                }
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            // 앱이 백그라운드로 가면 잠금
            if newPhase == .background {
                biometricManager.lock()
            }
        }
    }
}
```

## 고급 패턴

### 1. Keychain과 연동

```swift
import Security

func saveToKeychain(data: Data, withBiometricProtection: Bool) throws {
    let access: SecAccessControlCreateFlags = withBiometricProtection 
        ? .biometryCurrentSet 
        : []
    
    guard let accessControl = SecAccessControlCreateWithFlags(
        nil,
        kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
        access,
        nil
    ) else {
        throw KeychainError.accessControlCreationFailed
    }
    
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: "secureData",
        kSecValueData as String: data,
        kSecAttrAccessControl as String: accessControl
    ]
    
    SecItemDelete(query as CFDictionary)
    let status = SecItemAdd(query as CFDictionary, nil)
    
    guard status == errSecSuccess else {
        throw KeychainError.saveFailed(status)
    }
}

func readFromKeychain() async throws -> Data {
    let context = LAContext()
    context.localizedReason = "저장된 데이터에 접근합니다"
    
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: "secureData",
        kSecReturnData as String: true,
        kSecUseAuthenticationContext as String: context
    ]
    
    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)
    
    guard status == errSecSuccess, let data = result as? Data else {
        throw KeychainError.readFailed(status)
    }
    
    return data
}
```

### 2. 재인증 방지 (일정 시간)

```swift
class BiometricManager {
    private var lastAuthTime: Date?
    private let authValidDuration: TimeInterval = 300  // 5분
    
    var needsReauthentication: Bool {
        guard let lastAuth = lastAuthTime else { return true }
        return Date().timeIntervalSince(lastAuth) > authValidDuration
    }
    
    func authenticate() async {
        guard needsReauthentication else {
            isAuthenticated = true
            return
        }
        
        // 실제 인증 수행
        // ...
        
        lastAuthTime = Date()
    }
}
```

## 주의사항

1. **Info.plist 필수**
   - Face ID 사용 시 `NSFaceIDUsageDescription` 필수
   - 누락 시 크래시

2. **에러 처리**
   - `.userCancel`: 사용자 취소 (조용히 처리)
   - `.userFallback`: 암호 입력 선택
   - `.biometryLockout`: 너무 많은 실패 (기기 암호 필요)

3. **생체 정보 변경 감지**
   ```swift
   // 저장된 값과 비교
   let oldDomainState = loadedDomainState
   let newDomainState = context.evaluatedPolicyDomainState
   
   if oldDomainState != newDomainState {
       // 생체 정보가 변경됨 (지문 추가/삭제 등)
       // 재인증 요구 가능
   }
   ```

4. **시뮬레이터 테스트**
   - Features → Face ID / Touch ID → Enrolled
   - Matching / Non-matching Face/Finger로 테스트
