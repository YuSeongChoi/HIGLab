# LocalAuthentication AI Reference

> Face ID / Touch ID biometric authentication guide. Read this document to generate biometric authentication code.

## Overview

LocalAuthentication is a framework that provides user authentication through Face ID, Touch ID, and device passcode.

## Required Import

```swift
import LocalAuthentication
```

## Project Setup (Info.plist)

```xml
<key>NSFaceIDUsageDescription</key>
<string>Face ID is used to unlock the app.</string>
```

## Core Components

### 1. LAContext

```swift
let context = LAContext()

// Check biometric availability
var error: NSError?
if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
    // Biometric authentication available
} else {
    // Not available (check error for reason)
}

// Check biometric type
switch context.biometryType {
case .faceID:
    print("Face ID")
case .touchID:
    print("Touch ID")
case .opticID:
    print("Optic ID (Vision Pro)")
case .none:
    print("No biometrics")
@unknown default:
    break
}
```

### 2. Authentication Policies

```swift
// Biometrics only
.deviceOwnerAuthenticationWithBiometrics

// Biometrics + device passcode (fallback)
.deviceOwnerAuthentication
```

### 3. Perform Authentication

```swift
func authenticate() async -> Bool {
    let context = LAContext()
    context.localizedCancelTitle = "Cancel"
    context.localizedFallbackTitle = "Enter Passcode"  // Empty string hides it
    
    do {
        return try await context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Unlock the app"
        )
    } catch {
        return false
    }
}
```

## Complete Working Example

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
        context.localizedCancelTitle = "Cancel"
        context.localizedFallbackTitle = "Use Passcode"
        
        // Invalidate previous authentication (optional)
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
                .deviceOwnerAuthentication,  // Includes passcode fallback
                localizedReason: "Unlock the app"
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
            return "Unlock the app with Face ID"
        case .touchID:
            return "Unlock the app with Touch ID"
        case .opticID:
            return "Unlock the app with Optic ID"
        default:
            return "Unlock the app"
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
            return "Biometric authentication is not available"
        case .notEnrolled:
            return "Biometric authentication is not set up"
        case .lockout:
            return "Locked due to too many attempts. Please use device passcode"
        case .userCancelled:
            return "User cancelled"
        case .userFallback:
            return "Passcode entry selected"
        case .authenticationFailed:
            return "Authentication failed"
        case .unknown:
            return "An unknown error occurred"
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
            
            Text("App Locked")
                .font(.title.bold())
            
            Text("Authentication required for security")
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
                
                Button("Unlock with Passcode") {
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
            // Automatically request authentication on app start
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
        case .faceID: return "Unlock with Face ID"
        case .touchID: return "Unlock with Touch ID"
        case .opticID: return "Unlock with Optic ID"
        default: return "Unlock"
        }
    }
}

struct MainContentView: View {
    let biometricManager: BiometricManager
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        NavigationStack {
            List {
                Section("Sensitive Data") {
                    Text("Password: ••••••••")
                    Text("Card Number: •••• •••• •••• 1234")
                }
            }
            .navigationTitle("Secure Vault")
            .toolbar {
                Button("Lock") {
                    biometricManager.lock()
                }
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            // Lock when app goes to background
            if newPhase == .background {
                biometricManager.lock()
            }
        }
    }
}
```

## Advanced Patterns

### 1. Integration with Keychain

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
    context.localizedReason = "Access saved data"
    
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

### 2. Preventing Re-authentication (For a Period)

```swift
class BiometricManager {
    private var lastAuthTime: Date?
    private let authValidDuration: TimeInterval = 300  // 5 minutes
    
    var needsReauthentication: Bool {
        guard let lastAuth = lastAuthTime else { return true }
        return Date().timeIntervalSince(lastAuth) > authValidDuration
    }
    
    func authenticate() async {
        guard needsReauthentication else {
            isAuthenticated = true
            return
        }
        
        // Perform actual authentication
        // ...
        
        lastAuthTime = Date()
    }
}
```

## Important Notes

1. **Info.plist Required**
   - `NSFaceIDUsageDescription` required for Face ID
   - App will crash if missing

2. **Error Handling**
   - `.userCancel`: User cancelled (handle silently)
   - `.userFallback`: Passcode entry selected
   - `.biometryLockout`: Too many failures (device passcode required)

3. **Detecting Biometric Changes**
   ```swift
   // Compare with saved value
   let oldDomainState = loadedDomainState
   let newDomainState = context.evaluatedPolicyDomainState
   
   if oldDomainState != newDomainState {
       // Biometric info changed (fingerprint added/removed, etc.)
       // Can require re-authentication
   }
   ```

4. **Simulator Testing**
   - Features → Face ID / Touch ID → Enrolled
   - Test with Matching / Non-matching Face/Finger
